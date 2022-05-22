# frozen_string_literal: true

require 'httparty'
require 'json'

class UpdateHolaplexJob < ApplicationJob
  queue_as :holaplex

  def max_attempts
    1
  end

  def perform
    listings = MetaplexListing
               .select("listings.address, listings.created_at, listings.ends_at, listings.price_floor,
                listing_metadatas.metadata_address, metadatas.uri,
                storefronts.subdomain as brand_name, metadatas.name, metadatas.mint_address")
               .joins(<<-SQL).
      LEFT JOIN listing_metadatas
      ON listings.address = listing_metadatas.listing_address
      LEFT JOIN metadatas
      ON listing_metadatas.metadata_address = metadatas.address
      LEFT JOIN storefronts
      ON listings.store_owner = storefronts.owner_address
    SQL
               where("listings.created_at < '#{Time.now}' AND listings.ends_at > '#{Time.now}' AND listings.ended = false AND storefronts.subdomain NOT IN ('sedoggos', 'gatsbyclub')")
    add_to_db(listings)
  end

  def add_to_db(listings)
    listings.each do |listing|
      next unless listing.ends_at
      next if listing.address.nil?

      row = Auction.where(mint: listing.mint_address, source: 'holaplex').first_or_create

      row.start_time = Time.parse(listing.created_at.to_s).to_i
      row.end_time = Time.parse(listing.ends_at.to_s).to_i
      row.metadata_uri = listing.uri
      row.brand_name = listing.brand_name
      row.name = listing.name
      row.reserve = listing.price_floor

      bids = MetaplexBid.where(listing_address: listing.address)
      unless bids.empty?
        last_bid = bids.order(last_bid_time: :desc).limit(1).first
        row.number_bids = bids.count
        row.highest_bid = last_bid.last_bid_amount
        row.highest_bidder = last_bid.bidder_address
      end
      row.save
    end
  end
end

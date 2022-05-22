# frozen_string_literal: true

require 'httparty'
require 'json'

class UpdateHolaplexJob < ApplicationJob
  queue_as :holaplex

  def max_attempts
    1
  end

  def perform
    response = Holaplex::Client.query(ListingsQuery::Listings)
    listings = response.data.listings
    active = listings.select { |l| l.ended == false && !l.ends_at.nil? }
    add_to_db(active)
    finalize(listings)
  end

  def add_to_db(listings)
    listings.each do |listing|
      next unless listing.ends_at
      next if listing.address.nil?

      row = Auction.where(mint: listing.nfts[0].mint_address, source: 'holaplex').first_or_create

      # row.start_time = Time.parse(listing.created_at.to_s).to_i
      row.end_time = Time.parse(listing.ends_at.to_s).to_i
      row.image = listing.nfts[0].image
      row.brand_name = listing.storefront.subdomain
      row.name = listing.nfts[0].name
      # row.reserve = listing.price_floor

      bids = listing.bids
      unless bids.empty?
        last_bid = bids.first
        row.number_bids = bids.count
        row.highest_bid = last_bid.last_bid_amount
        row.highest_bidder = last_bid.bidder_address
      end
      row.save
    end
  end

  def finalize(listings)
    Auction.where("end_time < #{Time.now.to_i} AND finalized = false AND source = 'holaplex'").each do |row|
      listing = listings.select { |l| l.nfts[0] && l.nfts[0].mint_address == row.mint && l.ended == true && !l.ends_at.nil? }.last
      next unless listing
      next unless Time.parse(listing.ends_at.to_s).to_i < Time.now.to_i

      bids = listing.bids

      unless bids.empty?
        last_bid = bids.first
        row.number_bids = bids.count
        row.highest_bid = last_bid.last_bid_amount
        row.highest_bidder = last_bid.bidder_address
      end

      row.finalized = true
      row.save
    end
  end
end

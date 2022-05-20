# frozen_string_literal: true

require 'httparty'
require 'json'

class FinalizeHolaplexJob < ApplicationJob
  queue_as :holaplex

  def perform
    Auction.where("end_time < #{Time.now.to_i} AND finalized = false AND source = 'holaplex'").each do |row|
      listing = MetaplexListing
                .select("listings.address, listings.ends_at")
                .joins(<<-SQL).
                  LEFT JOIN listing_metadatas
                  ON listings.address = listing_metadatas.listing_address
                  LEFT JOIN metadatas
                  ON listing_metadatas.metadata_address = metadatas.address
                SQL
                where("metadatas.mint_address = '#{row.mint}' AND listings.ends_at IS NOT NULL AND listings.ended = true").last
      next unless listing
      next unless Time.parse(listing.ends_at.to_s).to_i < Time.now.to_i

      bids = MetaplexBid.where(listing_address: listing.address)

      unless bids.empty?
        last_bid = bids.order(last_bid_time: :desc).limit(1).first
        row.number_bids = bids.count
        row.highest_bid = last_bid.last_bid_amount
        row.highest_bidder = last_bid.bidder_address
      end

      row.finalized = true
      row.save
    end
  end
end

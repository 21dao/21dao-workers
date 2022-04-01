# frozen_string_literal: true

require 'httparty'
require 'json'

class FinalizeFormfunctionJob < ApplicationJob
  queue_as :formfunction

  def perform
    Auction.where("end_time < #{Time.now.to_i} AND finalized = false AND source = 'formfunction'").each do |row|
      response = fetch_from_formfunction(row['mint'])
      next unless response['info'] && response['info']['endTime']

      next unless Time.parse(response['info']['endTime']).to_i < Time.now.to_i

      row.highest_bid = response['info']['highestBid']
      row.highest_bidder = response['info']['highestBidder']
      row.number_bids = response['info']['numberOfBids']
      row.highest_bidder_username = response['info']['highestBidderUsername']
      row.finalized = true
      row.save
    end
    FinalizeFormfunctionJob.delay(run_at: 5.minutes.from_now).perform_later
  end

  def fetch_from_formfunction(mint)
    result = HTTParty.get("#{ENV['FORMFUNCTION_LAST_AUCTION']}?mintAddress=#{mint}",
                          headers: { 'Accept' => 'application/json' })
    result.parsed_response
  end
end

# frozen_string_literal: true

require 'httparty'
require 'json'

class FinalizeExchangeJob < ApplicationJob
  queue_as :exchange_art

  def perform
    Auction.where("end_time < #{Time.now.to_i} AND finalized = false AND source = 'exchange'").each do |row|
      next if row['collection_name'].nil?

      response = fetch_from_exchange(row['collection_name'], 0)
      next if find_mint(response['auctions'], row)

      remaining = response['count'] - 20
      from = 20
      while remaining.positive?
        response = fetch_from_exchange(row['collection_name'], from)
        remaining -= 20
        from += 20
        remaining = 0 if find_mint(response['auctions'], row)
      end
    end
    FinalizeExchangeJob.delay(run_at: 5.minutes.from_now).perform_later
  end

  def find_mint(auctions, row)
    return if auctions.nil?

    found = false
    auctions.each do |auction|
      next unless auction['keys']['mint'] == row.mint

      row.end_time = auction['data']['end']
      row.highest_bid = auction['data']['highestBid']
      row.highest_bidder = auction['data']['highestBidder']
      row.number_bids = auction['data']['numberBids']
      row.finalized = true
      row.save
      found = true
    end
    found
  rescue StandardError => e
    Rails.logger.error e.message
    false
  end

  def fetch_from_exchange(collection, from)
    result = HTTParty.post(ENV['EXCHANGE_AUCTIONS'],
                           body: {
                             from: from,
                             size: 20,
                             query: {
                               filters: {
                                 collections: [collection]
                               }
                             }
                           }.to_json,
                           headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json' })
    result.parsed_response
  rescue StandardError => e
    Rails.logger.error e.message
  end
end

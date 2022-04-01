# frozen_string_literal: true

require 'httparty'
require 'json'

class UpdateExchangeJob < ApplicationJob
  queue_as :exchange_art

  def perform
    response = fetch_from_exchange(0)
    add_to_db(response['auctions'])
    remaining = response['count'] - 20
    from = 20
    while remaining.positive?
      response = fetch_from_exchange(from)
      add_to_db(response['auctions'])
      remaining -= 20
      from += 20
    end
    UpdateExchangeJob.delay(run_at: 5.minutes.from_now).perform_later
  end

  def fetch_from_exchange(from)
    result = HTTParty.post(ENV['EXCHANGE_AUCTIONS'],
                           body: { from: from,
                                   size: 20,
                                   sorting: 'ending-asc',
                                   query: {
                                     filters: {
                                       doNotShowEnded: true
                                     }
                                   } }.to_json,
                           headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json' })
    result.parsed_response
  end

  def add_to_db(auctions)
    auctions.each do |auction|
      next unless auction['tokenPreviewData']['collection']['isOneOfOne']
      next if auction['tokenPreviewData']['collection']['isNsfw']

      row = Auction.where(mint: auction['keys']['mint'], source: 'exchange').first_or_create
      row.start_time = auction['data']['start']
      row.end_time = auction['data']['end']
      row.reserve = auction['data']['reservePrice']
      row.min_increment = auction['data']['minimumIncrement']
      row.ending_phase = auction['data']['endingPhase']
      row.extension = auction['data']['extensionWindow']
      row.highest_bid = auction['data']['highestBid']
      row.highest_bidder = auction['data']['highestBidder']
      row.number_bids = auction['data']['numberBids']
      row.brand_id = auction['tokenPreviewData']['brand']['id']
      row.brand_name = auction['tokenPreviewData']['brand']['name']
      row.collection_id = auction['tokenPreviewData']['collection']['id']
      row.collection_name = auction['tokenPreviewData']['collection']['name']
      row.image = auction['tokenPreviewData']['image']
      row.name = auction['tokenPreviewData']['name']
      row.save
    end
  end
end

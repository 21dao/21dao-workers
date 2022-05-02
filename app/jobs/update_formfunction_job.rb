# frozen_string_literal: true

require 'httparty'
require 'json'

class UpdateFormfunctionJob < ApplicationJob
  queue_as :formfunction

  def perform
    response = fetch_from_formfunction
    if response['auctions'].nil?
      Bugsnag.notify("empty response")
    else
      add_to_db(response['auctions'])
    end
    UpdateFormfunctionJob.delay(run_at: 5.minutes.from_now).perform_later
  end

  def fetch_from_formfunction
    result = HTTParty.get(ENV['FORMFUNCTION_AUCTIONS'],
                          headers: { 'Accept' => 'application/json' })
    result.parsed_response
  end

  def add_to_db(auctions)
    auctions.each do |auction|
      row = Auction.where(mint: auction['mintAddress'], source: 'formfunction').first_or_create
      row.start_time = Time.parse(auction['startTime']).to_i
      row.end_time = Time.parse(auction['endTime']).to_i
      row.reserve = auction['reserve']
      row.highest_bid = auction['highestBid']
      row.highest_bidder = auction['highestBidder']
      row.number_bids = auction['numberOfBids']
      row.brand_name = auction['artistName']
      row.image = auction['image']
      row.name = auction['name']
      row.highest_bidder_username = auction['highestBidderUsername']
      row.secondary = auction['isSecondary']
      row.save
    end
  end
end

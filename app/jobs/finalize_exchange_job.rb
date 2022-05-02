# frozen_string_literal: true

require 'httparty'
require 'json'

class FinalizeExchangeJob < ApplicationJob
  queue_as :exchange_art

  def perform
    Auction.where("end_time < #{Time.now.to_i - 300} AND finalized = false AND source = 'exchange'").each do |row|
      response = fetch_from_exchange(row['mint'])
      update_sale(response[0], row) unless response.nil?
    end
    FinalizeExchangeJob.delay(run_at: 5.minutes.from_now).perform_later
  end

  def update_sale(sale, row)
    return if sale.nil?

    row.highest_bid = sale['amount']
    row.highest_bidder = sale['to']
    row.finalized = true
    row.save
  end

  def finalize_now(row)
    row.update_attribute :finalized, true
  end

  def fetch_from_exchange(mint)
    result = HTTParty.post(ENV['EXCHANGE_SALES'],
                           body: {
                             query: {
                               filters: {
                                 mint: mint
                               }
                             }
                           }.to_json,
                           headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json' })
    result.parsed_response
  rescue StandardError => e
    Bugsnag.notify e
    nil
  end
end

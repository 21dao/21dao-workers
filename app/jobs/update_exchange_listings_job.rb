# frozen_string_literal: true

require 'httparty'
require 'json'

class UpdateExchangeListingsJob < ApplicationJob
  queue_as :exchange_art

  def perform
    @listings = []
    response = fetch_from_exchange(0)
    add_to_db(response['tokens'])
    remaining = response['totalCountOfResults'] - 20
    from = 20
    while remaining.positive?
      response = fetch_from_exchange(from)
      add_to_db(response['tokens'])
      remaining -= 20
      from += 20
    end
    remove_old_listings
    UpdateExchangeListingsJob.delay(run_at: 15.minutes.from_now).perform_later
  end

  def remove_old_listings
    listings = Listing.all.pluck(:mint)
    (listings - @listings).each do |mint|
      Listing.find_by_mint(mint).delete
    end
  end

  def fetch_from_exchange(from)
    url = "#{ENV['EXCHANGE_LISTINGS']}?limit=20&from=#{from}&filters={\"tokenStatus\":[\"curated\",\"certified\",\"known\"]}"
    result = HTTParty.get(url)
    result.parsed_response
  rescue StandardError
    nil
  end

  def add_to_db(tokens)
    return unless tokens

    tokens.each do |token|
      row = Listing.where(mint: token['mintKey']).first_or_create
      row.is_listed = token['isListed']
      row.last_listed = token['lastListedAt']
      row.listed_by = token['currentlyListedBy']
      row.last_sale_price = token['lastSalePrice']
      row.last_listed_price = token['lastListedPrice']
      row.image = token['image']
      row.title = token['name']
      row.description = token['description']
      row.name = token['brand']['name']
      row.save
      @listings << token['mintKey']
    rescue StandardError => e
      Rails.logger.error e.message
    end
  end
end

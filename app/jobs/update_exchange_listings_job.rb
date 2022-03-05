# frozen_string_literal: true

require 'httparty'
require 'json'

class UpdateExchangeListingsJob < ApplicationJob
  queue_as :exchange_art

  def perform
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
    UpdateExchangeListingsJob.delay(run_at: 5.minutes.from_now).perform_later
  end

  def fetch_from_exchange(from)
    artist_names = Artist.all.pluck(:name)
    result = HTTParty.get("#{ENV['EXCHANGE_LISTINGS']}?limit=20&from=#{from}&filters={\"tokenStatus\":[\"curated\",\"certified\",\"known\"],\"brands\":#{artist_names}}")
    result.parsed_response
  rescue StandardError
    nil
  end

  def add_to_db(tokens)
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
    rescue StandardError => e
      Rails.logger.error e.message
    end
  end
end

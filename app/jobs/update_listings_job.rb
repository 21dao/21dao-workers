# frozen_string_literal: true

require 'httparty'
require 'json'

class UpdateListingsJob < ApplicationJob
  queue_as :exchange_art

  def max_attempts
    1
  end

  def perform
    response = fetch_from_exchange(0)
    add_to_db(response['tokens'])
    remaining = response['totalCountOfResults'] - 1000
    from = 1000
    while remaining.positive?
      response = fetch_from_exchange(from)
      add_to_db(response['tokens'])
      remaining -= 1000
      from += 1000
    end
  end

  def fetch_from_exchange(from)
    names = Artist.pluck(:name)
    url = "#{ENV['EXCHANGE_LISTINGS']}?limit=1000&from=#{from}&filters={\"brands\":#{names}}"
    result = HTTParty.get(url,
                          headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json' })
    result.parsed_response
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
      row.name = token['brand']['name']
      row.description = token['description']
      row.title = token['name']
      row.save
    end
  end
end

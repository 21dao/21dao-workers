# frozen_string_literal: true

require 'httparty'
require 'json'

class ImageFromUriJob < ApplicationJob
  queue_as :image

  def max_attempts
    1
  end

  def perform
    Auction.where("image IS NULL AND source = 'holaplex'").each do |auction|
      next unless auction.metadata_uri

      resp = HTTParty.get(auction.metadata_uri)
      data = resp.body
      result = JSON.parse(data)
      auction.image = result['image']
      auction.save
    end
  end
end

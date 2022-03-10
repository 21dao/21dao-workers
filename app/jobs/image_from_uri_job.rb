# frozen_string_literal: true

require 'httparty'
require 'json'

class ImageFromUriJob < ApplicationJob
  queue_as :image

  def perform
    Auction.where("image IS NULL AND source = 'holaplex'").each do |auction|
      next unless auction.metadata_uri

      resp = HTTParty.get(auction.metadata_uri)
      data = resp.body
      result = JSON.parse(data)
      auction.image = result['image']
      auction.save
    rescue StandardError => e
      Rails.logger.error e.message
      Rails.logger.error e.backtrace
    end
    ImageFromUriJob.delay(run_at: 5.minutes.from_now).perform_later
  end
end

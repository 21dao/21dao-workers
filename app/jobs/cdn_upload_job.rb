# frozen_string_literal: true

require 'aws-sdk-s3'
require 'down'
require 'httparty'

class CdnUploadJob < ApplicationJob
  queue_as :cdn_upload

  def perform
    upload_auction_images
    upload_listing_images
    CdnUploadJob.delay(run_at: 5.minutes.from_now).perform_later
  end

  def upload_auction_images
    Auction.where(cdn_uploaded: false).each do |auction|
      next unless auction.mint && auction.image
      next unless auction.image.start_with? 'http'

      uploaded = upload(auction.mint, auction.image)
      auction.update_attribute(:cdn_uploaded, true) if uploaded
    end
  end

  def upload_listing_images
    Listing.where(is_listed: true, cdn_uploaded: false).each do |listing|
      next unless listing.image.start_with? 'http'

      uploaded = upload(listing.mint, listing.image)
      listing.update_attribute(:cdn_uploaded, true) if uploaded
    end
  end

  def upload(mint, uri)
    filename = mint.to_s
    cdn_url = "#{ENV['S3_URL']}/#{filename}"
    return if remote_file_exists(cdn_url)

    file = Down.download(uri)
    return if file.content_type == 'application/octet-stream'

    client.put_object({
                        bucket: ENV['S3_BUCKET'],
                        key: filename,
                        body: file,
                        acl: "public-read",
                        content_type: file.content_type
                      })
    true
  rescue StandardError => e
    Rails.logger.error e.message
    false
  end

  def client
    Aws::S3::Client.new(
      access_key_id: ENV['S3_ACCESS_KEY_ID'],
      secret_access_key: ENV['S3_SECRET_ACCESS_KEY'],
      endpoint: ENV['S3_ENDPOINT'],
      region: ENV['S3_REGION']
    )
  end

  def remote_file_exists(url)
    url_parsed = URI(url)
    response = nil
    Net::HTTP.start(url_parsed.host, 80) do |http|
      response = http.head(url_parsed.path.to_s + url_parsed.query.to_s)
    end
    return true if response.code[0, 1] == "2" || response.code[0, 1] == "3"

    false
  end

  def max_attempts
    1
  end
end

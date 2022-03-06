# frozen_string_literal: true

require 'aws-sdk-s3'
require 'down'
require 'httparty'

class CdnUploadJob < ApplicationJob
  queue_as :cdn_upload

  def perform
    Auction.where(cdn_uploaded: false).each do |auction|
      next unless auction.mint && auction.image
      next unless auction.image.start_with? 'http'

      upload(auction.mint, auction.image)
    end
    CdnUploadJob.delay(run_at: 5.minutes.from_now).perform_later
  end

  def upload(mint, uri)
    filename = mint.to_s
    cdn_url = "#{ENV['S3_URL']}/#{filename}"
    return if remote_file_exists(cdn_url)

    file = begin
      Down.download(uri)
    rescue Down::Error
      nil
    end
    return if file.nil? || file.content_type == 'application/octet-stream'

    client.put_object({
                        bucket: ENV['S3_BUCKET'],
                        key: filename,
                        body: file,
                        acl: "public-read",
                        content_type: file.content_type
                      })
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
end

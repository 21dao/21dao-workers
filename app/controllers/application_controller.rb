# frozen_string_literal: true

class ApplicationController < ActionController::API
  def artist_names
    params[:names].map do |s|
      "%#{s.downcase.gsub(' ', '%')}%"
    end.join(',')
  end

  def check_marketplaces
    return true if params[:marketplace] - MARKETPLACES == []

    false
  rescue StandardError
    false
  end

  def days
    if params[:days] && DAYS.include?(params[:days].to_i)
      params[:days].to_i
    else
      1
    end
  end

  def limit_and_offset(auctions)
    auctions = auctions.limit(params[:limit].to_i) if params[:limit]
    auctions = auctions.offset(params[:offset].to_i) if params[:offset]
    auctions
  end
end

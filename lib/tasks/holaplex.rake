namespace :holaplex do
  task populate: :environment do
    listings = MetaplexListing
               .select("listings.address, listings.created_at, listings.ends_at, listings.price_floor,
                listing_metadatas.metadata_address, metadatas.uri,
                storefronts.subdomain as brand_name, metadatas.name, metadatas.mint_address")
               .joins(<<-SQL).
      LEFT JOIN listing_metadatas
      ON listings.address = listing_metadatas.listing_address
      LEFT JOIN metadatas
      ON listing_metadatas.metadata_address = metadatas.address
      LEFT JOIN storefronts
      ON listings.store_owner = storefronts.owner_address
    SQL
              where("listings.highest_bid >= listings.price_floor AND listings.ends_at < '#{Time.now-6.months}' AND listings.ended = true AND storefronts.subdomain NOT IN ('sedoggos', 'gatsbyclub')")
    count = 0
    listings.each do |listing|
        next unless listing.ends_at
        next if listing.address.nil?

        next if Auction.where(mint: listing.mint_address, source: 'holaplex').first

        row = Auction.create(mint: listing.mint_address, source: 'holaplex')
        row.start_time = Time.parse(listing.created_at.to_s).to_i
        row.end_time = Time.parse(listing.ends_at.to_s).to_i
        row.metadata_uri = listing.uri
        row.brand_name = listing.brand_name
        row.name = listing.name
        row.reserve = listing.price_floor

        bids = MetaplexBid.where(listing_address: listing.address)
        unless bids.empty?
          last_bid = bids.order(last_bid_time: :desc).limit(1).first
          row.number_bids = bids.count
          row.highest_bid = last_bid.last_bid_amount
          row.highest_bidder = last_bid.bidder_address
        end
        row.save
        count += 1
      end
      puts "added #{count} records"
  end
end

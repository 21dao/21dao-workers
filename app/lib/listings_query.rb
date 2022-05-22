module ListingsQuery
  Listings = Holaplex::Client.parse <<-'GRAPHQL'
    query {
      listings {
        ended
        endsAt
        address
        nfts {
            name
            mintAddress
            description
            image
        }
        bids {
            lastBidTime
            lastBidAmount
            bidderAddress
        }
        storefront {
            subdomain
        }
      }
    }
  GRAPHQL
end

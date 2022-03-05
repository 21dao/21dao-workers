# frozen_string_literal: true

class MetaplexListingMetadata < ApplicationRecord
  self.abstract_class = true
  connects_to database: { writing: :metaplex, reading: :metaplex }
  self.table_name = 'listing_metadatas'
end

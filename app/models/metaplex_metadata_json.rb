# frozen_string_literal: true

class MetaplexMetadataJson < ApplicationRecord
  self.abstract_class = true
  connects_to database: { writing: :metaplex, reading: :metaplex }
  self.table_name = 'metadata_jsons'
end

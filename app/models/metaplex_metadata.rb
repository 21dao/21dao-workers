# frozen_string_literal: true

class MetaplexMetadata < ApplicationRecord
  self.abstract_class = true
  connects_to database: { writing: :metaplex, reading: :metaplex }
  self.table_name = 'metadatas'
end

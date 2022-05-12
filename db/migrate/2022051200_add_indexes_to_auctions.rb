class AddIndexesToAuctions < ActiveRecord::Migration[5.0]
  disable_ddl_transaction!

  def self.up
    add_index :auctions, :collection_name, algorithm: :concurrently
    add_index :auctions, :brand_name, algorithm: :concurrently
    add_index :auctions, :finalized, algorithm: :concurrently
  end

  def self.down
    remove_index :auctions, :collection_name
    remove_index :auctions, :brand_name
    remove_index :auctions, :finalized
  end
end

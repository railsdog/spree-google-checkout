class AddGoogleCheckoutColumnsInOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :financial_order_state , :string
    add_column :orders, :google_order_number, :string
    add_column :orders, :buyer_id, :string
    add_column :orders, :gateway, :string
  end

  def self.down
    remove_column :orders, :financial_order_state
    remove_column :orders, :google_order_number
    remove_column :orders, :buyer_id
    remove_column :orders, :gateway
  end
end

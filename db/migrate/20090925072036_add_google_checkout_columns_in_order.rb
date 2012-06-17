class AddGoogleCheckoutColumnsInOrder < ActiveRecord::Migration
  def self.up
    add_column :spree_orders, :financial_order_state , :string
    add_column :spree_orders, :google_order_number, :string
    add_column :spree_orders, :buyer_id, :string
    add_column :spree_orders, :gateway, :string
  end

  def self.down
    remove_column :spree_orders, :financial_order_state
    remove_column :spree_orders, :google_order_number
    remove_column :spree_orders, :buyer_id
    remove_column :spree_orders, :gateway
  end
end

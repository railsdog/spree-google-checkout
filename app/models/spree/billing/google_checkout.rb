module Spree
  class Billing::GoogleCheckout < BillingIntegration
    preference :use_sandbox, :boolean, :default => true
    preference :merchant_id, :string
    preference :merchant_key, :string  
    preference :currency, :string, :default => "USD" 

    attr_accessible :preferred_use_sandbox, :preferred_merchant_id, :preferred_merchant_key, :preferred_currency

    def tax_table_factory
      TaxTableFactory.new
    end
    
    def [](config_setting)
      begin
        self.send("preferred_#{config_setting}")
      rescue NoMethodError
        super
      end
    end
    
    def self.current
      self.where(:type => self.to_s, :environment => Rails.env, :active => true).first
    end
  end
end

class Billing::GoogleCheckout < BillingIntegration
  preference :use_sandbox, :boolean, :default => true
  preference :merchant_id, :string
  preference :merchant_key, :string  
  preference :currency, :string, :default => "USD" 
  
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
    self.first(:conditions => {:type => self.to_s, :environment => RAILS_ENV, :active => true})
  end
end

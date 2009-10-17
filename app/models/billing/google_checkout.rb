class Billing::GoogleCheckout < BillingIntegration
  preference :use_sandbox, :boolean, :default => true
  preference :merchant_id, :string
  preference :merchant_key, :string  
  preference :currency, :string, :default => "USD" 
  
  def tax_table_factory
    TaxTableFactory.new
  end
  
  def [](config_setting)
    self.send("preferred_#{config_setting}")
  end
end
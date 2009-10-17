module GoogleCheckout::ControllerExtender
  protected 
  
  def get_google_checkout_frontend
    return nil unless integration = Billing::GoogleCheckout.current
    #return nil unless load_google_gateway
    gc_config = { 
      :merchant_id  => integration.preferred_merchant_id, 
      :merchant_key => integration.preferred_merchant_key, 
      :use_sandbox  => integration.preferred_use_sandbox }
                                                
              
    #@gc_currency = @gw.gateway_option_values[2].value
    front_end = Google4R::Checkout::Frontend.new(gc_config)
    front_end.tax_table_factory = TaxTableFactory.new
    front_end
  end
    
end

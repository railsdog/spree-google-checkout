module GoogleCheckout::ControllerExtender
    protected 
    
    def load_google_gateway
      @gateway = Gateway.find_by_clazz "Google4R::Checkout::Frontend"
      @gw = GatewayConfiguration.find_by_gateway_id(@gateway.id)
      @gw.present? && 
        @gw.gateway_option_values[0].value.present? && 
        @gw.gateway_option_values[1].value.present? && 
        @gw.gateway_option_values[2].value.present?       
    end
    
    def get_google_checkout_frontend
      return nil unless load_google_gateway
      @gc_configuration = { 
        :merchant_id  => @gw.gateway_option_values[0].value, 
        :merchant_key => @gw.gateway_option_values[1].value, 
        :use_sandbox  => Spree::Config[:use_google_sandbox] }
                
      @gc_currency = @gw.gateway_option_values[2].value
      Google4R::Checkout::Frontend.new(@gc_configuration)
    end
    
end

module Spree
  OrdersController.class_eval do
    helper :google_checkout
    include GoogleCheckout::ControllerExtender
    before_filter :clear_session, :only => [:show]
    before_filter :setup_google_checkout, :only => :edit

    private
    def setup_google_checkout
      @order = current_order(true)
      @frontend = get_google_checkout_frontend 

      if @frontend     
        checkout_command = @frontend.create_checkout_command
        # Adding an item to shopping cart
        @order.line_items.each do |l|
          checkout_command.shopping_cart.create_item do |item|  
            item.name = l.product.name
            item.description = l.product.description
            item.unit_price = Money.new(100 * l.price, Billing::GoogleCheckout.current[:currency])    
            item.quantity = l.quantity
          end
        end
        checkout_command.shopping_cart.private_data = { 'order_number' => @order.id } 
        checkout_command.edit_cart_url = edit_order_url(@order)
        checkout_command.continue_shopping_url = order_url(@order, :checkout_complete => true)
        
        fake_shipment = Shipment.new :order => @order, :address => @order.ship_address
        ShippingMethod.all.each do |ship_method|
          
          checkout_command.create_shipping_method(Google4R::Checkout::FlatRateShipping) do |shipping_method|    
            shipping_method.name = ship_method.name
            ship_method_price = ship_method.calculator.compute(fake_shipment) || 0
            shipping_method.price = Money.new(100*ship_method_price, Billing::GoogleCheckout.current[:currency])
            shipping_method.create_allowed_area(Google4R::Checkout::UsCountryArea) do |area|
              area.area = Google4R::Checkout::UsCountryArea::ALL
            end
          end
        end
        @response = checkout_command.to_xml #send_to_google_checkout
        # puts "===========#{request.raw_post}"
      end
    end
    
    def clear_session
      session[:order_id] = nil
    end
  end
end

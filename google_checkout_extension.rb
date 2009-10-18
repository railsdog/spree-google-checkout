# Uncomment this if you reference any of your controllers in activate
begin
   require_dependency 'application_controller'
rescue MissingSourceFile
   require_dependency 'application'
end


class GoogleCheckoutExtension < Spree::Extension
  version "1.0"
  description "Provides google checkout payment gateway functionality.  User specifies an GoogleCheckout compatible gateway to use in the aplication."
  url "http://github.com/romul/spree-google-checkout"

  # Please use google_checkout/config/routes.rb instead for extension routes.

  def self.require_gems(config)
    config.gem 'oauth'
    config.gem 'google4r-checkout', :lib => 'google4r/checkout'
  end
  
  def activate       
                                               
    # register the BillingIntegration
    Billing::GoogleCheckout.register
    
    Spree::BaseHelper.module_eval do
      def signature(base_string, consumer_secret)
        secret="#{escape(consumer_secret)}"
        Base64.encode64(HMAC::SHA1.digest(secret,base_string)).chomp.gsub(/\n/,'')
      end
      def escape(value)
        CGI.escape(value.to_s).gsub("%7E", '~').gsub("+", "%20")
      end 
    end
    
    Order.class_eval do
      def restock_inventory
        inventory_units.each do |inventory_unit|
          inventory_unit.restock!
        end
      end
    end
    
    Admin::OrdersController.class_eval do
      include GoogleCheckout::ControllerExtender
              
      def charge_google_order
        begin
          @frontend = get_google_checkout_frontend
          if @frontend 
            order = @frontend.create_charge_order_command
            o = Order.find_by_number(params[:id])
            order.google_order_number = o.google_order_number if o.google_order_number.present? 
            order.amount = Money.new(100 * o.total, Billing::GoogleCheckout.current[:currency])            
            res = order.send_to_google_checkout
                                        
            payment = Payment.new(:amount => o.total)
            payment.order = o
            payment.save
            flash[:notice] = t('google_checkout.order_charged')
          end
        rescue
          flash[:error] = t('google_checkout.order_charge_failed')
          logger.error $!
        end
        redirect_to :back
      end
    
      def cancel_google_checkout_order
        begin
          @frontend = get_google_checkout_frontend
          if @frontend    
            order = @frontend.create_cancel_order_command
            o = Order.find_by_number(params[:id])
            order.google_order_number = o.google_order_number if o.google_order_number.present? 
            order.reason = params[o.number][:reason]
            order.comment = params[o.number][:comment]
            res = order.send_to_google_checkout
            
            o.cancel!
            flash[:notice] = t('google_checkout.order_cancelled')
          end
        rescue
          flash[:error] = t('google_checkout.order_cancel_failed')
          logger.error $!
        end
        redirect_to :back
      end
   
    end
    
    
    OrdersController.class_eval do
      helper :google_checkout
      include GoogleCheckout::ControllerExtender
      
      def edit
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
              shipping_method.price = Money.new(100*ship_method.calculate_cost(fake_shipment), Billing::GoogleCheckout.current[:currency])
              shipping_method.create_allowed_area(Google4R::Checkout::UsCountryArea) do |area|
                area.area = Google4R::Checkout::UsCountryArea::ALL
              end
            end       
          end 
          @response = checkout_command.to_xml #send_to_google_checkout

          # puts "===========#{request.raw_post}"
       end
     end
     
     show.before do
       session[:order_id] = nil
     end
    end
    
  end
  
  
end

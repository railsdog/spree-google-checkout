# Uncomment this if you reference any of your controllers in activate
 require_dependency 'application'

class GoogleCheckoutExtension < Spree::Extension
  version "1.0"
  description "Provides google checkout payment gateway functionality.  User specifies an GoogleCheckout compatible gateway 
  to use in the aplication."
  #url "http://yourwebsite.com/google_checkout"

  # Please use google_checkout/config/routes.rb instead for extension routes.

  def self.require_gems(config)
    config.gem 'oauth'
    config.gem 'google4r-checkout', :lib => 'google4r/checkout'
  end
  
  def activate   
    
    if Spree::Config.instance
      Spree::Config.set(:google_checkout_button => true)
    end
    
    Spree::BaseHelper.module_eval do
      def signature(base_string, consumer_secret)
        secret="#{escape(consumer_secret)}"
        Base64.encode64(HMAC::SHA1.digest(secret,base_string)).chomp.gsub(/\n/,'')
      end
      def escape(value)
        CGI.escape(value.to_s).gsub("%7E", '~').gsub("+", "%20")
      end 
    end
    
    Admin::OrdersController.class_eval do
      include GoogleCheckout::ControllerExtender
        
      def charge_google_order
        @frontend = get_google_checkout_frontend 
        if @frontend 
          order = @frontend.create_charge_order_command
          o = Order.find_by_number(params[:id])
          order.google_order_number = o.google_order_number if o.google_order_number.present? 
          order.amount = Money.new(100 * o.total, @gc_currency)
          #puts "=-=-=-=-=-_+_+_+-#{order.to_xml}"
          @orders = order.send_to_google_checkout
          flash[:notice] = t('charged_google_checkout_order')
          redirect_to :back
        end
      end
    
      def cancel_google_checkout_order
        @frontend = get_google_checkout_frontend 
        if @frontend    
          order = @frontend.create_cancel_order_command
          o = Order.find_by_number(params[:id])
          order.google_order_number = o.google_order_number if o.google_order_number.present? 
          order.reason = params[:reason]
          order.comment = params[:comment]
          @orders = order.send_to_google_checkout
          #puts "=-=-=-=-=-_+_+_+-#{@orders}"
        end
      end
   
    end
    
    
    OrdersController.class_eval do
      include GoogleCheckout::ControllerExtender
      
      def edit
        # set use_sandbox to false for production
        @frontend = get_google_checkout_frontend 
        if @frontend     
          @frontend.tax_table_factory = TaxTableFactory.new
          checkout_command = @frontend.create_checkout_command
          # Adding an item to shopping cart
          @order.line_items.each do |l|
            checkout_command.shopping_cart.create_item do |item|  
              item.name = l.product.name
              item.description = l.product.description
              item.unit_price = Money.new(100 * l.price, @gc_currency)    
              item.quantity = l.quantity
            end
          end
          checkout_command.shopping_cart.private_data = { 'order_number' => @order.id } 
          checkout_command.edit_cart_url = edit_order_url(@order)
          checkout_command.continue_shopping_url = order_url(@order)
       
          #Create a flat rate shipping method
          i = 50
          ShippingMethod.all.each do |ship_method| 
         
            checkout_command.create_shipping_method(Google4R::Checkout::FlatRateShipping) do |shipping_method|    
              shipping_method.name = ship_method.name #"UPS Standard 3 Day"
              shipping_method.price = Money.new(i, @gc_currency)
              shipping_method.create_allowed_area(Google4R::Checkout::UsCountryArea) do |area|
                area.area = Google4R::Checkout::UsCountryArea::ALL
              end 
              i += 50
            end       
          end 
          @response = checkout_command.to_xml       #send_to_google_checkout    # 

          # puts "===========#{request.raw_post}"
       end
     end
     
     show.before do
       session[:order_id] = nil
     end
    end
    
  end
  
  
end

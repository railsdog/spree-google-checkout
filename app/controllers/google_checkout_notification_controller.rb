class GoogleCheckoutNotificationController < ApplicationController
  protect_from_forgery :except => :create
  include GoogleCheckout::ControllerExtender
  
  def create
    frontend = get_google_checkout_frontend
    frontend.tax_table_factory = TaxTableFactory.new
    handler = frontend.create_notification_handler
        
    begin
      notification = handler.handle(request.raw_post) # raw_post contains the XML
      if notification.is_a?(Google4R::Checkout::NewOrderNotification)
        @order = Order.find_by_id(params[:new_order_notification][:shopping_cart][:merchant_private_data][:order_number].strip.to_i)
        
        unless @order.allow_pay?       
          @order.update_attribute("user_id", current_user) if current_user
          
          checkout_info = params[:new_order_notification]
          checkout_attrs = {
            :email => checkout_info[:email],
            :ip_address => request.env['REMOTE_ADDR']         
          }        
          @order.checkout.update_attributes(checkout_attrs)
          
          order_attrs = {
            :adjustment_total => notification.order_adjustment.adjustment_total.cents.to_f / 100, 
            :buyer_id => notification.buyer_id,
            :financial_order_state => notification.financial_order_state, 
            :google_order_number =>  notification.google_order_number, 
            :gateway => "Google Checkout"
          }        
          @order.update_attributes(order_attrs)
          
          new_billing_address = 
            create_spree_address_from_google_address(notification.buyer_billing_address)
               
          @order.checkout.update_attribute(:bill_address_id,  new_billing_address.id)        
          
          new_shipping_address = 
            create_spree_address_from_google_address(notification.buyer_shipping_address)
                    
          @order.shipment.update_attribute(:address_id,  new_shipping_address.id)
          
          ship_method = ShippingMethod.find_by_name(notification.order_adjustment.shipping.name)      
          @order.shipment.update_attribute(:shipping_method, ship_method)
          
          @order.complete!
        end
        render :text => 'proccess Google4R::Checkout::NewOrderNotification' and return
      end
      
      if notification.is_a?(Google4R::Checkout::ChargeAmountNotification)
        @order = Order.find_by_google_order_number(notification.google_order_number)
        payment = Payment.new(:amount => notification.latest_charge_amount)
        payment.order = @order
        payment.save
        render :text => 'proccess Google4R::Checkout::ChargeAmountNotification' and return
      end
      
    rescue Google4R::Checkout::UnknownNotificationType => e
      # This can happen if Google adds new commands and Google4R has not been
      # upgraded yet. It is not fatal.
      render :text => 'ignoring unknown notification type', :status => 200 and return
    end
  end
 
  private
  def create_spree_address_from_google_address(google_address)
    address = Address.new
    address.country = Country.find_by_iso(google_address.country_code)
    address.state = State.find_by_abbr(google_address.region)
    address.state_name = google_address.region unless address.state
    
    address_attrs = {
      :firstname  =>  google_address.contact_name[/^\S+/],
      :lastname   =>  google_address.contact_name[/\s.*/],
      :address1   =>  google_address.address1, 
      :address2   =>  google_address.address2,
      :city       =>  google_address.city,
      :phone      =>  google_address.phone,
      :zipcode    =>  google_address.postal_code
    }
    address.attributes = address_attrs
    address.save(false)
    address  
  end

end

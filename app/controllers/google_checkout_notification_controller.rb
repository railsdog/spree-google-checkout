class GoogleCheckoutNotificationController < ApplicationController
protect_from_forgery :except => :create
  
  def create
    if (checkout_info = params[:new_order_notification])   #and not checkout_info[:coupon_code]
     @order = Order.find_by_id(params[:new_order_notification][:shopping_cart][:merchant_private_data][:order_number].strip.to_i)
     @order.update_attribute(:user, current_user) if current_user
      # overwrite any earlier guest checkout email if user has since logged in
      @order.checkout.update_attributes(:email => checkout_info[:email],:completed_at => Date.today)
      session[:order_id] = nil if @order.checkout.completed_at 
      # and set the ip_address to the most recent one
      @order.checkout.update_attribute(:ip_address, request.env['REMOTE_ADDR'])
      @order.update_attributes(:adjustment_total => checkout_info[:order_adjustment][:adjustment_total].to_f, :financial_order_state => checkout_info[:financial_order_state], :google_order_number =>  checkout_info[:google_order_number], :gateway => "Google Checkout", :state => checkout_info[:fulfillment_order_state] )
      new_billing_address = Address.new
      state = State.all.each{|s| s.abbr}
      if state.include?(checkout_info[:buyer_billing_address][:region])
        new_billing_address.state_id = State.find_by_abbr(checkout_info[:buyer_billing_address][:region]).id
      else
        new_billing_address.state_name = checkout_info[:buyer_billing_address][:region]
      end
      new_billing_address.firstname = checkout_info[:buyer_billing_address][:first_name]
      new_billing_address.lastname = checkout_info[:buyer_billing_address][:last_name]
      new_billing_address.zipcode = checkout_info[:buyer_billing_address][:postal_code]
      new_billing_address.country_id = Country.find_by_iso(checkout_info[:buyer_billing_address][:country_code])
      new_billing_address.address1 = checkout_info[:buyer_billing_address][:address1]
      new_billing_address.address2 = checkout_info[:buyer_billing_address][:address2] if checkout_info[:buyer_billing_address][:address2]
      new_billing_address.save(false)
      @order.checkout.update_attribute(:bill_address_id,  new_billing_address.id)
       new_shipping_address = Address.new
      state = State.all.each{|s| s.abbr}
      if state.include?(checkout_info[:buyer_shipping_address][:region])
        new_shipping_address.state_id = State.find_by_abbr(checkout_info[:buyer_shipping_address][:region]).id
      else
        new_shipping_address.state_name = checkout_info[:buyer_shipping_address][:region]
      end
      new_shipping_address.firstname = checkout_info[:buyer_shipping_address][:first_name]
      new_shipping_address.lastname = checkout_info[:buyer_shipping_address][:last_name]
      new_shipping_address.zipcode = checkout_info[:buyer_shipping_address][:postal_code]
      new_shipping_address.country_id = Country.find_by_iso(checkout_info[:buyer_shipping_address][:country_code])
      new_shipping_address.address1 = checkout_info[:buyer_shipping_address][:address1]
      new_shipping_address.address2 = checkout_info[:buyer_shipping_address][:address2] if checkout_info[:buyer_shipping_address][:address2]
      new_shipping_address.save(false)
      @order.shipment.update_attribute(:address_id,  new_shipping_address.id)
      @order.charges.create!(:description => checkout_info[:order_adjustment][:shipping][:flat_rate_shipping_adjustment][:shipping_name] , :secondary_type => "ShippingCharge", :amount => checkout_info[:order_adjustment][:shipping][:flat_rate_shipping_adjustment][:shipping_cost].to_f)
    end
  end  
      
      
#      # check whether the bill address has changed, and start a fresh record if 
#      # we were using the address stored in the current user.
#      if checkout_info[:buyer_billing_address] and @checkout.bill_address
#        # always include the id of the record we must write to - ajax can't refresh the form
#        checkout_info[:bill_address_attributes][:id] = @checkout.bill_address.id
#        new_address = Address.new checkout_info[:bill_address_attributes]
#        if not @checkout.bill_address.same_as?(new_address) and
#             current_user and @checkout.bill_address == current_user.bill_address
#          # need to start a new record, so replace the existing one with a blank
#          checkout_info[:bill_address_attributes].delete :id  
#          @checkout.bill_address = Address.new
#        end

#
#      # check whether the ship address has changed, and start a fresh record if 
#      # we were using the address stored in the current user.
#      if checkout_info[:shipment_attributes][:address_attributes] and @order.shipment.address
#        # always include the id of the record we must write to - ajax can't refresh the form
#        checkout_info[:shipment_attributes][:address_attributes][:id] = @order.shipment.address.id
#        new_address = Address.new checkout_info[:shipment_attributes][:address_attributes]
#        if not @order.shipment.address.same_as?(new_address) and 
#             current_user and @order.shipment.address == current_user.ship_address 
#          # need to start a new record, so replace the existing one with a blank
#          checkout_info[:shipment_attributes][:address_attributes].delete :id
#          @order.shipment.address = Address.new
#        end
#      end
#
#    end
#end
#
#
# Parameters: {"action"=>"google_checkout_feedback", "new_order_notification"=>{"serial_number"=>"[FILTERED]", 
#"financial_order_state"=>"REVIEWING", "timestamp"=>"2009-09-22T07:04:58.229Z", "google_order_number"=>"[FILTERED]",
# "buyer_marketing_preferences"=>{"email_allowed"=>"true"}, "buyer_id"=>"950467314846239", 
#"shopping_cart"=>{"items"=>{"item"=>{"quantity"=>"1", "unit_price"=>"0.17", 
#"item_description"=>"Lorem ipsum dolor sit amet, consectetuer adipiscing elit.
# Nulla nonummy aliquet mi. Proin lacus. Ut placerat. Proin consequat, justo sit amet tempus consequat,
# elit est adipiscing odio, ut egestas pede eros in diam. Proin varius, lacus vitae suscipit varius, 
#ipsum eros convallis nisi, sit amet so...", "item_name"=>"\nRuby on Rails Stein\n"}}},
# "buyer_billing_address"=>{"region"=>"MAHARASHTRA", "city"=>"kalyan,dist.thane", 
#"address1"=>"C-5/406,greenland apt,yogidham", "address2"=>"complex", "contact_name"=>"prakash sejwani",
# "country_code"=>"IN", "company_name"=>nil, "postal_code"=>"421301", "fax"=>nil, 
#"phone"=>nil, "email"=>"prakashsejwani@rediff.com"}, "buyer_shipping_address"=>{"region"=>"FL", "city"=>"Miami", 
#"address1"=>"3555 S W Eighth Street", "address2"=>nil, "contact_name"=>"prakash", "country_code"=>"US",
# "company_name"=>nil, "postal_code"=>"33135", "fax"=>nil, "phone"=>nil, "email"=>"prakashsejwani@rediff.com"},
# "order_total"=>"50.17", "fulfillment_order_state"=>"NEW", "order_adjustment"=>{"adjustment_total"=>"50.0",
# "shipping"=>{"flat_rate_shipping_adjustment"=>{"shipping_name"=>"UPS Standard 3 Day", "shipping_cost"=>"50.0"}},
# "merchant_codes"=>nil, "total_tax"=>"0.0"}, "xmlns"=>"http://checkout.google.com/schema/2"}, 
#"controller"=>"orders"}


#  def google_checkout_feedback
#     @gateway = Gateway.find_by_clazz "Google4R::Checkout::Frontend"
#    @gw = GatewayConfiguration.find_by_gateway_id(@gateway.id)
#  if @gw.present? && @gw.gateway_option_values[0].value.present? && @gw.gateway_option_values[1].value.present?
#    configuration = { :merchant_id =>@gw.gateway_option_values[0].value, :merchant_key => @gw.gateway_option_values[1].value, :use_sandbox => true }
#    frontend = Google4R::Checkout::Frontend.new(configuration)
#    frontend.tax_table_factory = TaxTableFactory.new
#   handler = frontend.create_notification_handler
#  
#         # puts "====#{new-order-notification}"
#   
#     begin
#       notification = handler.handle(request.raw_post) # raw_post contains the XML
#       # puts "==============#{notification}"
#     rescue Google4R::Checkout::UnknownNotificationType => e
#       # This can happen if Google adds new commands and Google4R has not been
#       # upgraded yet. It is not fatal.
#       render :text => 'ignoring unknown notification type', :status => 200
#       return
#     end
#      notification_acknowledgement = Google4R::Checkout::NotificationAcknowledgement.new.to_xml
#    render :text => notification_acknowledgement, :status => 200
# end
#  end

end
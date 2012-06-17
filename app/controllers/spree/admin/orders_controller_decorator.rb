module Spree
  module Admin
    OrdersController.class_eval do
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
            
            payment = Payment.new(:amount => o.total, :payment_method_id => Billing::GoogleCheckout.current.id)
            payment.order = o
            payment.save
            payment.started_processing
            payment.complete
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
  end
end

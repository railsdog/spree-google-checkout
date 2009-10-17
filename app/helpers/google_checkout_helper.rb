module GoogleCheckoutHelper

  def google_checkout_button(merchant_id)    
    img_src = Billing::GoogleCheckout.current[:use_sandbox] ?
      "http://sandbox.google.com/checkout/buttons/checkout.gif" :
      "https://checkout.google.com/buttons/checkout.gif"
    params_hash = {:merchant_id => merchant_id,  
              :w => 180, :h => 46, :style => "white",
              :variant => "text", :loc => "en_US" }
    params_str = params_hash.to_a.inject([]){|arr, p| arr << p.join('=')}.join('&')
    
    
    image_submit_tag( [img_src, params_str].join('?'), 
        :name => "Google Checkout", 
        :alt => "Fast checkout through Google",
        :height => 46, :width => 180 )
  end

end

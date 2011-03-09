class SpreeGoogleCheckoutHooks < Spree::ThemeSupport::HookListener
  insert_after :outside_cart_form, 'shared/google_checkout_bar'
end

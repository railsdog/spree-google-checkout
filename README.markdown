Google Checkout
==================

### Installation

1. Add `gem 'spree_google_checkout', :git => "git://github.com/railsdog/spree-google-checkout.git"` to Gemfile
1. Run `rake spree_google_checkout:install`
1. Run `rake db:migrate`
1. Create seller account in Google Checkout
1. Open `https://sandbox.google.com/checkout/sell/settings?section=Integration` 
or `https://checkout.google.com/sell/settings?section=Integration`
1. remember your merchant ID and merchant key
1. set 'API callback URL' to `https://your.spree.site/google_checkout_notification`
1. select 'Notification as XML'
1. Create a billing integration using `http://your.spree.site/admin/payment_methods` and set the merchant ID, etc.
1. Set `Spree::Config[:allow_ssl_in_production]` to true


### Usage

* After filling your gateway settings, users can place order through Google Checkout.
* After placing order through Google Checkout, you can charge it or cancel it from Spree admin-panel.

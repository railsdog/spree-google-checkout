Google Checkout
==================

### Installation

1. Run `script/extension install git://github.com/romul/spree-google-checkout.git`
1. Run `db:migrate`
1. Create seller account in Google Checkout
1. Open `https://sandbox.google.com/checkout/sell/settings?section=Integration` 
or `https://checkout.google.com/sell/settings?section=Integration`
  1. remember your merchant ID and merchant key
  1. set 'API callback URL' to `http://your.spree.site/google_checkout_notification`
  1. select 'Notification as XML'
1. Open `http://your.spree.site/admin/gateway_configurations/1/edit`
  1. choose 'Google checkout' gateway
  1. fill options
1. If you want not use Google Sandbox, you should call `Spree::Config.set(:use_google_sandbox => false)` in your site-extension


### Usage

* After filling your gateway settings, users can place order through Google Checkout.
* After placing order through Google Checkout, you can charge it or cancel it from Spree admin-panel.

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
1. Create a billing integration using `http://your.spree.site/admin/billing_configurations` and set the merchant ID, etc.


### Usage

* After filling your gateway settings, users can place order through Google Checkout.
* After placing order through Google Checkout, you can charge it or cancel it from Spree admin-panel.

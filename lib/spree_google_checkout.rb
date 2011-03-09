require 'google4r/checkout'
require 'hmac-sha1'
require 'spree_core'
require 'spree_google_checkout_hooks'

module SpreeGoogleCheckout
  class Engine < Rails::Engine

    config.autoload_paths += %W(#{config.root}/lib)

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), "../app/**/*_decorator*.rb")) do |c|
        Rails.env.production? ? require(c) : load(c)
      end
      # register the BillingIntegration
      Billing::GoogleCheckout.register
    end

    config.to_prepare &method(:activate).to_proc
  end
end

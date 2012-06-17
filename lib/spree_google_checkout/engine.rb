module SpreeGoogleCheckout
  class Engine < Rails::Engine
    require 'google4r/checkout'
    require 'hmac-sha1'
    require 'spree_core'

    engine_name 'spree_google_checkout'

    config.autoload_paths += %W(#{config.root}/lib)

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), "../../app/**/*_decorator*.rb")) do |c|
        Rails.env.production? ? require(c) : load(c)
      end
    end

    config.to_prepare &method(:activate).to_proc

    initializer "spree.google_checkout.register.calculators" do |app|
      app.config.spree.payment_methods += [
                                           Spree::Billing::GoogleCheckout
                                          ]
    end
  end
end

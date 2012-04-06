Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_google_checkout'
  s.version     = '0.40.0'
  s.summary     = 'Google Checkout extension for Spree'
  #s.description = 'Add (optional) gem description here'
  s.required_ruby_version = '>= 1.8.7'

   s.author            = 'David Heinemeier Hansson'
  # s.email             = 'david@loudthinking.com'
  # s.homepage          = 'http://www.rubyonrails.org'
  # s.rubyforge_project = 'actionmailer'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.has_rdoc = true

  s.add_dependency('spree_core', '>= 0.50.0')
  s.add_dependency('oauth', '>= 0.4.4')
  s.add_dependency('google4r-checkout', '>= 1.1.1')
  s.add_dependency('ruby-hmac', '>= 0.3.2')
  s.add_dependency('money', '<= 3.7.1')
  
end

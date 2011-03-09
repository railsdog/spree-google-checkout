Spree::BaseHelper.module_eval do
  def signature(base_string, consumer_secret)
    secret="#{escape(consumer_secret)}"
    Base64.encode64(HMAC::SHA1.digest(secret,base_string)).chomp.gsub(/\n/,'')
  end
  def escape(value)
    CGI.escape(value.to_s).gsub("%7E", '~').gsub("+", "%20")
  end 
end

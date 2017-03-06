class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def data
    {}
  end

  def xml_payload
    payload = Builder::XmlMarkup.new.PaymentRequest do |payment_request|
      data.each do |key, value|
        payment_request.tag!(key, value)
      end

      payment_request.tag!('secureHash', secure_hash)
    end

    payload
  end

  def secure_hash
    value = data.values.join

    key = ENV['TWOCTWOP_SECRET_KEY', '']
    digest = OpenSSL::Digest.new('SHA1')
    secure_hash = OpenSSL::HMAC.hexdigest(digest, key, value).upcase

    secure_hash
  end

  def base64_encode(payload)
    Base64.strict_encode64(payload)
  end
end

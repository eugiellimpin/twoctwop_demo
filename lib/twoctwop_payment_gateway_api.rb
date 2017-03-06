module TwoctwopPaymentGatewayApi
  class Request

    def initialize(steps=[])
      @steps = steps
    end

    def execute
      step = next_step

      while step
        response = step.execute

        break if step.has_payment_response?
        break if @steps.empty?

        step = next_step.prepare(response)
      end

      step.try(:payment_response)
    end

    private

    def next_step
      @steps.shift
    end
  end

  class RequestStep
    Error = Class.new(StandardError)

    include HTTParty

    @@cookie_jar = {}

    attr_reader :url, :payload, :payment_response

    def initialize(options={})
      @url      = options.fetch(:url, nil)
      @payload  = options.fetch(:payload, nil)
      @details  = options.fetch(:details, nil)
    end

    def execute
      check_for_payment_response(post)
    end

    def prepare(response)
      html = Nokogiri::HTML(response.body)

      begin
        unless @url
          form_id = @details[:form_id]
          @url = html.css("##{form_id}").first['action'] if form_id
        end

        unless @payload
          input_id = @details[:input_id]
          @payload = { input_id => html.css("##{input_id}").first['value'] } if input_id
        end
      rescue NoMethodError => e
        raise Error.new("Could not find required information for next request")
      end

      self
    end

    def has_payment_response?
      @payment_response.present?
    end

    private

    def post
      puts "========================= START ========================="
      puts "sending request to #{@url}"
      puts "=========================  END  ========================="

      @response = self.class.post(@url, body: @payload, headers: { 'Cookie' => cookies })
      store_cookies(@response.headers['Set-Cookie'])
      @response
    end

    def cookies
      @@cookie_jar.fetch(host, CookieHash.new).to_cookie_string
    end

    def store_cookies(new_cookies)
      if new_cookies.present?
        @@cookie_jar[host] ||= CookieHash.new
        @@cookie_jar[host].add_cookies(new_cookies)
      end
    end

    def host
      @host ||= URI.parse(@url).host
    end

    def check_for_payment_response(response)
      html = Nokogiri::HTML(response.body)

      if (payment_response_el = html.css("#paymentResponse")).present?
        @payment_response = payment_response_el.first['value']
      end

      response
    end
  end
end

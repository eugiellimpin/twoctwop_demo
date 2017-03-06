class OfflinePaymentController < ApplicationController
  TWOCWOP_ENDPOINT     = 'https://demo2.2c2p.com/2C2PFrontEnd'
  ONETWOTHREE_ENDPOINT = 'http://uat.satuduatiga.co.id'

  def checkout
  end

  def pay
    @payload = xml_payload
    @payload = base64_encode(@payload)

    payment_response = request_payment(@payload)
    render text: "#{payment_response}", status: 200
  end

  private

  def request_payment(payload)
    steps = [
      { url: "#{TWOCWOP_ENDPOINT}/SecurePayment/PaymentAuth.aspx", payload: { "paymentRequest" => payload } },
      { details: { form_id:  'paymentRequestForm', input_id: 'paymentRequest' } },
      { details: { form_id:  'ReqForm123', input_id: 'OneTwoThreeReq' } },
      { url: "#{ONETWOTHREE_ENDPOINT}/Payment/paywith123.aspx", payload: { "btnGoBack" => '' } },
      { details: { form_id:  'PostForm', input_id: 'OneTwoThreeRes' } }
    ].map { |options| ::TwoctwopPaymentGatewayApi::RequestStep.new(options) }

    payment_request = ::TwoctwopPaymentGatewayApi::Request.new(steps)
    payment_response = payment_request.execute
  end

  def data
    {
      version:                '9.3',
      merchantID:             ENV['TWOCTWOP_MERCHANT_ID'],
      uniqueTransactionCode:  Time.now.strftime('%y%m%d%H%M%S'),
      desc:                   "No UI test #{Time.now.strftime('%H:%M:%S')}",
      amt:                    '000079000000',
      currencyCode:           360,
      paymentChannel:         '123',
      cardholderName:         params['payer_name'],
      cardholderEmail:        params['payer_email'],
      agentCode:              'CIMBVA',
      channelCode:            'ATM',
      mobileNo:               params['payer_mobile_number']
    }
  end
end
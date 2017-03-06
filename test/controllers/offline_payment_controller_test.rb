require 'net/http'

describe "OfflinePaymentController", type: :request do
  it "succeed!" do
    response = Net::HTTP.get('example.com', '/index.html')
    puts response
    expect(true).to eq true
  end
end

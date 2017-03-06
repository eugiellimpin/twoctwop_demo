require 'test_helper'

class CreditCardPaymentControllerTest < ActionController::TestCase
  test "should get checkout" do
    get :checkout
    assert_response :success
  end

  test "should get pay" do
    get :pay
    assert_response :success
  end

end

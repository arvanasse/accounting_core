require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ReceiptDetail do
  before(:each) do
    @valid_attributes = {
      :receipt => mock_model(Receipt, 'open?'=>true),
      :payment_instrument => mock_model(PaymentInstrument),
      :amount => "9.99",
      :reference_number => "1"
    }
  end

  it "should create a new instance given valid attributes" do
    ReceiptDetail.create!(@valid_attributes)
  end
end

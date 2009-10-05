require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe InvoiceLine do
  before(:each) do
    @valid_attributes = {
      :invoice => mock_model(Invoice, 'closed?'=>false),
      :name => "value for name",
      :posted_on => Date.today, 
      :amount => 0.00
    }
  end

  it "should create a new instance given valid attributes" do
    lambda{InvoiceLine.create(@valid_attributes)}.should change(InvoiceLine, :count).by(1)
  end
  
  [:name, :amount].each do |required_attr|
    it "should require a(n) #{required_attr}" do
      @valid_attributes.delete required_attr
      lambda{InvoiceLine.create(@valid_attributes)}.should_not change(InvoiceLine, :count)
    end
  end
  
  it "should not be able to post to a closed invoice" do
    @valid_attributes[:invoice] = mock_model(Invoice, 'closed?'=>true)
    lambda{InvoiceLine.create(@valid_attributes)}.should_not change(InvoiceLine, :count)
  end
  
  it "should require the amount to be non-negative" do
    @valid_attributes[:amount] = 0.01
    lambda{InvoiceLine.create(@valid_attributes)}.should change(InvoiceLine, :count).by(1)
    @valid_attributes[:amount] = -0.01
    lambda{InvoiceLine.create(@valid_attributes)}.should_not change(InvoiceLine, :count)
  end
end

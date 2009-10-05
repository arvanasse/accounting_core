require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe JournalDetail do
  before(:each) do
    @valid_attributes = {
      :journal_entry => mock_model(JournalEntry, 'details_adjusted!'=>true),
      :amount => "9.99",
      :balance_type => "value for balance_type",
      :account => mock_model(SubledgerAccount)
    }
  end

  it "should create a new instance given valid attributes" do
    lambda{JournalDetail.create(@valid_attributes)}.should change(JournalDetail, :count).by(1)
  end
  
  [:journal_entry, :amount, :balance_type, :account].each do |required_attr|
    it "should require a #{required_attr.to_s.humanize}" do
      @valid_attributes.delete required_attr
      lambda{JournalDetail.create(@valid_attributes)}.should_not change(JournalDetail, :count)
    end
  end
  
  it "should require the amount to be non-negative" do
    @valid_attributes[:amount] = BigDecimal.new("-13.23")
    lambda{JournalDetail.create(@valid_attributes)}.should_not change(JournalDetail, :count)
  end
end

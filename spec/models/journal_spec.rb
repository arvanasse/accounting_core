require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "a journal", :shared=>true do
  it "should create a new instance given valid attributes" do
    lambda{Journal.create(@valid_attributes)}.should change(Journal, :count).by(1)
  end
  
  [:name, :general_ledger].each do |required_attr|
    it "should require a #{required_attr}" do
      @valid_attributes.delete(required_attr)
      lambda{Journal.create(@valid_attributes)}.should_not change(Journal, :count)
    end
  end
end

describe Journal do
  before(:each) do
    @valid_attributes = {
      :general_ledger => mock_model(GeneralLedger),
      :name => "Test Journal",
      :journal_type => "SomeJournal"
    }
  end
  
  it "should not permit a generic joural" do
    @valid_attributes.delete(:journal_type)
      lambda{Journal.create(@valid_attributes)}.should_not change(Journal, :count)
  end
end

[SalesJournal, CashReceiptsJournal].each do |journal_class|
  describe journal_class do
    before(:each) do
      @valid_attributes = {
        :general_ledger => mock_model(GeneralLedger),
        :name => "Test #{journal_class.name.underscore.humanize}", 
        :journal_type => journal_class.name}
    end

    it_should_behave_like "a journal"
  end
end
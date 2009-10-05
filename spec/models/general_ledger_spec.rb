require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe GeneralLedger do
  before(:each) do
    @valid_attributes = {
      :name => "Test Ledger"
    }
  end

  it "should create a new instance given valid attributes" do
    lambda{GeneralLedger.create!(@valid_attributes)}.should change(GeneralLedger, :count).by(1)
  end
  
  describe 'after creation' do
    before(:each) do
      @gl = GeneralLedger.create(@valid_attributes)
    end
    
    %w{CashReceiptsJournal SalesJournal}.each do |journal_type|
      it "should create a #{journal_type.underscore.humanize} upon creation" do
        @gl.journals.find_all_by_journal_type(journal_type).size.should eql(1)
      end
    end

    %w{Cash AccountsReceivable AccountsPayable SalesRevenue}.each do |account_type|
      it "should create a #{account_type.underscore.humanize} upon creation" do
        @gl.ledger_accounts.find_all_by_ledger_type(account_type).size.should eql(1)
      end
    end
    
    it "should use it's uuid as its url id" do
      @gl.to_param.should eql(@gl.uuid)
    end

    it "should generate a uuid upon creation for cross-site identification" do
      @gl.uuid.should_not be_nil
    end
  end
end

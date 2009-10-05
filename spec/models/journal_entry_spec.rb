require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'transaction_detail'

describe JournalEntry do
  before(:each) do
    @valid_attributes = {
      :journal => mock_model(Journal),
      :description => "value for description"
    }
  end

  it "should create a new instance given valid attributes" do
    lambda{JournalEntry.create(@valid_attributes)}.should change(JournalEntry, :count).by(1)
  end
  
  [:journal, :description].each do |required_attr|
    it "should require a #{required_attr}" do
      @valid_attributes.delete required_attr
      lambda{JournalEntry.create(@valid_attributes)}.should_not change(JournalEntry, :count)
    end
  end
  
  it "should enter the pending state upon creation" do
    @entry = JournalEntry.create(@valid_attributes)
    @entry.aasm_current_state.should eql(:pending)
  end
  
  describe "in the pending state" do
    before(:each) do
      @entry = JournalEntry.create(@valid_attributes)
      @entry.should_not be_new_record
      @entry.should be_pending
    end
    
    it "should be able to add details to the entry" do
      lambda{
        5.times{ add_detail(@entry, Debit.new(100), SubledgerAccount) }
      }.should change(JournalDetail, :count).by(5)
      @entry.should have(5).journal_details
    end
    
    it "should transition to unbalanced when a non-zero detail is added" do
      lambda{
        add_detail(@entry, Debit.new(100), SubledgerAccount)
      }.should change(@entry, :aasm_current_state).from(:pending).to(:unbalanced)
    end
    
    it "should raise an error if posted" do
      lambda{@entry.post!}.should raise_error(AASM::InvalidTransition)
    end
  end
  
  describe "in the unbalanced state" do
    before(:each) do
      @entry = JournalEntry.create(@valid_attributes)
      add_detail(@entry, Debit.new(100), SubledgerAccount)
      @entry.should be_unbalanced
    end
    
    it "should remain unbalanced if journal details are added that does not bring the balance to 0" do
      lambda{
        add_detail(@entry, Debit.new(100), SubledgerAccount)
      }.should_not change(@entry, :aasm_current_state)
      
      lambda{
        add_detail(@entry, Credit.new(199.99), LedgerAccount)
      }.should_not change(@entry, :aasm_current_state)
    end
    
    it "should become balanced if a journal detail is added that brings it into balance" do
      lambda{ add_detail(@entry, Credit.new(100), LedgerAccount) }.should change(@entry, :aasm_current_state).from(:unbalanced).to(:balanced)
    end
    
    it "should raise an error if posted" do
      lambda{@entry.post!}.should raise_error(AASM::InvalidTransition)
    end
  end
  
  describe "in the balanced state" do
    fixtures :general_ledgers, :journals, :ledger_accounts, :subledger_accounts
    before(:each) do
      @entry = JournalEntry.create(
        :journal=>journals(:koinonia_sales), 
        :description=>"#{Date.today.strftime('%B %Y')} Services"
      )
      @entry.journal_details.create :transaction_detail=>Debit.new(100), :account=>subledger_accounts(:vanasse_family)
      @entry.journal_details.create :transaction_detail=>Credit.new(100), :account=>ledger_accounts(:koinonia_sales)
      @entry.reload # reload this because the record is updated in the background by an observer
      @entry.should be_balanced
    end
    
    it "should be able to be posted" do
      lambda{
        @entry.post!
        @entry.reload
      }.should change(@entry, :aasm_current_state).from(:balanced).to(:posted)
    end
    
    it "should transition to unbalanced if any non-zero journal detail is added" do
      lambda{add_detail(@entry, Debit.new(100), SubledgerAccount)}.should change(@entry,:aasm_current_state)
    end
    
    [LedgerEntry, SubledgerEntry].each do |effected_entry_class|
      it "should create a #{effected_entry_class.name.humanize} if its corresponding account is in the entry" do
        lambda{@entry.post!}.should change(effected_entry_class, :count).by(1)
      end
    end
  end
  
  def add_detail(entry, transaction_detail, account_class)
    entry.journal_details.create :transaction_detail=>transaction_detail, :account=>mock_model(LedgerAccount)
    entry.reload
  end
end

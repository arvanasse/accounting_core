require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "an account entry", :shared=>true do
  it "should create a new instance given valid attributes" do
    lambda{@entry_class.create!(@valid_attributes)}.should change(@entry_class, :count).by(1)
  end

  it "should require an amount" do
    @entry = @entry_class.new(@valid_attributes.merge(:transaction_detail=>Debit.new(nil)))
    @entry.should_not be_valid
    @entry.should have_at_least(1).error_on(:amount)
  end

  it "should not allow a negative amount in the transaction detail" do
    @entry = @entry_class.new(@valid_attributes.merge(:transaction_detail=>Debit.new(-50.0)))
    @entry.should_not be_valid
    @entry.should have_at_least(1).error_on(:amount)
  end

  it "should default the recorded_on date if not supplied" do
    @entry = @entry_class.create!(@valid_attributes)
    @entry.recorded_on.should eql(Date.today)
  end

  it "should allow the user to specify the recorded_on date" do
    yesterday = Date.yesterday
    @entry = @entry_class.create!(@valid_attributes.merge(:recorded_on => yesterday))
    @entry.recorded_on.should eql(yesterday)
  end

  it "should default the posting date when posted" do
    @entry = @entry_class.create!(@valid_attributes)
    @entry.post!
    @entry.posted_on.should eql(Date.today)
  end
end
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "an account with entries", :shared=>true do
  [Debit, Credit].each do |balance_type|
    describe "initialized with an opening #{balance_type} balance" do
      before(:each) do
        @valid_attributes[:opening_balance] = balance_type.new(100)
      end

      it "should create a new instance given valid attributes" do
        lambda{@account_class.create!(@valid_attributes)}.should change(@account_class, :count).by(1)
      end
      
      it "should generate a uuid upon creation" do
        @account = @account_class.new @valid_attributes
        @account.uuid.should be_nil
        @account.save
        @account.uuid.should_not be_nil
      end
      
      [:opening_amount, :opening_balance_type].each do |required_attr|
        it "should require #{required_attr}" do
          @account = @account_class.new @valid_attributes
          @account.send "#{required_attr}=", nil
          lambda{@account.save}.should_not change(@account_class, :count)
        end
      end
    end
  end
  
  [Debit, Credit].each do |opening_balance_type|
    describe "created with an opening #{opening_balance_type.name.downcase} of $100" do
      before(:each) do
        @valid_attributes[:opening_balance] = opening_balance_type.new(100)
        @account = @account_class.create(@valid_attributes)
        @account.should be_valid
        @account.should_not be_new_record
      end

      [:debit, :credit].each do |transaction_type|
        describe "and #{transaction_type}ed five times" do
          before(:each) do
            @transaction_total = 0.0
            5.times{
              amount = rand(10)
              @account.send(transaction_type, amount)
              @transaction_total += amount
            }
          end

          it "should have five #{transaction_type}s" do
            @account.should have(5).entries
            # Check that the entries have the correct transaction type
            @account.entries.unposted.select{|entry| entry.transaction_detail.send("#{transaction_type}?")}.size.should eql(5)
          end

          it "should have a debit balance that has changed by the sum of the #{transaction_type}s" do
            balance = opening_balance_type.new(100).send(transaction_type, @transaction_total)
            @account.current_balance.should ==  balance
          end
        end
      end

      it "should change balance types if the #{opening_balance_type.name=='Debit' ? 'credits' : 'debits'} exceed the opening #{opening_balance_type.name} balance" do
        trans_type = opening_balance_type.name=='Debit' ? 'credit' : 'debit'
        @account.send(trans_type, 125.0)
        @account.should have(1).entry
        @account.current_balance.should == trans_type.classify.constantize.new(25.0)
      end

      it "should report a balance that is a 100 #{opening_balance_type.name.downcase} over the net of debits and credits" do
        net_change = Debit.new(0.0)
        5.times do
          transaction_detail = create_transaction_detail
          net_change = net_change.send(transaction_detail.balance_type, transaction_detail.amount)
          @account.send(transaction_detail.balance_type, transaction_detail.amount)
        end
        expected_balance = opening_balance_type.new(100).send(net_change.balance_type, net_change.amount)
        @account.current_balance.should == expected_balance
      end
    end
  end
  
  describe "with a mix of posted and unposted entries" do
    before(:each) do
      @valid_attributes[:opening_balance] = Debit.new(100)
      @account = @account_class.create(@valid_attributes)
      # Create five posted entries
      5.times{
        transaction_detail = create_transaction_detail
        @account.send(transaction_detail.balance_type, transaction_detail.amount)
      }
      @account.entries.map(&:post!)
      # Create five unposted entries
      5.times{
        transaction_detail = create_transaction_detail
        @account.send(transaction_detail.balance_type, transaction_detail.amount)
      }
    end
    
    it "should be able to distinguish between posted and unposted entries" do
      @account.should have(10).entries
      @account.entries.unposted.size.should eql(5)
    end
    
    it "should calculate the current balance based only on unposted entries" do
      expected =  @account.entries.unposted.inject(Debit.new(100)){|bal, entry| bal.send(entry.balance_type, entry.amount)}
      @account.current_balance.should == expected
    end
  end
  
  def create_transaction_detail
    Debit.new(50).credit(rand(100))
  end
end
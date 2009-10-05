require 'transaction_detail'
module AccountBehavior
    class << self
      def included(receiver)
        receiver.class_eval do
          composed_of :opening_balance, 
                      :class_name => 'TransactionDetail',
                      :mapping=>[%w{opening_amount amount}, %w{opening_balance_type balance_type}]
          composed_of :reconciled_balance, 
                      :class_name => 'TransactionDetail',
                      :mapping=>[%w{reconciled_amount amount}, %w{reconciled_balance_type balance_type}]
        
          validates_numericality_of :opening_amount, :reconciled_amount, :greater_than_or_equal_to=>0
          validates_presence_of     :opening_balance_type, :reconciled_balance_type

          before_validation_on_create :default_reconciled_balance, :generate_uuid
        end
      end
    end
            
    def debit(amount, options={})
      options[:transaction_detail] = Debit.new(amount)
      entries.create(options) if self.respond_to?(:entries)
    end

    def credit(amount, options={})
      options[:transaction_detail] = Credit.new(amount)
      entries.create(options) if self.respond_to?(:entries)
    end
    
    def current_balance
      original_balance = reconciled_balance || Debit.new(0)
      original_balance.send unposted_balance.balance_type, unposted_balance.amount
    end

    def unposted_balance
      credit_balance = entries.unposted.credits.sum(:amount) || 0.0
      debit_balance = entries.unposted.debits.sum(:amount) || 0.0
      Debit.new(debit_balance).credit(credit_balance)
    end
      
    protected
    def default_reconciled_balance
      self.reconciled_balance = self.opening_balance
      self.reconciled_on = Date.today
    end

    def generate_uuid
      write_attribute(:uuid, UUID.timestamp_create.to_s)
    end
  end

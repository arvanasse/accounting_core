  class TransactionDetail
    include Comparable
    attr_reader :balance_type
    attr_accessor :amount

    def initialize(amount=0, balance_type='debit')
      @amount = amount
      @balance_type = balance_type.to_s
    end
    
    def debit?
      @balance_type=='debit'
    end
    
    def credit?
      @balance_type=='credit'
    end
    
    def <=>(other)
      raise ArgumentError unless other.is_a?(TransactionDetail)
      case
      when self.debit?
        return 1 if other.credit?
      when self.credit?
        return -1 if other.debit?
      end
      @amount<=>other.amount
    end
  end
  
  class Debit < TransactionDetail    
    def initialize(amount=0)
      super amount, :debit
    end
    
    def debit(amount)
      Debit.new(amount+@amount)
    end
    
    def credit(amount)
      if amount>@amount
        Credit.new(amount-@amount)
      else
        Debit.new(@amount-amount)
      end
    end
    
    def to_s
      "#{@amount} DR"
    end
  end
  
  class Credit < TransactionDetail
    def initialize(amount=0)
      super amount, :credit
    end
    
    def debit(amount)
      if amount<@amount
        Credit.new(@amount-amount)
      else
        Debit.new(amount-@amount)
      end
    end
    
    def credit(amount)
      Credit.new(@amount+amount)
    end
    
    def to_s
      "#{@amount} CR"
    end
  end
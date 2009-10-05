class SubledgerAccount < ActiveRecord::Base
  include AccountBehavior
  class << self
    def post_summary_for(ledger_account)
      if subledgers = ledger_account.respond_to?(:subledger_accounts)
        summary_balance = subledgers.inject(Debit.new(0.0)) do |running_total, subledger_account|
          summary_transaction = subledger_account.post_entries
          running_total.send(summary_transaction.transaction_detail.balance_type, summary_transaction.transaction_detail.balance)
        end
        ledger_account.send(summary_balance.transaction_detail.balance_type, summary_balance.transaction_detail.balance)
      end
    end
  end
  
  belongs_to  :accountable, :polymorphic=>true
  belongs_to  :ledger_account
  has_one     :general_ledger, :through=>:ledger_account

  has_many    :entries, :class_name => 'SubledgerEntry'
  
  has_many    :invoices
  has_many    :receipts
  
  validates_numericality_of :ledger_account_id, :only_integer=>true, :greater_than=>0, :message=>"must be supplied"
  
  def to_param
    self.uuid
  end
  
  def post_entries
    change_in_balance = unposted_balance
    entries.unposted.each{|entry| entry.post!} if update_attributes(:reconciled_balance=>current_balance, :reconciled_on=>Date.today)
    return change_in_balance
  end
end

class LedgerEntry < ActiveRecord::Base  
  include AccountEntryBehavior
  
  belongs_to  :ledger_account
  validates_numericality_of :ledger_account_id, :only_integer=>true, :greater_than=>0, :message=>"must be supplied"
end

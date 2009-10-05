class LedgerAccount < ActiveRecord::Base
  include AccountBehavior
  
  belongs_to  :general_ledger
  
  has_many    :entries, :class_name => 'LedgerEntry'
  has_many    :subledger_accounts

  validates_numericality_of :general_ledger_id, :only_integer=>true, :greater_than=>0, :message=>"must be supplied"
  validates_presence_of     :ledger_type, :account_number, :name
  
  def to_param
    self.uuid
  end
end

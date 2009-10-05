require 'transaction_detail'
class JournalDetail < ActiveRecord::Base
  belongs_to :journal_entry
  belongs_to :account, :polymorphic=>true

  validates_numericality_of :amount, :greater_than_or_equal_to=>0, :message=>"must be greater than or equal to 0.00"
  validates_numericality_of :journal_entry_id, :account_id, :greater_than=>0, :only_integer=>true, :message=>"must be provided"
  validates_presence_of     :account_type, :balance_type

  composed_of :transaction_detail, :mapping=>[%w{amount amount}, %w{balance_type balance_type}]
end

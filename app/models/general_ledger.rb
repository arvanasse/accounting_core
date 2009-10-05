require 'journal'
require 'ledger_account'

class GeneralLedger < ActiveRecord::Base
  has_many :ledger_accounts
  has_many :journals
  
  before_validation_on_create :generate_uuid
  after_create :generate_journals_and_accounts
  
  # Use the unique but unpredictable uuid as a url 'id'
  def to_param
    self.uuid
  end
  
  private
  def generate_uuid
    write_attribute(:uuid, UUID.timestamp_create().to_s)
  end
  
  def generate_journals_and_accounts
    CashReceiptsJournal.create  :general_ledger_id => self.id, :name=> "#{name} Cash Receipts"
    SalesJournal.create         :general_ledger_id => self.id, :name=> "#{name} Billing"

    account_defaults = {:general_ledger_id=>self.id, :opening_balance=>Debit.new(0), :reconciled_balance=>Debit.new(0)}
    {"Cash"=>100, "AccountsReceivable"=>200, "AccountsPayable"=>1200, "SalesRevenue"=>1300}.each do |ledger_type, account_number|
      acct = LedgerAccount.create({:account_number=> account_number, :ledger_type=>ledger_type, :name=>ledger_type.underscore.humanize}.merge(account_defaults))
      logger.debug acct.errors.full_messages.to_sentence unless acct.valid?
    end
  end
end

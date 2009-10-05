class JournalEntry < ActiveRecord::Base
  @@zero_balance = Debit.new(0)
  
  belongs_to  :journal
  has_many    :journal_details
  
  belongs_to  :void_for,  :class_name=>'JournalEntry'
  has_one     :voided_by, :class_name=>'JournalEntry', :foreign_key=>:void_for_id
  
  validates_numericality_of :journal_id, :only_integer=>:true, :greater_than=>0, :message=>'must be provided'
  validates_presence_of     :description
  
  composed_of :transaction_detail, :mapping=>[%w{amount amount}, %w{balance_type balance_type}]

  include AASM
  aasm_column :state
  aasm_initial_state :pending
    aasm_state :pending
    aasm_state :unbalanced
    aasm_state :balanced
    aasm_state :posted, :enter=>:post_details_to_accounts
    aasm_state :voided, :enter=>:record_void
    
  aasm_event :details_adjusted do
    transitions :to=>:balanced,   :from=>[:pending, :unbalanced, :balanced], :guard=>:in_balance?
    transitions :to=>:unbalanced, :from=>[:pending, :unbalanced, :balanced]
  end
  
  aasm_event :post do
    transitions :to=>:posted, :from=>[:balanced]
  end
  
  aasm_event :void do
    transitions :to=>:voided, 
                :from=>[:pending, :unbalanced, :balanced, :posted], 
                :guard=>lambda{|entry| entry.voided_by.nil? and entry.void_for.nil?}
  end
  
  private
  def in_balance?
    entry_balance == @@zero_balance
  end
  
  def entry_balance
    journal_details.inject(Debit.new(0)){|balance, detail| balance.send(detail.transaction_detail.balance_type, detail.transaction_detail.amount)}
  end
  
  def post_details_to_accounts
    journal_details.each do |detail|
      detail.account.send(detail.transaction_detail.balance_type, detail.transaction_detail.amount, :journal_entry=>self)
    end
  end
  
  def record_void
    if void_entry = create_voided_by(:journal=>self.journal, :description=>"Void of #{self.description}")
      self.journal_details.each do |detail|
        transaction_detail = case detail.transaction_detail.balance_type
          when 'debit'  then Credit.new(detail.transaction_detail.amount)
          when 'credit' then Debit.new(detail.transaction_detail.amount)
        end
        void_entry.journal_details.create(:account=>detail.account, :transaction_detail=>transaction_detail)
      end
    end

    void_entry.post! if self.posted?
  end
end

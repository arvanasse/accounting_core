require 'transaction_detail'
module AccountEntryBehavior
  class << self
    def included(receiver)
      receiver.class_eval do
        include AASM
        
        belongs_to :journal_entry # link to book of original entry

        composed_of :transaction_detail,
                    :mapping=>[%w{amount amount}, %w{balance_type balance_type}]

        named_scope :debits, :conditions=>{:balance_type=>'debit'}
        named_scope :credits, :conditions=>{:balance_type=>'credit'}
        named_scope :unposted, :conditions=>{:state=>'recorded'}

        aasm_column :state
        aasm_initial_state :recorded
        aasm_state :recorded
        aasm_state :posted, :enter=>:add_posting_date

        aasm_event :post do
          transitions :from=>[:recorded], :to=>:posted
        end

        before_validation_on_create :add_recording_date

        validates_presence_of :balance_type
        validates_numericality_of :amount, :greater_than_or_equal_to=>0        
      end
    end
  end
  
  private
  def add_recording_date
    self.recorded_on ||= Date.today
  end
  
  def add_posting_date
    self.posted_on ||= Date.today
    save
  end  
  
  def voided?
    self.journal_entry && self.journal_entry.voided?
  end
  
  def original_entry?
    self.journal_entry && !self.journal_entry.void_for_id
  end
end

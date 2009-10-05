class Journal < ActiveRecord::Base
  self.inheritance_column = 'journal_type'
  has_sti_factory
  
  belongs_to :general_ledger
  has_many   :journal_entries
  
  validates_numericality_of :general_ledger_id, :only_integer=>true, :greater_than=>0, :message=>'must be supplied'
  validates_presence_of :name
  
  before_validation_on_create :generate_uuid

  # Use the unique but unpredictable uuid as a url 'id'
  def to_param
    self.uuid
  end
  
  protected
  def validate
    errors.add(:journal_type, "is not a valid subtype") unless self.class.subclass_names.include?(self.journal_type) && self.journal_type != Journal.name
  end
  
  private
  def generate_uuid
    write_attribute(:uuid, UUID.timestamp_create().to_s)
  end
end

class SalesJournal < Journal
  
end

class CashReceiptsJournal < Journal
  
end
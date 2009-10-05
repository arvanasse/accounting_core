class SubledgerEntry < ActiveRecord::Base
  include AccountEntryBehavior

  belongs_to  :subledger_account
  before_save :update_user
  
  validates_numericality_of :subledger_account_id, :only_integer=>true, :greater_than=>0, :message=>"must be supplied"
  
  private
  def update_user
    if Thread.current[:user_id]
      self.created_by_id ||= Thread.current[:user_id]
      self.updated_by_id = Thread.current[:user_id]
    end
  end
end

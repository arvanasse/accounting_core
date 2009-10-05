class JournalDetailObserver < ActiveRecord::Observer
  observe :journal_detail
  
  def after_create(detail)
    notify detail.journal_entry
  end
  
  def after_destroy(detail)
    notify detail.journal_entry
  end
  
  private
  def notify(journal_entry)
    journal_entry.details_adjusted!
    true
  end
end

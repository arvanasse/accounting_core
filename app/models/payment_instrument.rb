class PaymentInstrument < InactiveRecord::Base
  create_table do |t|
    t.string :name
    t.string :reference_number
  end
  
  create :name=>'Cash', :reference_number=>nil
  create :name=>'Check', :reference_number=>'Check Number'
  create :name=>'Credit Card', :reference_number=>'Account Number'
end

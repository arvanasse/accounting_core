require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ReceiptsController do
  describe "route generation" do
    it "should map #index" do
      route_for(:account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59",  :controller => "receipts", :action => "index").should == "/accounts/e4b9f868-e7e8-11dd-ab2c-0016cb90fd59/receipts"
    end
  
    it "should map #new" do
      route_for(:account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59",  :controller => "receipts", :action => "new").should == "/accounts/e4b9f868-e7e8-11dd-ab2c-0016cb90fd59/receipts/new"
    end
  
    it "should map #show" do
      route_for(:account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59",  :controller => "receipts", :action => "show", :id => 1).should == "/accounts/e4b9f868-e7e8-11dd-ab2c-0016cb90fd59/receipts/1"
    end
  
    it "should map #edit" do
      route_for(:account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59",  :controller => "receipts", :action => "edit", :id => 1).should == "/accounts/e4b9f868-e7e8-11dd-ab2c-0016cb90fd59/receipts/1/edit"
    end
  
    it "should map #update" do
      route_for(:account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59",  :controller => "receipts", :action => "update", :id => 1).should == "/accounts/e4b9f868-e7e8-11dd-ab2c-0016cb90fd59/receipts/1"
    end
  
    it "should map #destroy" do
      route_for(:account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59",  :controller => "receipts", :action => "destroy", :id => 1).should == "/accounts/e4b9f868-e7e8-11dd-ab2c-0016cb90fd59/receipts/1"
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/accounts/e4b9f868-e7e8-11dd-ab2c-0016cb90fd59/receipts").should == {:account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59", :controller => "receipts", :action => "index"}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/accounts/e4b9f868-e7e8-11dd-ab2c-0016cb90fd59/receipts/new").should == {:account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59", :controller => "receipts", :action => "new"}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/accounts/e4b9f868-e7e8-11dd-ab2c-0016cb90fd59/receipts").should == {:account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59", :controller => "receipts", :action => "create"}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/accounts/e4b9f868-e7e8-11dd-ab2c-0016cb90fd59/receipts/1").should == {:account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59", :controller => "receipts", :action => "show", :id => "1"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/accounts/e4b9f868-e7e8-11dd-ab2c-0016cb90fd59/receipts/1/edit").should == {:account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59", :controller => "receipts", :action => "edit", :id => "1"}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/accounts/e4b9f868-e7e8-11dd-ab2c-0016cb90fd59/receipts/1").should == {:account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59", :controller => "receipts", :action => "update", :id => "1"}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/accounts/e4b9f868-e7e8-11dd-ab2c-0016cb90fd59/receipts/1").should == {:account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59", :controller => "receipts", :action => "destroy", :id => "1"}
    end
  end
end

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe GeneralLedgersController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "general_ledgers", :action => "index").should == "/general_ledgers"
    end
  
    it "should map #new" do
      route_for(:controller => "general_ledgers", :action => "new").should == "/general_ledgers/new"
    end
  
    it "should map #show" do
      route_for(:controller => "general_ledgers", :action => "show", :id=>'e4b9f868-e7e8-11dd-ab2c-0016cb90fd59').should == "/general_ledgers/e4b9f868-e7e8-11dd-ab2c-0016cb90fd59"
    end
  
    it "should map #edit" do
      route_for(:controller => "general_ledgers", :action => "edit", :id=>'e4b9f868-e7e8-11dd-ab2c-0016cb90fd59').should == "/general_ledgers/e4b9f868-e7e8-11dd-ab2c-0016cb90fd59/edit"
    end
  
    it "should map #update" do
      route_for(:controller => "general_ledgers", :action => "update", :id=>'e4b9f868-e7e8-11dd-ab2c-0016cb90fd59').should == "/general_ledgers/e4b9f868-e7e8-11dd-ab2c-0016cb90fd59"
    end
  
    it "should map #destroy" do
      route_for(:controller => "general_ledgers", :action => "destroy", :id=>'e4b9f868-e7e8-11dd-ab2c-0016cb90fd59').should == "/general_ledgers/e4b9f868-e7e8-11dd-ab2c-0016cb90fd59"
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/general_ledgers").should == {:controller => "general_ledgers", :action => "index"}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/general_ledgers/new").should == {:controller => "general_ledgers", :action => "new"}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/general_ledgers").should == {:controller => "general_ledgers", :action => "create"}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/general_ledgers/e4b9f868-e7e8-11dd-ab2c-0016cb90fd59").should == {:id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59", :controller => "general_ledgers", :action => "show"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/general_ledgers/e4b9f868-e7e8-11dd-ab2c-0016cb90fd59/edit").should == {:id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59", :controller => "general_ledgers", :action => "edit"}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/general_ledgers/e4b9f868-e7e8-11dd-ab2c-0016cb90fd59").should == {:id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59", :controller => "general_ledgers", :action => "update"}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/general_ledgers/e4b9f868-e7e8-11dd-ab2c-0016cb90fd59").should == {:id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59", :controller => "general_ledgers", :action => "destroy"}
    end
  end
end

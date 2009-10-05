require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AccountsController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "accounts", :action => "index").should == "/accounts"
    end
  
    it "should map #new" do
      route_for(:controller => "accounts", :action => "new").should == "/accounts/new"
    end
  
    it "should map #show" do
      route_for(:controller => "accounts", :action => "show", :id=>'e4b9f868-e7e8-11dd-ab2c-0016cb90fd59').should == "/accounts/e4b9f868-e7e8-11dd-ab2c-0016cb90fd59"
    end
  
    it "should map #edit" do
      route_for(:controller => "accounts", :action => "edit", :id=>'e4b9f868-e7e8-11dd-ab2c-0016cb90fd59').should == "/accounts/e4b9f868-e7e8-11dd-ab2c-0016cb90fd59/edit"
    end
  
    it "should map #update" do
      route_for(:controller => "accounts", :action => "update", :id=>'e4b9f868-e7e8-11dd-ab2c-0016cb90fd59').should == "/accounts/e4b9f868-e7e8-11dd-ab2c-0016cb90fd59"
    end
  
    it "should map #destroy" do
      route_for(:controller => "accounts", :action => "destroy", :id=>'e4b9f868-e7e8-11dd-ab2c-0016cb90fd59').should == "/accounts/e4b9f868-e7e8-11dd-ab2c-0016cb90fd59"
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/accounts").should == {:controller => "accounts", :action => "index"}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/accounts/new").should == {:controller => "accounts", :action => "new"}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/accounts").should == {:controller => "accounts", :action => "create"}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/accounts/e4b9f868-e7e8-11dd-ab2c-0016cb90fd59").should == {:id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59", :controller => "accounts", :action => "show"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/accounts/e4b9f868-e7e8-11dd-ab2c-0016cb90fd59/edit").should == {:id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59", :controller => "accounts", :action => "edit"}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/accounts/e4b9f868-e7e8-11dd-ab2c-0016cb90fd59").should == {:id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59", :controller => "accounts", :action => "update"}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/accounts/e4b9f868-e7e8-11dd-ab2c-0016cb90fd59").should == {:id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59", :controller => "accounts", :action => "destroy"}
    end
  end
end

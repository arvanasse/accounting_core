require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe GeneralLedgersController do

  def mock_general_ledger(stubs={})
    @mock_general_ledger ||= mock_model(GeneralLedger, stubs)
  end
  
  describe "responding to GET index" do

    it "should raise an Action Not Found" do
      lambda{get :index}.should raise_error(ActionController::UnknownAction)
    end

    describe "with mime type of xml" do
  
      it "should raise an Action Not Found" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        lambda{get :index}.should raise_error(ActionController::UnknownAction)
      end
    
    end

  end

  describe "responding to GET show" do

    it "should expose the requested general_ledger as @general_ledger" do
      GeneralLedger.should_receive(:find_by_uuid).with("e4b9f868-e7e8-11dd-ab2c-0016cb90fd59").and_return(mock_general_ledger)
      get :show, :id => "e4b9f868-e7e8-11dd-ab2c-0016cb90fd59"
      assigns[:general_ledger].should equal(mock_general_ledger)
    end
    
    describe "with mime type of xml" do

      it "should render the requested general_ledger as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        GeneralLedger.should_receive(:find_by_uuid).with("e4b9f868-e7e8-11dd-ab2c-0016cb90fd59").and_return(mock_general_ledger)
        mock_general_ledger.should_receive(:to_xml).with(:include=>[:ledger_accounts, :journals]).and_return("generated XML")
        get :show, :id => "e4b9f868-e7e8-11dd-ab2c-0016cb90fd59"
        response.body.should == "generated XML"
      end

    end
    
  end

  describe "responding to GET new" do

    it "should raise an Action Not Found" do
      lambda{get :index}.should raise_error(ActionController::UnknownAction)
    end

  end

  describe "responding to GET edit" do
  
    it "should raise an Action Not Found" do
      lambda{get :index}.should raise_error(ActionController::UnknownAction)
    end

  end

  describe "responding to POST create" do

    describe "with valid params" do
      
      it "should expose a newly created general_ledger as @general_ledger" do
        GeneralLedger.should_receive(:new).with({'these' => 'params'}).and_return(mock_general_ledger(:save => true, :uuid=>2))
        mock_general_ledger.should_receive(:to_xml).with(:include=>[:ledger_accounts, :journals]).and_return("generated XML")
        post :create, :general_ledger => {:these => 'params'}
        assigns(:general_ledger).should equal(mock_general_ledger)
      end

      it "should redirect to the created general_ledger" do
        GeneralLedger.stub!(:new).and_return(mock_general_ledger(:save => true, :uuid=>2))
        mock_general_ledger.should_receive(:to_xml).with(:include=>[:ledger_accounts, :journals]).and_return("generated XML")
        post :create, :general_ledger => {}
        response.body.should == "generated XML"
      end
      
    end
    
    describe "with invalid params" do

      it "should expose a newly created but unsaved general_ledger as @general_ledger" do
        GeneralLedger.stub!(:new).with({'these' => 'params'}).and_return(mock_general_ledger(:save => false))
        post :create, :general_ledger => {:these => 'params'}
        assigns(:general_ledger).should equal(mock_general_ledger)
      end
    end
    
  end

  describe "responding to PUT update" do
    it "should raise an Action Not Found" do
      lambda{put :update, :id=>1}.should raise_error(ActionController::UnknownAction)
    end
  end

  describe "responding to DELETE destroy" do
    it "should raise an Action Not Found" do
      lambda{delete :destroy}.should raise_error(ActionController::UnknownAction)
    end
  end

end

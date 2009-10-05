require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AccountsController do

  def mock_ledger_account(stubs={})
    @mock_ledger_account ||= mock_model(LedgerAccount, stubs)
  end
  
  def mock_subledger_account(stubs={})
    @mock_subledger_account ||= mock_model(SubledgerAccount, stubs)
  end
  
  def mock_general_ledger(stubs={})
    @mock_gl ||= mock_model(GeneralLedger, stubs)
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
    describe "with a uuid for a SubledgerAccount" do
      describe "with mime type of xml" do
        it "should render the requested account as xml" do
          request.env["HTTP_ACCEPT"] = "application/xml"
          # Note: Only SubledgerAccount should be queried
          SubledgerAccount.should_receive(:find_by_uuid).with("e4b9f868-e7e8-11dd-ab2c-0016cb90fd59").and_return(mock_subledger_account)
          mock_subledger_account.should_receive(:to_xml).and_return("generated XML")
          get :show, :id => "e4b9f868-e7e8-11dd-ab2c-0016cb90fd59"
          response.body.should == "generated XML"
        end
      end
    end
    
    describe "with a valid uuid for a LedgerAccount" do
      describe "with mime type of xml" do
        it "should render the requested account as xml" do
          request.env["HTTP_ACCEPT"] = "application/xml"
          # Note: LedgerAccount queried after SubledgerAccount returns nil
          SubledgerAccount.should_receive(:find_by_uuid).with("e4b9f868-e7e8-11dd-ab2c-0016cb90fd59").and_return(nil)
          LedgerAccount.should_receive(:find_by_uuid).with("e4b9f868-e7e8-11dd-ab2c-0016cb90fd59").and_return(mock_ledger_account)
          mock_ledger_account.should_receive(:to_xml).and_return("generated XML")
          get :show, :id => "e4b9f868-e7e8-11dd-ab2c-0016cb90fd59"
          response.body.should == "generated XML"
        end
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
      describe "and a uuid for the General Ledger" do
        before(:each) do
          GeneralLedger.should_receive(:find_by_uuid).with("e4b9f868-e7e8-11dd-ab2c-0016cb90fd59").and_return(mock_general_ledger(:ledger_accounts=>LedgerAccount))
          mock_general_ledger.should_receive(:respond_to?).with(:ledger_accounts).and_return(true)

          LedgerAccount.should_receive(:build).with({'these' => 'params'}).and_return(mock_ledger_account(:save => true))          
          mock_ledger_account.should_receive(:to_xml).and_return("generated XML")
          mock_ledger_account.should_receive(:uuid).and_return("a2644bec-a75d-11dd-aee3-0016cb90fd59")          
        end
      
        it "should expose a newly created Ledger Account as @account" do          
          post :create, :account => {:uuid=>'e4b9f868-e7e8-11dd-ab2c-0016cb90fd59', :these => 'params'}
          assigns(:account).should equal(mock_ledger_account)
        end

        it "should render the created Ledger Account" do
          post :create, :account => {:uuid=>'e4b9f868-e7e8-11dd-ab2c-0016cb90fd59', :these => 'params'}
          response.body.should == "generated XML"
        end              
      end
      
      describe "and a uuid for a Ledger Account" do
        before(:each) do
          GeneralLedger.should_receive(:find_by_uuid).with("e4b9f868-e7e8-11dd-ab2c-0016cb90fd59").and_return(nil)
          LedgerAccount.should_receive(:find_by_uuid).with("e4b9f868-e7e8-11dd-ab2c-0016cb90fd59").and_return(mock_ledger_account(:subledger_accounts=>SubledgerAccount))
          mock_ledger_account.should_receive(:respond_to?).with(:ledger_accounts).and_return(false)
          mock_ledger_account.should_receive(:respond_to?).with(:subledger_accounts).and_return(true)

          SubledgerAccount.should_receive(:build).with({'these' => 'params'}).and_return(mock_subledger_account(:save => true))          
          mock_subledger_account.should_receive(:to_xml).and_return("generated XML")
          mock_subledger_account.should_receive(:uuid).and_return("a2644bec-a75d-11dd-aee3-0016cb90fd59")          
        end
      
        it "should expose a newly created Ledger Account as @account" do          
          post :create, :account => {:uuid=>'e4b9f868-e7e8-11dd-ab2c-0016cb90fd59', :these => 'params'}
          assigns(:account).should equal(mock_subledger_account)
        end

        it "should render the created Ledger Account" do
          post :create, :account => {:uuid=>'e4b9f868-e7e8-11dd-ab2c-0016cb90fd59', :these => 'params'}
          response.body.should == "generated XML"
        end              
      end
    end
    
    describe "with invalid params" do
      describe "with an invalid uuid" do
        it "should return a 404 error" do
          GeneralLedger.should_receive(:find_by_uuid).with("e4b9f868-e7e8-11dd-ab2c-0016cb90fd59").and_return(nil)
          LedgerAccount.should_receive(:find_by_uuid).with("e4b9f868-e7e8-11dd-ab2c-0016cb90fd59").and_return(nil)
          post :create, :account => {:uuid=>'e4b9f868-e7e8-11dd-ab2c-0016cb90fd59', :these => 'params'}
          assert_response 422
        end
      end
      
      describe "and a uuid for a General Ledger" do
        before(:each) do
          GeneralLedger.should_receive(:find_by_uuid).with("e4b9f868-e7e8-11dd-ab2c-0016cb90fd59").and_return(mock_general_ledger(:ledger_accounts=>LedgerAccount))
          mock_general_ledger.should_receive(:respond_to?).with(:ledger_accounts).and_return(true)

          LedgerAccount.should_receive(:build).with({'these' => 'params'}).and_return(mock_ledger_account(:save => false))
          mock_ledger_account.should_receive(:errors).and_return('lots of errors')
        end

        it "should expose a newly created but unsaved account as @account" do
          post :create, :account => {:uuid=>'e4b9f868-e7e8-11dd-ab2c-0016cb90fd59', :these => 'params'}
          assigns(:account).should equal(mock_ledger_account)
        end
        
        it "should render errors from the newly created but unsaved account as @account" do
          post :create, :account => {:uuid=>'e4b9f868-e7e8-11dd-ab2c-0016cb90fd59', :these => 'params'}
          response.body.should == "lots of errors"
        end
      end
    end
    
  end

  describe "responding to PUT update" do
    describe "with valid params" do
      describe "with the uuid of a Ledger Account" do
        before(:each) do
          SubledgerAccount.should_receive(:find_by_uuid).with("e4b9f868-e7e8-11dd-ab2c-0016cb90fd59").and_return(nil)
          LedgerAccount.should_receive(:find_by_uuid).with("e4b9f868-e7e8-11dd-ab2c-0016cb90fd59").and_return(mock_ledger_account)
          mock_ledger_account.should_receive(:update_attributes).with({'these'=>'params'}).and_return(true)
          mock_ledger_account.should_receive(:to_xml).and_return("xml attributes")
        end

        it "should expose the updated Ledger Account as @account" do          
          put :update, :id=>'e4b9f868-e7e8-11dd-ab2c-0016cb90fd59', :account => {:these => 'params'}
          assigns(:account).should equal(mock_ledger_account)
        end

        it "should render the updated Ledger Account" do
          put :update, :id=>'e4b9f868-e7e8-11dd-ab2c-0016cb90fd59', :account => {:these => 'params'}
          response.body.should == "xml attributes"
        end              
      end

      describe "with the uuid of a Subledger Account" do
        before(:each) do
          SubledgerAccount.should_receive(:find_by_uuid).with("e4b9f868-e7e8-11dd-ab2c-0016cb90fd59").and_return(mock_subledger_account)
          mock_subledger_account.should_receive(:update_attributes).with({'these'=>'params'}).and_return(true)
          mock_subledger_account.should_receive(:to_xml).and_return("xml attributes")
        end

        it "should expose the updated Subledger Account as @account" do          
          put :update, :id=>'e4b9f868-e7e8-11dd-ab2c-0016cb90fd59', :account => {:these => 'params'}
          assigns(:account).should equal(mock_subledger_account)
        end

        it "should render the updated SUbledger Account" do
          put :update, :id=>'e4b9f868-e7e8-11dd-ab2c-0016cb90fd59', :account => {:these => 'params'}
          response.body.should == "xml attributes"
        end              
      end
    end
    
    describe "with invalid params" do    
      describe "with an invalid uuid" do
        it "should return a 404 error" do
          LedgerAccount.should_receive(:find_by_uuid).with("e4b9f868-e7e8-11dd-ab2c-0016cb90fd59").and_return(nil)
          SubledgerAccount.should_receive(:find_by_uuid).with("e4b9f868-e7e8-11dd-ab2c-0016cb90fd59").and_return(nil)
          put :update, :id=>'e4b9f868-e7e8-11dd-ab2c-0016cb90fd59', :account => {:these => 'params'}
          assert_response 404
        end
      end
      
      describe "with the uuid of a Ledger Account" do
        before(:each) do
          SubledgerAccount.should_receive(:find_by_uuid).with("e4b9f868-e7e8-11dd-ab2c-0016cb90fd59").and_return(nil)
          LedgerAccount.should_receive(:find_by_uuid).with("e4b9f868-e7e8-11dd-ab2c-0016cb90fd59").and_return(mock_ledger_account)
          mock_ledger_account.should_receive(:update_attributes).with({'these'=>'params'}).and_return(false)
          mock_ledger_account.should_receive(:errors).and_return('error list')
        end
        
        it "should expose the updated Ledger Account as @account" do
          put :update, :id=>'e4b9f868-e7e8-11dd-ab2c-0016cb90fd59', :account => {:these => 'params'}
          assigns(:account).should equal(mock_ledger_account)
        end
        
        it "should render the errors on the updated Ledger Account" do
          put :update, :id=>'e4b9f868-e7e8-11dd-ab2c-0016cb90fd59', :account => {:these => 'params'}
          response.body.should == 'error list'
        end
      end
      
      describe "with the uuid of a Subledger Account" do
        before(:each) do
          SubledgerAccount.should_receive(:find_by_uuid).with("e4b9f868-e7e8-11dd-ab2c-0016cb90fd59").and_return(mock_subledger_account)
          mock_subledger_account.should_receive(:update_attributes).with({'these'=>'params'}).and_return(false)
          mock_subledger_account.should_receive(:errors).and_return('error list')
        end
        
        it "should expose the updated Subledger Account as @account" do
          put :update, :id=>'e4b9f868-e7e8-11dd-ab2c-0016cb90fd59', :account => {:these => 'params'}
          assigns(:account).should equal(mock_subledger_account)
        end
        
        it "should render the errors on the updated Subledger Account" do
          put :update, :id=>'e4b9f868-e7e8-11dd-ab2c-0016cb90fd59', :account => {:these => 'params'}
          response.body.should == 'error list'
        end
      end
    end    
  end

  describe "responding to DELETE destroy" do
    it "should raise an Action Not Found" do
      lambda{delete :destroy}.should raise_error(ActionController::UnknownAction)
    end
  end

end

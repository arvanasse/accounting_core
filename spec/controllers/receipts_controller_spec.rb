require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ReceiptsController do

  def mock_receipt(stubs={})
    @mock_receipt ||= mock_model(Receipt, stubs)
  end
  
  def mock_account(stubs={})
    @mock_account ||= mock_model(SubledgerAccount, stubs)
  end
  
  describe "responding to GET index" do
    describe "with a valid account uuid" do
      before(:each) do
        SubledgerAccount.should_receive(:find_by_uuid).with("e4b9f868-e7e8-11dd-ab2c-0016cb90fd59").and_return(mock_account(:receipts=>Receipt))
      end

      it "should expose all receipts as @receipts" do
        Receipt.should_receive(:by_date).and_return([mock_receipt])
        get :index, :account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59"
        assigns[:account].should == mock_account
        assigns[:receipts].should == [mock_receipt]
      end

      describe "with mime type of xml" do
        it "should render all receipts as xml" do
          request.env["HTTP_ACCEPT"] = "application/xml"
          
          Receipt.should_receive(:by_date).and_return(receipts = mock("Array of Receipts"))      
          receipts.should_receive(:to_xml).and_return("generated XML")

          get :index, :account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59"
          response.body.should == "generated XML"
        end
      end
    end
    
    describe "with an unknown account uuid" do
      it "should return a 404" do
        get :index, :account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59"
        assert_response 404
      end
    end
  end

  describe "responding to GET show" do
    describe "with a valid account uuid" do
      before(:each) do
        SubledgerAccount.should_receive(:find_by_uuid).with("e4b9f868-e7e8-11dd-ab2c-0016cb90fd59").and_return(mock_account(:receipts=>Receipt))
        Receipt.should_receive(:find_by_id).with("37").and_return(mock_receipt)
      end
      
      it "should expose the requested receipt as @receipt" do
        get :show, :account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59", :id => "37"
        assigns[:account].should == mock_account
        assigns[:receipt].should equal(mock_receipt)
      end

      describe "with mime type of xml" do
        it "should render the requested receipt as xml" do
          request.env["HTTP_ACCEPT"] = "application/xml"
          mock_receipt.should_receive(:to_xml).with(:include=>:receipt_details).and_return("generated XML")
          get :show, :account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59", :id => "37"
          response.body.should == "generated XML"
        end
      end
    end
    
    
    describe "with an unknown account uuid" do
      it "should return a 404" do
        get :index, :account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59"
        assert_response 404
      end
    end
  end

  describe "responding to GET new" do
  
    it "should expose a new receipt as @receipt" do
      Receipt.should_receive(:new).and_return(mock_receipt)
      get :new
      assigns[:receipt].should equal(mock_receipt)
    end

  end

  describe "responding to GET edit" do
  
    it "should expose the requested receipt as @receipt" do
      Receipt.should_receive(:find).with("37").and_return(mock_receipt)
      get :edit, :id => "37"
      assigns[:receipt].should equal(mock_receipt)
    end

  end

  describe "responding to POST create" do

    describe "with valid params" do
      before(:each) do
        SubledgerAccount.should_receive(:find_by_uuid).with("e4b9f868-e7e8-11dd-ab2c-0016cb90fd59").and_return(mock_account(:receipts=>Receipt, :uuid=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59"))
      end
            
      it "should expose a newly created receipt as @receipt" do
        Receipt.should_receive(:build).with({'these' => 'params'}).and_return(mock_receipt(:save => true))
        post :create, :account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59", :receipt => {:these => 'params'}
        assigns[:account].should == mock_account
        assigns(:receipt).should equal(mock_receipt)
      end
      
      it "should build a new receipt detail for each detail supplied with the receipt" do
        Receipt.should_receive(:build).with({'these' => 'params'}).and_return(mock_receipt(:save => true))
        mock_receipt.should_receive(:receipt_details).twice.and_return([])
        ReceiptDetail.should_receive(:new).twice
        post :create, :account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59", :receipt => {:these => 'params', :receipt_details=>{'1'=>{}, '2'=>{}}}
      end

      it "should redirect to the created receipt" do
        Receipt.stub!(:build).and_return(mock_receipt(:save => true))
        post :create, :account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59", :receipt => {}
        response.should redirect_to(account_receipt_url(:account_id=>mock_account.uuid, :id=>mock_receipt.id))
      end
      
      describe "with mime type of xml" do
        it "should render the created receipt as xml" do
          request.env["HTTP_ACCEPT"] = "application/xml"
          Receipt.stub!(:build).and_return(mock_receipt(:save => true))
          mock_receipt.should_receive(:to_xml).with(:include=>:receipt_details).and_return("receipt xml")
          post :create, :account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59", :receipt => {}
          response.body.should == "receipt xml"
        end
      end
    end
    
    describe "with an unknown account uuid" do
      it "should respond with a 404" do
        get :index, :account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59"
        assert_response 404
      end
    end
    
    describe "with invalid params" do
      before(:each) do
        SubledgerAccount.should_receive(:find_by_uuid).with("e4b9f868-e7e8-11dd-ab2c-0016cb90fd59").and_return(mock_account(:receipts=>Receipt))
      end
      
      it "should expose a newly created but unsaved receipt as @receipt" do
        Receipt.stub!(:build).with({'these' => 'params'}).and_return(mock_receipt(:save => false))
        post :create, :account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59", :receipt => {:these => 'params'}
        assigns(:receipt).should equal(mock_receipt)
      end

      it "should re-render the 'new' template" do
        Receipt.stub!(:build).and_return(mock_receipt(:save => false))
        post :create, :account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59", :receipt => {}
        response.should render_template('new')
      end
    end
    
  end

  describe "responding to PUT udpate" do

    describe "with valid params" do
      before(:each) do
        SubledgerAccount.should_receive(:find_by_uuid).with("e4b9f868-e7e8-11dd-ab2c-0016cb90fd59").and_return(mock_account(:receipts=>Receipt, :uuid=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59"))
      end

      it "should update the requested receipt" do
        Receipt.should_receive(:find_by_id).with("37").and_return(mock_receipt)
        mock_receipt.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59", :id => "37", :receipt => {:these => 'params'}
      end

      it "should expose the requested receipt as @receipt" do
        Receipt.stub!(:find_by_id).and_return(mock_receipt(:update_attributes => true))
        put :update, :account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59", :id => "1"
        assigns(:receipt).should equal(mock_receipt)
        assigns(:account).should equal(mock_account)
      end

      it "should redirect to the receipt" do
        Receipt.stub!(:find_by_id).and_return(mock_receipt(:update_attributes => true))
        put :update, :account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59", :id => "1"
        response.should redirect_to(account_receipt_url(:account_id=>mock_account.uuid, :id=>mock_receipt.id))
      end

      describe "and a mime type of xml" do
        it "should respond with a 200 (OK)" do
          request.env["HTTP_ACCEPT"] = "application/xml"
          Receipt.stub!(:find_by_id).and_return(mock_receipt(:update_attributes => true))
          put :update, :account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59", :id => "1"
          assert_response 200
        end        
      end
      
    end
    
    describe "with an invalid account uuid" do
      it "should respond with a 404" do
        SubledgerAccount.should_receive(:find_by_uuid).with("e4b9f868-e7e8-11dd-ab2c-0016cb90fd59").and_return(nil)
        put :update, :account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59", :id => "1"
        assert_response 404
      end
    end
    
    describe "with invalid params" do
      before(:each) do
        SubledgerAccount.should_receive(:find_by_uuid).with("e4b9f868-e7e8-11dd-ab2c-0016cb90fd59").and_return(mock_account(:receipts=>Receipt, :uuid=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59"))
      end

      it "should update the requested receipt" do
        Receipt.should_receive(:find_by_id).with("37").and_return(mock_receipt)
        mock_receipt.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59", :id => "37", :receipt => {:these => 'params'}
      end

      it "should expose the receipt as @receipt" do
        Receipt.stub!(:find_by_id).and_return(mock_receipt(:update_attributes => false))
        put :update, :account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59", :id => "1"
        assigns(:receipt).should equal(mock_receipt)
        assigns(:account).should equal(mock_account)
      end

      it "should re-render the 'edit' template" do
        Receipt.stub!(:find_by_id).and_return(mock_receipt(:update_attributes => false))
        put :update, :account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59", :id => "1"
        response.should render_template('edit')
      end
    end
  end

  describe "responding to DELETE destroy" do
    describe "with a valid account uuid" do
      before(:each) do
        SubledgerAccount.should_receive(:find_by_uuid).with("e4b9f868-e7e8-11dd-ab2c-0016cb90fd59").and_return(mock_account(:receipts=>Receipt, :uuid=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59"))
      end

      it "should destroy the requested receipt" do
        Receipt.should_receive(:find_by_id).with("37").and_return(mock_receipt)
        mock_receipt.should_receive(:void!).and_return(true)
        delete :destroy, :account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59", :id => "37"
      end

      it "should redirect to the receipts list" do
        Receipt.stub!(:find_by_id).and_return(mock_receipt(:void! => true))
        delete :destroy, :account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59", :id => "1"
        response.should redirect_to(account_receipts_url(:account_id=>mock_account.uuid))
      end
      
      describe "with a mime type of xml" do
        it "should respond with a 200 (OK)" do
          request.env["HTTP_ACCEPT"] = "application/xml"
          Receipt.stub!(:find_by_id).and_return(mock_receipt(:void! => true))
          delete :destroy, :account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59", :id => "1"
          assert_response 200
        end        
      end
    end
    
    describe "and an unknown account uuid" do
      it "should respond with a 404" do
        SubledgerAccount.should_receive(:find_by_uuid).with("e4b9f868-e7e8-11dd-ab2c-0016cb90fd59").and_return(nil)
        delete :destroy, :account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59", :id => "1"
        assert_response 404
      end
    end
  end

end

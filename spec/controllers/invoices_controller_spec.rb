require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe InvoicesController do

  def mock_invoice(stubs={})
    @mock_invoice ||= mock_model(Invoice, stubs)
  end
  
  def mock_account(stubs={})
    @mock_account ||= mock_model(SubledgerAccount, stubs)
  end
  
  describe "responding to GET index" do
    describe "with a valid account uuid" do
      before(:each) do
        SubledgerAccount.should_receive(:find_by_uuid).with("e4b9f868-e7e8-11dd-ab2c-0016cb90fd59").and_return(mock_account(:invoices=>Invoice))
      end
      
      it "should expose all invoices as @invoices" do
        Invoice.should_receive(:by_date).and_return([mock_invoice])
        get :index, :account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59"
        assigns[:account].should == mock_account
        assigns[:invoices].should == [mock_invoice]
      end

      describe "with mime type of xml" do
        it "should render all invoices as xml" do
          request.env["HTTP_ACCEPT"] = "application/xml"

          Invoice.should_receive(:by_date).and_return(invoices = mock("Array of Invoices"))
          invoices.should_receive(:to_xml).and_return("generated XML")

          get :index, :account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59"
          response.body.should == "generated XML"
        end
      end
    end
    
    describe "with an unknown account uuid" do
      it "should respond with a 404" do
        get :index, :account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59"
        assert_response 404
      end
    end
  end

  describe "responding to GET show" do
    describe "with a valid account uuid" do
      before(:each) do
        SubledgerAccount.should_receive(:find_by_uuid).with("e4b9f868-e7e8-11dd-ab2c-0016cb90fd59").and_return(mock_account(:invoices=>Invoice))
        Invoice.should_receive(:find_by_id).with("37").and_return(mock_invoice)
      end
      
      it "should expose the requested invoice as @invoice" do
        get :show, :account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59", :id => "37"
        assigns[:account].should == mock_account
        assigns[:invoice].should equal(mock_invoice)
      end

      describe "with mime type of xml" do
        it "should render the requested invoice as xml" do
          request.env["HTTP_ACCEPT"] = "application/xml"
          mock_invoice.should_receive(:to_xml).with(:include=>[:invoice_lines, :invoice_payments]).and_return("generated XML")
          get :show, :account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59", :id => "37"
          response.body.should == "generated XML"
        end
      end
    end
    
    
    describe "with an unknown account uuid" do
      it "should respond with a 404" do
        get :index, :account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59"
        assert_response 404
      end
    end
  end

  describe "responding to GET new" do
  
    it "should expose a new invoice as @invoice" do
      Invoice.should_receive(:new).and_return(mock_invoice)
      get :new
      assigns[:invoice].should equal(mock_invoice)
    end

  end

  describe "responding to GET edit" do
  
    it "should expose the requested invoice as @invoice" do
      Invoice.should_receive(:find).with("37").and_return(mock_invoice)
      get :edit, :id => "37"
      assigns[:invoice].should equal(mock_invoice)
    end

  end

  describe "responding to POST create" do

    describe "with valid params" do
      before(:each) do
        SubledgerAccount.should_receive(:find_by_uuid).with("e4b9f868-e7e8-11dd-ab2c-0016cb90fd59").and_return(mock_account(:invoices=>Invoice, :uuid=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59"))
      end
      
      it "should expose a newly created invoice as @invoice" do
        Invoice.should_receive(:build).with({'these' => 'params'}).and_return(mock_invoice(:save => true))
        post :create, :account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59", :invoice => {:these => 'params'}
        assigns[:account].should == mock_account
        assigns(:invoice).should equal(mock_invoice)
      end

      it "should build a new invoice detail for each detail supplied with the invoice" do
        Invoice.should_receive(:build).with({'these' => 'params'}).and_return(mock_invoice(:save => true))
        mock_invoice.should_receive(:invoice_lines).twice.and_return([])
        InvoiceLine.should_receive(:new).twice
        post :create, :account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59", :invoice => {:these => 'params', :invoice_lines=>{'1'=>{}, '2'=>{}}}
      end

      it "should redirect to the created invoice" do
        Invoice.stub!(:build).and_return(mock_invoice(:save => true))
        post :create, :account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59", :invoice => {}
        response.should redirect_to(account_invoice_url(:account_id=>mock_account.uuid, :id=>mock_invoice.id))
      end
      
      describe "with mime type of xml" do
        it "should render the created invoice as xml" do
          request.env["HTTP_ACCEPT"] = "application/xml"
          Invoice.stub!(:build).and_return(mock_invoice(:save => true))
          mock_invoice.should_receive(:to_xml).with(:include=>[:invoice_lines, :invoice_payments]).and_return("invoice xml")
          post :create, :account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59", :invoice => {}
          response.body.should == "invoice xml"
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
        SubledgerAccount.should_receive(:find_by_uuid).with("e4b9f868-e7e8-11dd-ab2c-0016cb90fd59").and_return(mock_account(:invoices=>Invoice))
      end
      
      it "should expose a newly created but unsaved invoice as @invoice" do
        Invoice.stub!(:build).with({'these' => 'params'}).and_return(mock_invoice(:save => false))
        post :create, :account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59", :invoice => {:these => 'params'}
        assigns(:invoice).should equal(mock_invoice)
      end

      it "should re-render the 'new' template" do
        Invoice.stub!(:build).and_return(mock_invoice(:save => false))
        post :create, :account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59", :invoice => {}
        response.should render_template('new')
      end
    end
    
  end

  describe "responding to PUT update" do

    describe "with valid params" do
      before(:each) do
        SubledgerAccount.should_receive(:find_by_uuid).with("e4b9f868-e7e8-11dd-ab2c-0016cb90fd59").and_return(mock_account(:invoices=>Invoice, :uuid=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59"))
      end

      it "should update the requested invoice" do
        Invoice.should_receive(:find_by_id).with("37").and_return(mock_invoice)
        mock_invoice.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59", :id => "37", :invoice => {:these => 'params'}
      end

      it "should expose the requested invoice as @invoice" do
        Invoice.stub!(:find_by_id).and_return(mock_invoice(:update_attributes => true))
        put :update, :account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59", :id => "1"
        assigns(:invoice).should equal(mock_invoice)
        assigns(:account).should equal(mock_account)
      end

      it "should redirect to the invoice" do
        Invoice.stub!(:find_by_id).and_return(mock_invoice(:update_attributes => true))
        put :update, :account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59", :id => "1"
        response.should redirect_to(account_invoice_url(:account_id=>mock_account.uuid, :id=>mock_invoice.id))
      end
      
      describe "and a mime type of xml" do
        it "should respond with a 200 (OK)" do
          request.env["HTTP_ACCEPT"] = "application/xml"
          Invoice.stub!(:find_by_id).and_return(mock_invoice(:update_attributes => true))
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
        SubledgerAccount.should_receive(:find_by_uuid).with("e4b9f868-e7e8-11dd-ab2c-0016cb90fd59").and_return(mock_account(:invoices=>Invoice, :uuid=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59"))
      end

      it "should update the requested invoice" do
        Invoice.should_receive(:find_by_id).with("37").and_return(mock_invoice)
        mock_invoice.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59", :id => "37", :invoice => {:these => 'params'}
      end

      it "should expose the invoice as @invoice" do
        Invoice.stub!(:find_by_id).and_return(mock_invoice(:update_attributes => false))
        put :update, :account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59", :id => "1"
        assigns(:invoice).should equal(mock_invoice)
        assigns(:account).should equal(mock_account)
      end

      it "should re-render the 'edit' template" do
        Invoice.stub!(:find_by_id).and_return(mock_invoice(:update_attributes => false))
        put :update, :account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59", :id => "1"
        response.should render_template('edit')
      end
    end
  end
  
  describe "responding to PUT to close" do
    describe "with a valid account uuid" do
      before(:each) do
        SubledgerAccount.should_receive(:find_by_uuid).with("e4b9f868-e7e8-11dd-ab2c-0016cb90fd59").and_return(mock_account(:invoices=>Invoice, :uuid=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59"))
      end

      it "should update the requested invoice" do
        Invoice.should_receive(:find_by_id).with("37").and_return(mock_invoice)
        mock_invoice.should_receive(:close!).and_return(true)
        put :close, :account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59", :id => "37"
      end
    end
    
    describe "with an invalid account uuid" do
      it "should return a 404" do
        SubledgerAccount.should_receive(:find_by_uuid).with("e4b9f868-e7e8-11dd-ab2c-0016cb90fd59").and_return(nil)
        put :close, :account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59", :id => "1"
        assert_response 404
      end
    end
  end

  describe "responding to DELETE destroy" do
    describe "with a valid account uuid" do
      before(:each) do
        SubledgerAccount.should_receive(:find_by_uuid).with("e4b9f868-e7e8-11dd-ab2c-0016cb90fd59").and_return(mock_account(:invoices=>Invoice, :uuid=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59"))
      end

      it "should destroy the requested invoice" do
        Invoice.should_receive(:find_by_id).with("37").and_return(mock_invoice)
        mock_invoice.should_receive(:void!).and_return(true)
        delete :destroy, :account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59", :id => "37"
      end

      it "should redirect to the invoices list" do
        Invoice.stub!(:find_by_id).and_return(mock_invoice(:void! => true))
        delete :destroy, :account_id=>"e4b9f868-e7e8-11dd-ab2c-0016cb90fd59", :id => "1"
        response.should redirect_to(account_invoices_url(:account_id=>mock_account.uuid))
      end

      describe "with a mime type of xml" do
        it "should respond with a 200 (OK)" do
          request.env["HTTP_ACCEPT"] = "application/xml"
          Invoice.stub!(:find_by_id).and_return(mock_invoice(:void! => true))
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

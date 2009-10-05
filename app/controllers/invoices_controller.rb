class InvoicesController < ApplicationController
  # GET /invoices
  # GET /invoices.xml
  def index
    @account = SubledgerAccount.find_by_uuid(params[:account_id])
    head(:status=>:not_found) and return if @account.nil?

    @invoices = @account.invoices.by_date

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @invoices }
    end
  end

  # GET /invoices/1
  # GET /invoices/1.xml
  def show
    @account = SubledgerAccount.find_by_uuid(params[:account_id])
    head(:status=>:not_found) and return if @account.nil?

    @invoice = @account.invoices.find_by_id(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @invoice.to_xml(:include=>[:invoice_lines, :invoice_payments]) }
    end
  end

  # GET /invoices/new
  # GET /invoices/new.xml
  def new
    @invoice = Invoice.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @invoice }
    end
  end

  # GET /invoices/1/edit
  def edit
    @invoice = Invoice.find(params[:id])
  end

  # POST /invoices
  # POST /invoices.xml
  def create
    @account = SubledgerAccount.find_by_uuid(params[:account_id])
    if @account.nil?
      head(:status=>:not_found) 
      return 
    end

    invoice_complete = params[:invoice].delete(:complete)
    Invoice.transaction do
      line_items = params[:invoice].delete(:invoice_lines)
      @invoice = @account.invoices.build(params[:invoice])
      line_items.each{|line_item| @invoice.invoice_lines << InvoiceLine.new(line_item)} if line_items
    end

    respond_to do |format|
      if @invoice.save
        @invoice.close! if invoice_complete
        flash[:notice] = 'Invoice was successfully created.'
        format.html { redirect_to account_invoice_url(:account_id=>@account.uuid, :id=>@invoice.id) }
        format.xml  { render :xml => @invoice.to_xml(:include=>[:invoice_lines, :invoice_payments]), 
                             :status => :created, 
                             :location => account_invoice_url(:account_id=>@account.uuid, :id=>@invoice.id) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @invoice.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /invoices/1
  # PUT /invoices/1.xml
  def update
    @account = SubledgerAccount.find_by_uuid(params[:account_id])
    head(:status=>:not_found) and return if @account.nil?
    
    @invoice = @account.invoices.find_by_id(params[:id])    
    head(:status=>:not_found) and return if @invoice.nil?

    respond_to do |format|
      if @invoice.update_attributes(params[:invoice])
        flash[:notice] = 'Invoice was successfully updated.'
        format.html { redirect_to account_invoice_url(:account_id=>@account.uuid, :id=>@invoice.id) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @invoice.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /invoices/1
  # DELETE /invoices/1.xml
  def destroy
    @account = SubledgerAccount.find_by_uuid(params[:account_id])
    head(:status=>:not_found) and return if @account.nil?

    @invoice = @account.invoices.find_by_id(params[:id])
    head(:status=>:not_found) and return if @invoice.nil?

    @invoice.void!
    
    respond_to do |format|
      format.html { redirect_to(account_invoices_url(:account_id=>@account.uuid)) }
      format.xml  { head :ok }
    end
  end
end
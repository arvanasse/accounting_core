class ReceiptsController < ApplicationController
  # GET /receipts
  # GET /receipts.xml
  def index
    @account = SubledgerAccount.find_by_uuid(params[:account_id])    
    head(:status=>:not_found) and return if @account.nil?

    @receipts = @account.receipts.by_date

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @receipts }
    end
  end

  # GET /receipts/1
  # GET /receipts/1.xml
  def show
    @account = SubledgerAccount.find_by_uuid(params[:account_id])    
    head(:status=>:not_found) and return if @account.nil?

    @receipt = @account.receipts.find_by_id(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @receipt.to_xml(:include=>:receipt_details) }
    end
  end

  # GET /receipts/new
  # GET /receipts/new.xml
  def new
    @receipt = Receipt.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @receipt }
    end
  end

  # GET /receipts/1/edit
  def edit
    @receipt = Receipt.find(params[:id])
  end

  # POST /receipts
  # POST /receipts.xml
  def create
    @account = SubledgerAccount.find_by_uuid(params[:account_id])    
    head(:status=>:not_found) and return if @account.nil?
    
    line_items = params[:receipt].delete(:receipt_details)

    @receipt = @account.receipts.build(params[:receipt])
    line_items.each{|detail| @receipt.receipt_details << ReceiptDetail.new(detail)} if line_items

    respond_to do |format|
      if @receipt.save
        flash[:notice] = 'Receipt was successfully created.'
        format.html { redirect_to(account_receipt_url(:account_id=>@account.uuid, :id=>@receipt.id)) }
        format.xml  { render :xml => @receipt.to_xml(:include=>:receipt_details), 
                             :status => :created, 
                             :location => account_receipt_url(:account_id=>@account.uuid, :id=>@receipt.id) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @receipt.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /receipts/1
  # PUT /receipts/1.xml
  def update
    @account = SubledgerAccount.find_by_uuid(params[:account_id])    
    head(:status=>:not_found) and return if @account.nil?

    @receipt = @account.receipts.find_by_id(params[:id])
    head(:status=>:not_found) and return if @receipt.nil?

    respond_to do |format|
      if @receipt.update_attributes(params[:receipt])
        flash[:notice] = 'Receipt was successfully updated.'
        format.html { redirect_to(account_receipt_url(:account_id=>@account.uuid, :id=>@receipt.id)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @receipt.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /receipts/1
  # DELETE /receipts/1.xml
  def destroy
    @account = SubledgerAccount.find_by_uuid(params[:account_id])    
    head(:status=>:not_found) and return if @account.nil?

    @receipt = @account.receipts.find_by_id(params[:id])
    head(:status=>:not_found) and return if @receipt.nil?

    @receipt.void!

    respond_to do |format|
      format.html { redirect_to(account_receipts_url(:account_id=>@account.uuid)) }
      format.xml  { head :ok }
    end
  end
end
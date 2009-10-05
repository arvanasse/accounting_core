class AccountsController < ApplicationController
  def create
    owner_uuid = params[:account].delete(:uuid)
    @master_account = GeneralLedger.find_by_uuid(owner_uuid) || LedgerAccount.find_by_uuid(owner_uuid)
    @account = case
      when @master_account.respond_to?(:ledger_accounts)    then @master_account.ledger_accounts.build(params[:account])
      when @master_account.respond_to?(:subledger_accounts) then @master_account.subledger_accounts.build(params[:account])
      else head(:status=>:unprocessable_entity) and return
    end
    
    respond_to do |format|
      if @account.save
        format.xml { render :xml => @account.to_xml, :status => :created, :location => account_url(:id=>@account.uuid) }
      else
        format.xml { render :xml => @account.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def show
    @account = SubledgerAccount.find_by_uuid(params[:id]) || LedgerAccount.find_by_uuid(params[:id])
    respond_to do |format|
      format.xml { render :xml=>@account.to_xml }
      format.html{ head :unprocessable_entity}
    end
  end

  def update
    @account = SubledgerAccount.find_by_uuid(params[:id]) || LedgerAccount.find_by_uuid(params[:id])
    
    if @account.nil?
      head(:status => :not_found) and return
    end
    
    respond_to do |format|
      if @account.update_attributes(params[:account])
        format.xml { render :xml=>@account.to_xml }
      else
        format.xml { render :xml => @account.errors, :status => :unprocessable_entity }
      end
    end
  end
end

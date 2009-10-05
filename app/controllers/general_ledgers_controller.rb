class GeneralLedgersController < ApplicationController
  def create
    GeneralLedger.transaction{@general_ledger = GeneralLedger.new(params[:general_ledger])}
    
    respond_to do |format|
      if @general_ledger.save
        format.xml { render_ledger :status=>:created, :location=>general_ledger_path(:id=>@general_ledger.uuid) }
      else
        format.xml  { render :xml => @general_ledger.errors, :status => :unprocessable_entity }
      end
    end
  end

  def show
    @general_ledger = GeneralLedger.find_by_uuid(params[:id])
    respond_to do |format|
      format.html {head :unprocessable_entity}
      format.xml { render_ledger }
    end
  end
  
  private
  def render_ledger(options={})
    rendering = {:xml => @general_ledger.to_xml(:include=>[:ledger_accounts, :journals])}.merge(options)
    render rendering
  end
end

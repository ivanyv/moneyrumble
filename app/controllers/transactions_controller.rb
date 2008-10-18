class TransactionsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => 'update_attr'
  
  # GET /transactions
  # GET /transactions.xml
  def index
    @account = current_user.accounts.find(params[:account_id])

    order = params['sidx'] ? params['sidx'] : ''
    order += params['sord'] == 'asc' ? ' asc' : ' desc'
    @transactions = @account.transactions.find(:all, :order => order)
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  # index.xml.erb
    end
  end

  # GET /transactions/1
  # GET /transactions/1.xml
  def show
    @transaction = Transaction.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @transaction }
    end
  end

  # GET /transactions/new
  # GET /transactions/new.xml
  def new
    @transaction = Transaction.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @transaction }
    end
  end

  # GET /transactions/1/edit
  def edit
    @transaction = Transaction.find(params[:id])
  end

  # POST /transactions
  # POST /transactions.xml
  def create
    @transaction = Transaction.new(params[:transaction])

    respond_to do |format|
      if @transaction.save
        flash[:notice] = 'Transaction was successfully created.'
        format.html { redirect_to(@transaction) }
        format.xml  { render :xml => @transaction, :status => :created, :location => @transaction }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @transaction.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /transactions/1
  # PUT /transactions/1.xml
  def update
    @transaction = Transaction.find(params[:id])

    respond_to do |format|
      if @transaction.update_attributes(params[:transaction])
        flash[:notice] = 'Transaction was successfully updated.'
        format.html { redirect_to(@transaction) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @transaction.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update_attr
    account = current_user.accounts.find(params[:account_id])
    transaction = account.transactions.find(params[:id])
    params.each do |param, value|
      case param
      when 'number'
        transaction.number = value
      when 'date'
        transaction.date = value
      end
    end
    if transaction.save
      head :ok
    else
      render :xml => @transaction.errors, :status => :unprocessable_entity
    end
  end

  # DELETE /transactions/1
  # DELETE /transactions/1.xml
  def destroy
    @transaction = Transaction.find(params[:id])
    @transaction.destroy

    respond_to do |format|
      format.html { redirect_to(transactions_url) }
      format.xml  { head :ok }
    end
  end
end

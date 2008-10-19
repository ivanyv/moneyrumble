class TransactionsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => 'update_attr'
  before_filter :set_account
  
  # GET /transactions
  # GET /transactions.xml
  def index
    if params['sidx']
      order = params['sidx']
      order += params['sord'] == 'asc' ? ' asc' : ' desc'
    end
    
    if params[:detail]
      @transaction = @account.transactions.find(params[:id])
    else
      @transactions = @account.transactions.find(:all, :order => order)
    end
    
    respond_to do |format|
      format.xml  {
        render :action => 'detail' if params[:detail]
      }
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
    type = params[:trans_type].capitalize
    type = 'Transaction' if type == 'Transfer'
    type_sym = type.downcase.to_sym
    amount = BigDecimal.new(params[type_sym].delete(:amount)).abs

    # It doesn't matter if it's invalid because we check that later:
    @transfer = nil
    case type_sym
    when :payment
      contact_name = params[:payment].delete(:other_party_id)
      contact = Contact.find_or_create_by_name_for_owner(contact_name, current_user.id)
      params[:payment][:other_party_id] = contact ? contact.id : nil
      @transaction = @account.payments.new(params[:payment])
      @transaction.payment = amount
    when :deposit
      contact_name = params[:deposit].delete(:other_party_id)
      contact = Contact.find_or_create_by_name_for_owner(contact_name, current_user.id)
      params[:deposit][:other_party_id] = contact ? contact.id : nil
      @transaction = @account.deposits.new(params[:deposit])
      @transaction.deposit = amount
    when :transaction
      @transaction = @account.payments.new(params[:transaction])
      @transaction.payment = amount
      @transfer = @account.transfer_to(@transaction, params[:transaction][:other_party_id])
    else
      return head :bad_request
    end

    return head :ok if amount == 0

    respond_to do |format|
      if @transaction.save
        if @transfer
          @transfer.save
          @transaction.update_attribute :transfer_transaction_id, @transfer.id
          @transfer.account.update_balance
          @transaction.account.update_balance
        end
        flash[:notice] = 'Transaction was successfully created.'
        format.html { head :ok }
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
    transaction = @account.transactions.find(params[:id])
    params.each do |param, value|
      case param
      when 'number'
        transaction.number = value
      when 'date'
        transaction.date = value
      when 'destroy'
        transaction.destroy if value
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
    @transaction = @account.transactions.find(params[:id])
    @transaction.destroy

    respond_to do |format|
      format.html { head :ok }
      format.xml  { head :ok }
    end
  end
  
  protected
  def set_account
    @account = current_user.accounts.find(params[:account_id])
  end
end
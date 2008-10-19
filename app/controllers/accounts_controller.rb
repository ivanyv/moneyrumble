class AccountsController < ApplicationController
  auto_complete_for :contact, :name

  before_filter :find_sidebar_accounts, :only => [ :dashboard, :index, :show, :new ]
  before_filter :accounts_for_transfer, :only => [ :dashboard, :show ]
  
  def dashboard
    @current_section = 'register'

    respond_to do |format|
      format.html {
        render :action => 'no_accounts' if @accounts.size < 1
      }
      format.js   {
        #render :action => 'dashboard'
      }
    end
  end

  # GET /accounts
  # GET /accounts.xml
  def index
    @current_section = 'accounts'
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @accounts }
      format.js   { render :partial => 'at_a_glance'}
    end
  end

  # GET /accounts/1
  # GET /accounts/1.xml
  def show
    @current_section = 'register'
    
    respond_to do |format|
      format.html { render :action => 'dashboard' }
      format.xml  { render :xml => @account }
    end
  end

  # GET /accounts/new
  # GET /accounts/new.xml
  def new
    @account = current_user.accounts.new

    respond_to do |format|
      format.js   { render :partial => 'new' }
    end
  end

  # GET /accounts/1/edit
  def edit
    @account = current_user.accounts.find(params[:id])
  end

  # POST /accounts
  # POST /accounts.xml
  def create
    @account = current_user.accounts.new(params[:account])
    
    #respond_to do |format|
      if @account.save
        default_account = Account.count == 1 || (Account.count > 1 && params[:default_account])
        current_user.update_attribute(:default_account, @account.id) if default_account

        flash[:notice] = 'Account was successfully created.'
        head :ok
        #format.html { redirect_to(@account) }
        #format.xml  { render :xml => @account, :status => :created, :location => @account }
      else
        #format.html { render :action => "new" }
        #format.xml  { render :xml => @account.errors, :status => :unprocessable_entity }
        head :unprocessable_entity
      end
    #end
  end

  # PUT /accounts/1
  # PUT /accounts/1.xml
  def update
    @account = current_user.account.find(params[:id])

    respond_to do |format|
      if @account.update_attributes(params[:account])
        flash[:notice] = 'Account was successfully updated.'
        format.html { redirect_to(@account) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @account.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /accounts/1
  # DELETE /accounts/1.xml
  def destroy
    @account = current_user.account.find(params[:id])
    @account.destroy

    respond_to do |format|
      format.html { redirect_to(accounts_url) }
      format.xml  { head :ok }
    end
  end
  
  protected
    def find_sidebar_accounts
      @account = params[:id] ? @account = current_user.accounts.find(params[:id]) :
        @account  = current_user.default_account

      @all_accounts = current_user.accounts.find(:all, :include => [ :sub_accounts ] )

      @accounts = []
      @all_accounts.each {|a| @accounts << a unless a.parent_id }
    end

    def accounts_for_transfer
      @accounts_for_transfer = []
      @all_accounts.each {|a| @accounts_for_transfer << a if a.id != @account.id }
    end
end
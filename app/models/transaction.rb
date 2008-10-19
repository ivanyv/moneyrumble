class Transaction < ActiveRecord::Base
  belongs_to :account
  belongs_to :transferred_to, :class_name => 'Deposit', :foreign_key => 'transfer_transaction_id', :dependent => :destroy
  belongs_to :transferred_from, :class_name => 'Payment', :foreign_key => 'transfer_transaction_id'
  belongs_to :payee, :class_name => 'Contact', :foreign_key => 'other_party_id'

  before_validation :set_date
  after_save :update_account_balance
  after_destroy :update_account_balance

  @@skip_update_account_balance = false
  
  def payee_text
    s = '&lt;None&gt;'
    if transfer?
      target = Account.find(other_party_id)
      s = transfer_origin? ? "Transfer To: " : "Transfer From: "
      s += target.full_name
    else
      s = payee.name if payee
    end
    s
  end

  def transfer?
    !transfer_transaction_id.nil?
  end

  def transfer_origin?
    transfer? && attributes['type'] == 'Payment'
  end

  def transfer_target?
    !transfer_origin?
  end

  def amount
    case attributes['type']
    when 'Deposit'
      deposit
    when 'Payment'
      payment * -1
    end
  end

  def update_account_balance
    return if @@skip_update_account_balance
    
    comparison_date = date_was ? date > date_was ? date_was : date : date
    trans = account.transactions.find(:all, :conditions => "date >= '#{comparison_date}'", :order => 'date asc, id asc')
    prev = account.transactions.find(:first, :conditions => "date < '#{comparison_date}'", :order => 'id desc')
    prev = prev ? prev.running_balance : 0
    amount = 0
    sql = ''
    
    @@skip_update_account_balance = true
    trans.each do |t|
      if t.instance_of?(Deposit)
        amount = t.deposit
      elsif t.instance_of?(Payment)
        amount = t.payment * -1
      else
        amount = 0
      end
      ActiveRecord::Base.connection.execute "UPDATE transactions SET running_balance = #{prev + amount} WHERE id = #{t.id};"
      #t.update_attribute :running_balance, prev + amount
      prev += amount
    end
    @@skip_update_account_balance = false
    account.update_balance
  end

  protected
  def set_date
    self.date = Date.today unless self.date
  end
end
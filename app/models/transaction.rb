class Transaction < ActiveRecord::Base
  belongs_to :account
  belongs_to :transfer_to, :class_name => 'Transaction', :foreign_key => 'transfer_transaction_id'

  after_save :update_account_balance
  
  def payee
    'Ivan Vega Rivera'
  end

  def amount
    case attributes['type']
    when 'Deposit'
      deposit
    when 'Transfer', 'Payment'
      payment * -1
    end
  end

  protected
  def update_account_balance
    if self.instance_of?(Transfer)
      # payment == 0 means this is the receiving end of the transfer
      if payment == 0
        if deposit != transfer_to.payment.abs
          transfer_to.update_attribute :payment, deposit.abs
          transfer_to.account.update_balance
        end
      else
        if payment != transfer_to.deposit.abs
          transfer_to.update_attribute :deposit, payment.abs
          transfer_to.account.update_balance
        end
      end
    end
    account.update_balance

    comparison_date = date > date_was ? date_was : date
    trans = account.transactions.find(:all, :conditions => "date >= '#{comparison_date}'", :order => 'date asc, id asc')
    prev = account.transactions.find(:first, :conditions => "date < '#{comparison_date}'", :order => 'id desc')
    prev = prev ? prev.running_balance : 0
    amount = 0
    sql = ''
    trans.each do |t|
      if t.instance_of?(Deposit)
        amount = t.deposit
      elsif t.instance_of?(Transfer)
        # payment == 0 means this is the receiving end of the transfer
        amount = payment == 0 ? t.deposit : t.payment * -1
      elsif t.instance_of?(Payment)
        amount = t.payment * -1
      else
        amount = 0
      end
      ActiveRecord::Base.connection.execute "UPDATE transactions SET running_balance = #{prev + amount} WHERE id = #{t.id};"
      #t.update_attribute :running_balance, prev + amount
      prev += amount
    end
  end
end
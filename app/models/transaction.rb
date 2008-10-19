class Transaction < ActiveRecord::Base
  belongs_to :account

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
    case attributes['type']
    when 'Deposit'
      amount = deposit
    when 'Payment'
      amount = payment * -1
    when 'Transfer'
      amount = payment == 0 ? t.deposit : t.payment * -1
    end
    account.update_attribute :balance, account.balance + amount

    trans = account.transactions.find(:all, :conditions => "date >= '#{date}'", :order => 'id asc')
    prev = account.transactions.find(:first, :conditions => "date < '#{date}'", :order => 'id desc')
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
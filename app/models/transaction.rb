class Transaction < ActiveRecord::Base
  belongs_to :account

  def payee
    'Ivan Vega Rivera'
  end

  def balance
    rand(1000)
  end

  def payment
    rand(1000)
  end

  def deposit
    0
  end
end

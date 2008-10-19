class Account < ActiveRecord::Base
  belongs_to :parent, :class_name => 'Account'
  has_many :sub_accounts, :class_name => 'Account', :foreign_key => 'parent_id', :dependent => :nullify
  has_many :transactions
  has_many :deposits
  has_many :payments

  after_destroy :nullify_transfers

  belongs_to :owner, :class_name => 'User'

  def update_balance
    update_attribute :balance, deposits.sum(:deposit) - payments.sum(:payment)
  end

  def name_for_transfer
    "Transfer to: #{name}"
  end

  def self.demo
    accounts = []
    accounts << Account.new(:name => 'Checking', :balance => rand(10000) )
    accounts << Account.new(:name => 'Savings', :balance => rand(10000) )
    accounts[1].sub_accounts.build(:name => 'Car', :balance => rand(1000))
    accounts[1].sub_accounts.build(:name => 'New home', :balance => rand(100000))
    accounts
  end

  def transfer_to(trans, acc_id)
    acc = Account.find acc_id
    acc.deposits.new :other_party_id   => self.id,
                     :deposit          => trans.payment,
                     :date             => trans.date,
                     :notes            => trans.notes,
                     :number           => trans.number,
                     :transferred_from => trans
  end

  def full_name
    parent_id ? "#{parent.name} » #{name}" : name
  end

  protected
  def nullify_transfers
    user = User.find owner_id
    acc = Account.find :first, :conditions => { :owner_id => user.id }

    Transaction.update_all 'other_party_id = NULL, transfer_transaction_id = NULL',
      "transfer_transaction_id > 0 AND other_party_id = #{id}"
    Transaction.delete_all "account_id = #{id} OR (account_id = #{acc.id} AND payment > 0)"

    acc.update_balance

    if user.default_account == id
      acc = acc ? acc.id : nil
      user.update_attribute :default_account, acc
    end
  end
end
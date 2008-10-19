class Account < ActiveRecord::Base
  belongs_to :parent, :class_name => 'Account'
  has_many :sub_accounts, :class_name => 'Account', :foreign_key => 'parent_id', :dependent => :nullify
  has_many :transactions, :dependent => :destroy
  has_many :deposits
  has_many :payments

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
end
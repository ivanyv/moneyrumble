class Account < ActiveRecord::Base
  belongs_to :parent, :class_name => 'Account'
  has_many :sub_accounts, :class_name => 'Account', :foreign_key => 'parent_id'
  has_many :transactions

  belongs_to :owner, :class_name => 'User'

  def self.demo
    accounts = []
    accounts << Account.new(:name => 'Checking', :balance => rand(10000) )
    accounts << Account.new(:name => 'Savings', :balance => rand(10000) )
    accounts[1].sub_accounts.build(:name => 'Car', :balance => rand(1000))
    accounts[1].sub_accounts.build(:name => 'New home', :balance => rand(100000))
    accounts
  end

  def full_name
    parent_id ? "#{parent.name} &raquo #{name}" : name
  end
end
class CreateTransactions < ActiveRecord::Migration
  def self.up
    create_table :transactions do |t|
      t.integer :account_id, :null => false
      t.integer :other_party_id
      t.string :type, :limit => 10
      t.decimal :payment, :default => 0
      t.decimal :deposit, :default => 0
      t.integer :transfer_transaction_id
      t.date :date
      t.string :notes
      t.string :number
      t.decimal :running_balance

      t.timestamps
    end

    add_index :transactions, :type
  end

  def self.down
    drop_table :transactions
  end
end

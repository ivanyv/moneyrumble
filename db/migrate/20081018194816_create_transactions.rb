class CreateTransactions < ActiveRecord::Migration
  def self.up
    create_table :transactions do |t|
      t.integer :account_id
      t.integer :other_party
      t.string :type, :limit => 10
      t.decimal :payment
      t.decimal :deposit
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

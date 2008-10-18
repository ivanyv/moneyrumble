class CreateTransactions < ActiveRecord::Migration
  def self.up
    create_table :transactions do |t|
      t.integer :account_id
      t.decimal :amount
      t.date :date
      t.string :notes
      t.string :number

      t.timestamps
    end
  end

  def self.down
    drop_table :transactions
  end
end

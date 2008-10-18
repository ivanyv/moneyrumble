class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.integer :owner_id
      t.integer :parent_id
      t.decimal :balance, :default => 0
      t.decimal :global_balance, :default => 0
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :accounts
  end
end

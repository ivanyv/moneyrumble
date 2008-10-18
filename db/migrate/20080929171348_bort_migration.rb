class BortMigration < ActiveRecord::Migration
  def self.up
    # Create Sessions Table
    create_table :sessions do |t|
      t.string :session_id, :null => false
      t.text :data
      t.timestamps
    end

    add_index :sessions, :session_id
    add_index :sessions, :updated_at
    
    # Create OpenID Tables
    create_table :open_id_authentication_associations, :force => true do |t|
      t.integer :issued, :lifetime
      t.string :handle, :assoc_type
      t.binary :server_url, :secret
    end

    create_table :open_id_authentication_nonces, :force => true do |t|
      t.integer :timestamp, :null => false
      t.string :server_url, :null => true
      t.string :salt, :null => false
    end
    
    # Create Users Table
    create_table :users do |t|
      t.string :identity_url
      t.string :name, :limit => 100, :default => '', :null => true
      t.string :email, :limit => 100
      t.timestamps
    end
    
    add_index :users, :identity_url, :unique => true
  end

  def self.down
    # Drop all Bort tables
    drop_table :sessions
    drop_table :users
    drop_table :open_id_authentication_associations
    drop_table :open_id_authentication_nonces
  end
end
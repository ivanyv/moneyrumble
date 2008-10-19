# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20081018194816) do

  create_table "accounts", :force => true do |t|
    t.integer  "owner_id"
    t.integer  "parent_id"
    t.decimal  "balance",        :default => 0.0
    t.decimal  "global_balance", :default => 0.0
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "open_id_authentication_associations", :force => true do |t|
    t.integer "issued"
    t.integer "lifetime"
    t.string  "handle"
    t.string  "assoc_type"
    t.binary  "server_url"
    t.binary  "secret"
  end

  create_table "open_id_authentication_nonces", :force => true do |t|
    t.integer "timestamp",  :null => false
    t.string  "server_url"
    t.string  "salt",       :null => false
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"
  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"

  create_table "transactions", :force => true do |t|
    t.integer  "account_id",                                             :null => false
    t.integer  "other_party_id"
    t.string   "type",                    :limit => 10
    t.decimal  "payment",                               :default => 0.0
    t.decimal  "deposit",                               :default => 0.0
    t.integer  "transfer_transaction_id"
    t.date     "date"
    t.string   "notes"
    t.string   "number"
    t.decimal  "running_balance"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "transactions", ["type"], :name => "index_transactions_on_type"

  create_table "users", :force => true do |t|
    t.string   "identity_url"
    t.string   "name",                      :limit => 100, :default => ""
    t.string   "email",                     :limit => 100
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.integer  "default_account"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["identity_url"], :name => "index_users_on_identity_url", :unique => true

end

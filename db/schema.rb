# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121027203309) do

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.boolean  "isExpense"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "order"
  end

  create_table "entries", :force => true do |t|
    t.date     "date"
    t.string   "name"
    t.string   "document_number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "inventory_entries", :force => true do |t|
    t.date     "date"
    t.string   "name"
    t.string   "document_number"
    t.integer  "amount"
    t.decimal  "unit_price"
    t.string   "source"
    t.string   "stock_number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "inventory_journals", :force => true do |t|
    t.integer  "year"
    t.integer  "unit_id"
    t.boolean  "open"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "inventory_journals", ["unit_id"], :name => "index_inventory_journals_on_unit_id"

  create_table "items", :force => true do |t|
    t.decimal  "amount"
    t.decimal  "amount_one_percent"
    t.integer  "entry_id"
    t.integer  "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "journal_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "journals", :force => true do |t|
    t.integer  "year"
    t.integer  "unit_id"
    t.integer  "journal_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "units", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end

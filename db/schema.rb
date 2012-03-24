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

ActiveRecord::Schema.define(:version => 20120324162141) do

  create_table "cash_entries", :force => true do |t|
    t.date     "date"
    t.string   "name"
    t.string   "document_number"
    t.decimal  "amount"
    t.integer  "category_id"
    t.integer  "journal_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.boolean  "isExpense"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "inventory_entries", :force => true do |t|
    t.date     "date"
    t.string   "name"
    t.string   "document_number"
    t.string   "comment"
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

end

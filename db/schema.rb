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

ActiveRecord::Schema.define(:version => 20120219171442) do

  create_table "cash_entries", :force => true do |t|
    t.date     "date"
    t.string   "name"
    t.string   "document_number"
    t.string   "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "expense_cash_entries", :force => true do |t|
    t.date     "date"
    t.string   "name"
    t.string   "document_number"
    t.string   "comment"
    t.decimal  "razem"
    t.decimal  "razem_jeden_procent"
    t.decimal  "wyposazenie"
    t.decimal  "wyposazenie_jeden_procent"
    t.decimal  "materialy"
    t.decimal  "materialy_jeden_procent"
    t.decimal  "wyzywienie"
    t.decimal  "wyzywienie_jeden_procent"
    t.decimal  "uslugi"
    t.decimal  "uslugi_jeden_procent"
    t.decimal  "transport"
    t.decimal  "transport_jeden_procent"
    t.decimal  "czynsz"
    t.decimal  "czynsz_jeden_procent"
    t.decimal  "ubezpieczenie"
    t.decimal  "ubezpieczenie_jeden_procent"
    t.decimal  "inne"
    t.decimal  "inne_jeden_procent"
    t.decimal  "wynagrodzenie"
    t.decimal  "wynagrodzenie_jeden_procent"
    t.decimal  "skladki"
    t.decimal  "skladki_jeden_procent"
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

  create_table "revenue_cash_entries", :force => true do |t|
    t.date     "date"
    t.string   "name"
    t.string   "document_number"
    t.string   "comment"
    t.decimal  "razem"
    t.decimal  "darowizny"
    t.decimal  "akcje_zarobkowe"
    t.decimal  "jeden_procent"
    t.decimal  "inne"
    t.decimal  "skladki"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "units", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end

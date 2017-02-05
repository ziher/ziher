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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170205203915) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.boolean  "is_expense"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
    t.integer  "year"
    t.boolean  "is_one_percent", default: false
  end

  create_table "entries", force: :cascade do |t|
    t.date     "date"
    t.string   "name"
    t.string   "document_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "journal_id"
    t.boolean  "is_expense"
    t.integer  "linked_entry_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups_units", force: :cascade do |t|
    t.integer "group_id"
    t.integer "unit_id"
  end

  create_table "inventory_entries", force: :cascade do |t|
    t.date     "date"
    t.string   "stock_number"
    t.string   "name"
    t.string   "document_number"
    t.integer  "amount"
    t.boolean  "is_expense"
    t.decimal  "total_value",         precision: 9, scale: 2
    t.integer  "unit_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "inventory_source_id"
    t.string   "remark"
  end

  create_table "inventory_sources", force: :cascade do |t|
    t.string   "name"
    t.boolean  "is_active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "inventory_sources", ["name"], name: "index_inventory_sources_on_name", unique: true, using: :btree

  create_table "items", force: :cascade do |t|
    t.decimal  "amount",             precision: 9, scale: 2
    t.decimal  "amount_one_percent", precision: 9, scale: 2
    t.integer  "entry_id"
    t.integer  "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "journal_types", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_default", default: false
  end

  create_table "journals", force: :cascade do |t|
    t.integer  "year"
    t.integer  "unit_id"
    t.integer  "journal_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_open"
    t.decimal  "initial_balance",             precision: 9, scale: 2, default: 0.0, null: false
    t.decimal  "initial_balance_one_percent", precision: 9, scale: 2, default: 0.0, null: false
  end

  create_table "subgroups", id: false, force: :cascade do |t|
    t.integer "group_id"
    t.integer "subgroup_id"
  end

  create_table "units", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "code"
  end

  add_index "units", ["code"], name: "index_units_on_code", unique: true, using: :btree

  create_table "user_group_associations", force: :cascade do |t|
    t.integer  "group_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "can_view_entries",   default: false
    t.boolean  "can_manage_entries", default: false
    t.boolean  "can_close_journals", default: false
    t.boolean  "can_manage_users",   default: false
    t.boolean  "can_manage_units",   default: false
    t.boolean  "can_manage_groups",  default: false
  end

  create_table "user_unit_associations", force: :cascade do |t|
    t.integer "unit_id"
    t.integer "user_id"
    t.boolean "can_view_entries",   default: false
    t.boolean "can_manage_entries", default: false
    t.boolean "can_close_journals", default: false
    t.boolean "can_manage_users",   default: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
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
    t.string   "invitation_token"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.boolean  "is_superadmin",          default: false
    t.boolean  "is_blocked",             default: false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone"
    t.datetime "invitation_created_at"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", using: :btree
  add_index "users", ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end

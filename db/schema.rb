# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2025_04_12_154225) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "audits", force: :cascade do |t|
    t.integer "auditable_id"
    t.string "auditable_type"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.text "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at"
    t.index ["associated_id", "associated_type"], name: "associated_index"
    t.index ["auditable_id", "auditable_type"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.boolean "is_expense"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position"
    t.integer "year"
    t.boolean "is_one_percent", default: false
    t.integer "grant_id"
    t.index ["grant_id"], name: "index_categories_on_grant_id"
    t.index ["is_expense"], name: "index_categories_on_is_expense"
    t.index ["year"], name: "index_categories_on_year"
  end

  create_table "entries", force: :cascade do |t|
    t.date "date"
    t.string "name"
    t.string "document_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "journal_id"
    t.boolean "is_expense"
    t.integer "linked_entry_id"
    t.index ["journal_id"], name: "index_entries_on_journal_id"
  end

  create_table "grants", force: :cascade do |t|
    t.string "name", null: false
    t.text "description", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "groups", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "code"
  end

  create_table "groups_units", force: :cascade do |t|
    t.integer "group_id"
    t.integer "unit_id"
  end

  create_table "inventory_entries", force: :cascade do |t|
    t.date "date"
    t.string "stock_number"
    t.string "name"
    t.string "document_number"
    t.integer "amount"
    t.boolean "is_expense"
    t.decimal "total_value", precision: 9, scale: 2
    t.integer "unit_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "inventory_source_id"
    t.string "remark"
    t.index ["date"], name: "index_inventory_entries_on_date"
    t.index ["inventory_source_id"], name: "index_inventory_entries_on_inventory_source_id"
    t.index ["is_expense"], name: "index_inventory_entries_on_is_expense"
    t.index ["unit_id"], name: "index_inventory_entries_on_unit_id"
  end

  create_table "inventory_sources", force: :cascade do |t|
    t.string "name"
    t.boolean "is_active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_inventory_sources_on_name", unique: true
  end

  create_table "item_grants", force: :cascade do |t|
    t.integer "item_id", null: false
    t.integer "grant_id", null: false
    t.decimal "amount", precision: 9, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["grant_id"], name: "index_item_grants_on_grant_id"
    t.index ["item_id"], name: "index_item_grants_on_item_id"
  end

  create_table "items", force: :cascade do |t|
    t.decimal "amount", precision: 9, scale: 2
    t.decimal "amount_one_percent", precision: 9, scale: 2
    t.bigint "entry_id"
    t.bigint "category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_items_on_category_id"
    t.index ["entry_id"], name: "index_items_on_entry_id"
  end

  create_table "journal_grants", force: :cascade do |t|
    t.integer "journal_id", null: false
    t.integer "grant_id", null: false
    t.decimal "initial_grant_balance", precision: 9, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["grant_id"], name: "index_journal_grants_on_grant_id"
    t.index ["journal_id"], name: "index_journal_grants_on_journal_id"
  end

  create_table "journal_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_default", default: false
  end

  create_table "journals", force: :cascade do |t|
    t.integer "year"
    t.bigint "unit_id"
    t.bigint "journal_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_open"
    t.decimal "initial_balance", precision: 9, scale: 2, default: "0.0", null: false
    t.decimal "initial_balance_one_percent", precision: 9, scale: 2, default: "0.0", null: false
    t.date "blocked_to"
    t.index ["journal_type_id"], name: "index_journals_on_journal_type_id"
    t.index ["unit_id", "year", "journal_type_id"], name: "index_journals_on_unit_year_type", unique: true
    t.index ["unit_id"], name: "index_journals_on_unit_id"
    t.index ["year"], name: "index_journals_on_year"
  end

  create_table "subgroups", id: false, force: :cascade do |t|
    t.integer "group_id"
    t.integer "subgroup_id"
  end

  create_table "units", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "code"
    t.boolean "is_active", default: true, null: false
    t.index ["code"], name: "index_units_on_code", unique: true
    t.index ["is_active"], name: "index_units_on_is_active"
  end

  create_table "user_group_associations", force: :cascade do |t|
    t.integer "group_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "can_view_entries", default: false
    t.boolean "can_manage_entries", default: false
    t.boolean "can_close_journals", default: false
    t.boolean "can_manage_users", default: false
    t.boolean "can_manage_units", default: false
    t.boolean "can_manage_groups", default: false
    t.index ["group_id"], name: "index_user_group_associations_on_group_id"
    t.index ["user_id"], name: "index_user_group_associations_on_user_id"
  end

  create_table "user_unit_associations", force: :cascade do |t|
    t.integer "unit_id"
    t.integer "user_id"
    t.boolean "can_view_entries", default: false
    t.boolean "can_manage_entries", default: false
    t.boolean "can_close_journals", default: false
    t.boolean "can_manage_users", default: false
    t.index ["unit_id"], name: "index_user_unit_associations_on_unit_id"
    t.index ["user_id"], name: "index_user_unit_associations_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: ""
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "invitation_token"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.bigint "invited_by_id"
    t.boolean "is_superadmin", default: false
    t.boolean "is_blocked", default: false
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.datetime "invitation_created_at"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by_type_and_invited_by_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end

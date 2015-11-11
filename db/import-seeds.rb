# encoding: utf-8

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create!([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create!(name: 'Emanuel', city: cities.first)

finance = JournalType.create!(id: JournalType::FINANCE_TYPE_ID, name: "Książka finansowa", is_default: true)
bank = JournalType.create!(id: JournalType::BANK_TYPE_ID, name: "Książka bankowa")

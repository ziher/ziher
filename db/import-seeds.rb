# encoding: utf-8

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create!([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create!(name: 'Emanuel', city: cities.first)

user = User.create!(email: 'ziher_to@zhr.pl', password: '0xDEADBEEF', confirmed_at: '2012-03-24 22:37:00', confirmation_sent_at: '2012-03-24 22:36:09', is_superadmin: true)
user.confirm!

finance = JournalType.create!(id: JournalType::FINANCE_TYPE_ID, name: "Książka finansowa", is_default: true)
bank = JournalType.create!(id: JournalType::BANK_TYPE_ID, name: "Książka bankowa")

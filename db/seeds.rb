# encoding: utf-8

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or create!d alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create!([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create!(name: 'Emanuel', city: cities.first)

c1 = Category.create!(name: 'Darowizny', isExpense: true)
c2 = Category.create!(name: 'Akcje zarobkowe', isExpense: true)
Category.create!(name: 'Wyposazenie', isExpense: false)
Category.create!(name: 'Materialy', isExpense: false)
Category.create!(name: 'Transport', isExpense: false)
Category.create!(name: 'Wynagrodzenia', isExpense: false)

user = User.create!(email: 'ziher_to@zhr.pl', password: '0xDEADBEEF', confirmed_at: '2012-03-24 22:37:00', confirmation_sent_at: '2012-03-24 22:36:09')
user.confirm!

e1 = Entry.new(name: 'jakies entry', document_number: 'ey1')
e2 = Entry.new(name: 'jakies drugie entry', document_number: 'ntr2')

item1 = Item.create!(amount: 5, category_id: c1.id, entry_id: e1.id)
item2 = Item.create!(amount: 7, category_id: c2.id, entry_id: e2.id)
item3 = Item.create!(amount: 3, category_id: c1.id, entry_id: e2.id)
item4 = Item.create!(amount: 11, category_id: c2.id, entry_id: e1.id)

e1.items << item1
e2.items << item2
e1.save!
e2.save!

JournalType.create!(name: "Książka finansowa")
JournalType.create!(name: "Książka bankowa")

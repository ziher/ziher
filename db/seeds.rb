# encoding: utf-8

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or create!d alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create!([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create!(name: 'Emanuel', city: cities.first)

c1 = Category.create!(name: 'Darowizny', is_expense: false, year: 2012)
c2 = Category.create!(name: 'Akcje zarobkowe', is_expense: false, year: 2012)
c3 = Category.create!(name: 'Transport', is_expense: true, year: 2012)
c4 = Category.create!(name: 'Wyposazenie', is_expense: true, year: 2012)
c5 = Category.create!(name: 'Materialy', is_expense: true, year: 2012)
Category.create!(name: 'Wynagrodzenia', is_expense: true, year: 2012)
Category.create!(name: 'Wynagrodzenia', is_expense: true, year: 2011)
Category.create!(name: 'Wyposazenie', is_expense: true, year: 2011)

unit1 = Unit.create!(name: 'Jedrkowa')

user = User.create!(email: 'ziher_to@zhr.pl', password: '0xDEADBEEF', confirmed_at: '2012-03-24 22:37:00', confirmation_sent_at: '2012-03-24 22:36:09', is_superadmin: true)
user.confirm!
user2 = User.create!(email: 'jedrek@localhost.localdomain', password: 'jedrek', confirmed_at: '2012-11-24 23:14:00', confirmation_sent_at: '2012-11-24 23:13:00', is_superadmin: false)
user2.confirm!

user2.units = [unit1]

e1 = Entry.new(name: 'entry 1: darowizna', document_number: 'ey1')
e2 = Entry.new(name: 'entry 2: akcja, material', document_number: 'ntr2')
e3 = Entry.new(name: 'entry 3: wyposazenie', document_number: 'fv4')
e4 = Entry.new(name: 'entry 4: transport', document_number: 'trnsprtdrwn')
e5 = Entry.new(name: 'entry 5: darowizna, wyposazenie', document_number: 'dar34')

item1 = Item.create!(amount: 1, category_id: c1.id, entry_id: e1.id)
item2 = Item.create!(amount: 2, category_id: c2.id, entry_id: e2.id)
item3 = Item.create!(amount: 3, category_id: c5.id, entry_id: e2.id)
item4 = Item.create!(amount: 4, category_id: c4.id, entry_id: e3.id)
item5 = Item.create!(amount: 5, category_id: c3.id, entry_id: e4.id)
item6 = Item.create!(amount: 6, category_id: c1.id, entry_id: e5.id)
item7 = Item.create!(amount: 7, category_id: c4.id, entry_id: e5.id)

e1.items << item1
e2.items << item2
e2.items << item3
e3.items << item4
e4.items << item5
e5.items << item6
e5.items << item7
e1.save!
e2.save!
e3.save!
e4.save!
e5.save!

type1 = JournalType.create!(name: "Książka finansowa")
JournalType.create!(name: "Książka bankowa")

journal1 = Journal.create!(year: 2012, journal_type: type1)
journal2 = Journal.create!(year: 2012, journal_type: type1)
journal1.entries = [e1, e2, e3]
journal2.entries = [e4, e5]
journal1.save!
journal2.save!

# encoding: utf-8

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
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
c6 = Category.create!(name: 'Wynagrodzenia', is_expense: true, year: 2012)
c7_2011 = Category.create!(name: 'Wynagrodzenia', is_expense: true, year: 2011)
c8_2011 = Category.create!(name: 'Wyposazenie', is_expense: true, year: 2011)
c9_2011 = Category.create!(name: 'Akcje zarobkowe', is_expense: false, year: 2011)

dukt = Unit.create!(name: '9 ZDH Dukt')
pajaki = Unit.create!(name: '31 DH Pająki')
wiklina = Unit.create!(name: '9 ZDH Wiklina')
orleta = Unit.create!(name: '30 DH Orlęta')
wigryk = Unit.create!(name: '45 ŻDH Wigry')


zhhy = Group.create!(name: 'Zielonogórski Hufiec Harcerzy', units: [dukt, pajaki])
zhhek = Group.create!(name: 'Zielonogórski Hufiec Harcerek', units: [wiklina, orleta, wigryk])
obwzg = Group.create!(name: 'Obwód Zielonogórski', subgroups: [zhhy, zhhek])
wchhy = Group.create!(name: 'Wielkopolska Chorągiew Harcerzy', subgroups: [zhhy])
wchhek = Group.create!(name: 'Wielkopolska Chorągiew Harcerek', subgroups: [zhhek])
okrwlkp = Group.create!(name: 'Okręg Wielkopolski', subgroups: [wchhy, wchhek])

user = User.create!(email: 'ziher_to@zhr.pl', password: '0xDEADBEEF', confirmed_at: '2012-03-24 22:37:00', confirmation_sent_at: '2012-03-24 22:36:09', is_superadmin: true)
user.confirm!
hufcowyzg = User.create!(email: 'hufcowy_zg@zhr.com', password: 'hufcowy_zg@zhr.com', confirmed_at: '2013-02-23 20:02:00', confirmation_sent_at: '2013-02-23 20:00:00', groups: [zhhy])
hufcowyzg.confirm!
hufcowazg = User.create!(email: 'hufcowa_zg@zhr.com', password: 'hufcowa_zg@zhr.com', confirmed_at: '2013-02-23 20:02:00', confirmation_sent_at: '2013-02-23 20:00:00', groups: [zhhek])
hufcowazg.confirm!

type1 = JournalType.create!(name: "Książka finansowa", is_default: true)
type2 = JournalType.create!(name: "Książka bankowa")

journal1 = Journal.create!(year: 2012, journal_type: type1, is_open: true)
journal2 = Journal.create!(year: 2011, journal_type: type2, is_open: true)
journal1.save!
journal2.save!

e1 = Entry.new(name: 'entry 1: darowizna', document_number: 'ey1', journal_id: journal1.id)
e2 = Entry.new(name: 'entry 2: akcja, material', document_number: 'ntr2', journal_id: journal1.id)
e3 = Entry.new(name: 'entry 3: wyposazenie', document_number: 'fv4', journal_id: journal1.id)
e4 = Entry.new(name: 'entry 4: transport', document_number: 'trnsprtdrwn', journal_id: journal2.id)
e5 = Entry.new(name: 'entry 5: darowizna, wyposazenie', document_number: 'dar34', journal_id: journal2.id)

item1 = Item.create!(amount: 1, category_id: c1.id)
item2 = Item.create!(amount: 2, category_id: c2.id)
item3 = Item.create!(amount: 3, category_id: c1.id)
item4 = Item.create!(amount: 4, category_id: c4.id)
item5 = Item.create!(amount: 5, category_id: c7_2011.id)
item6 = Item.create!(amount: 6, category_id: c7_2011.id)
item7 = Item.create!(amount: 7, category_id: c8_2011.id)

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

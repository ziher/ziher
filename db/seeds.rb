# encoding: utf-8

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create!([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create!(name: 'Emanuel', city: cities.first)

darowizny_2011 = Category.create!(name: 'Darowizny', is_expense: false, year: 2012)
akcje_zarobkowe_2012 = Category.create!(name: 'Akcje zarobkowe', is_expense: false, year: 2012)
transport_2012 = Category.create!(name: 'Transport', is_expense: true, year: 2012)
wyposazenie_2012 = Category.create!(name: 'Wyposazenie', is_expense: true, year: 2012)
materialy_2012 = Category.create!(name: 'Materialy', is_expense: true, year: 2012)
wynagrodzenia_2012 = Category.create!(name: 'Wynagrodzenia', is_expense: true, year: 2012)
wynagrodzenia_2011 = Category.create!(name: 'Wynagrodzenia', is_expense: true, year: 2011)
wyposazenie_2011 = Category.create!(name: 'Wyposazenie', is_expense: true, year: 2011)
akcje_zarobkowe_2011 = Category.create!(name: 'Akcje zarobkowe', is_expense: false, year: 2011)

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
journal2 = Journal.create!(year: 2011, journal_type: type2, is_open: true, initial_balance: 12.34)
journal1.save!
journal2.save!

darowizna = Entry.new(name: 'entry 1: darowizna', document_number: 'ey1', journal: journal1, is_expense: false)
akcja_i_darowizna = Entry.new(name: 'entry 2: akcja, darowizna', document_number: 'ntr2', journal: journal1, is_expense: false)
wyposazenie = Entry.new(name: 'entry 3: wyposazenie', document_number: 'fv4', journal: journal1, is_expense: true)
transport = Entry.new(name: 'entry 4: transport', document_number: 'trnsprtdrwn', journal: journal2, is_expense: false)
wynagrodzenie_i_wyposazenie = Entry.new(name: 'entry 5: darowizna, wyposazenie', document_number: 'dar34', journal: journal2, is_expense: true)

darowizna.items << Item.create!(amount: 1, category: darowizny_2011)
akcja_i_darowizna.items << Item.create!(amount: 2, category: akcje_zarobkowe_2012)
akcja_i_darowizna.items << Item.create!(amount: 3, category: darowizny_2011)
wyposazenie.items << Item.create!(amount: 4, category: wyposazenie_2012)
transport.items << Item.create!(amount: 5, category: wynagrodzenia_2011)
wynagrodzenie_i_wyposazenie.items << Item.create!(amount: 6, category: wynagrodzenia_2011)
wynagrodzenie_i_wyposazenie.items << Item.create!(amount: 7, category: wyposazenie_2011)

darowizna.save!
akcja_i_darowizna.save!
wyposazenie.save!
transport.save!
wynagrodzenie_i_wyposazenie.save!

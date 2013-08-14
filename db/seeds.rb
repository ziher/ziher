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

druzynowy_dukt = User.create!(email: 'druzynowy_dukt@zhr.com', password: 'druzynowy_dukt@zhr.com', confirmed_at: '2013-02-23 20:02:00', confirmation_sent_at: '2013-02-23 20:00:00')
druzynowy_dukt.confirm!
UserUnitAssociation.create!(user: druzynowy_dukt, unit: dukt, can_view_entries: true, can_manage_entries: true)
UserUnitAssociation.create!(user: druzynowy_dukt, unit: pajaki, can_view_entries: true)

druzynowy_pajaki = User.create!(email: 'druzynowy_pajaki@zhr.com', password: 'druzynowy_pajaki@zhr.com', confirmed_at: '2013-02-23 20:02:00', confirmation_sent_at: '2013-02-23 20:00:00')
druzynowy_pajaki.confirm!
UserUnitAssociation.create!(user: druzynowy_pajaki, unit: pajaki, can_view_entries: true, can_manage_entries: true)

druzynowa_wiklina = User.create!(email: 'druzynowa_wiklina@zhr.com', password: 'druzynowa_wiklina@zhr.com', confirmed_at: '2013-02-23 20:02:00', confirmation_sent_at: '2013-02-23 20:00:00')
druzynowa_wiklina.confirm!
UserUnitAssociation.create!(user: druzynowa_wiklina, unit: wiklina, can_view_entries: true, can_manage_entries: true)

druzynowa_orleta = User.create!(email: 'druzynowa_orleta@zhr.com', password: 'druzynowa_orleta@zhr.com', confirmed_at: '2013-02-23 20:02:00', confirmation_sent_at: '2013-02-23 20:00:00')
druzynowa_orleta.confirm!
UserUnitAssociation.create!(user: druzynowa_orleta, unit: orleta, can_view_entries: true, can_manage_entries: true)

druzynowa_wigryk = User.create!(email: 'druzynowa_wigryk@zhr.com', password: 'druzynowa_wigryk@zhr.com', confirmed_at: '2013-02-23 20:02:00', confirmation_sent_at: '2013-02-23 20:00:00')
druzynowa_wigryk.confirm!
UserUnitAssociation.create!(user: druzynowa_wigryk, unit: wigryk, can_view_entries: true, can_manage_entries: true)

hufcowyzg = User.create!(email: 'hufcowy_zg@zhr.com', password: 'hufcowy_zg@zhr.com', confirmed_at: '2013-02-23 20:02:00', confirmation_sent_at: '2013-02-23 20:00:00')
hufcowyzg.confirm!
UserGroupAssociation.create!(user: hufcowyzg, group: zhhy, can_view_entries: true)

hufcowazg = User.create!(email: 'hufcowa_zg@zhr.com', password: 'hufcowa_zg@zhr.com', confirmed_at: '2013-02-23 20:02:00', confirmation_sent_at: '2013-02-23 20:00:00')
hufcowazg.confirm!
UserGroupAssociation.create!(user: hufcowazg, group: zhhek, can_view_entries: true)

skarbnik_okrwlkp = User.create!(email: 'skarbnik_okrwlkp@zhr.com', password: 'skarbnik_okrwlkp@zhr.com', confirmed_at: '2013-02-23 20:02:00', confirmation_sent_at: '2013-02-23 20:00:00')
skarbnik_okrwlkp.confirm!
UserGroupAssociation.create!(user: skarbnik_okrwlkp, group: okrwlkp, can_view_entries: true, can_manage_entries: true, can_close_journals: true, can_manage_users: true, can_manage_units: true)

finance = JournalType.create!(name: "Książka finansowa", is_default: true)
bank = JournalType.create!(name: "Książka bankowa")

dukt2010f = Journal.create!(year: 2010, journal_type: finance, unit: dukt, is_open: false)
dukt2010b = Journal.create!(year: 2010, journal_type: bank, unit: dukt, is_open: false)
dukt2011f = Journal.create!(year: 2011, journal_type: finance, unit: dukt, is_open: false)
dukt2011b = Journal.create!(year: 2011, journal_type: bank, unit: dukt, is_open: false)
dukt2012f = Journal.create!(year: 2012, journal_type: finance, unit: dukt, is_open: true)
dukt2012b = Journal.create!(year: 2012, journal_type: bank, unit: dukt, is_open: true)
pajaki2010f = Journal.create!(year: 2010, journal_type: finance, unit: pajaki, is_open: false)
pajaki2010b = Journal.create!(year: 2010, journal_type: bank, unit: pajaki, is_open: false)
pajaki2011f = Journal.create!(year: 2011, journal_type: finance, unit: pajaki, is_open: false)
pajaki2011b = Journal.create!(year: 2011, journal_type: bank, unit: pajaki, is_open: false)
wiklina1997f = Journal.create!(year: 1997, journal_type: finance, unit: wiklina, is_open: false)
wiklina1997b = Journal.create!(year: 1997, journal_type: bank, unit: wiklina, is_open: false)
wiklina1998f = Journal.create!(year: 1998, journal_type: finance, unit: wiklina, is_open: false)
wiklina1998b = Journal.create!(year: 1998, journal_type: bank, unit: wiklina, is_open: false)
wigryk2011f = Journal.create!(year: 2011, journal_type: finance, unit: wigryk, is_open: true, initial_balance: 12.34)
wigryk2011b = Journal.create!(year: 2011, journal_type: bank, unit: wigryk, is_open: true, initial_balance: 12.34)

darowizna = Entry.new(name: 'entry 1: darowizna', document_number: 'ey1', journal: dukt2012f, is_expense: false)
akcja_i_darowizna = Entry.new(name: 'entry 2: akcja, darowizna', document_number: 'ntr2', journal: dukt2012f, is_expense: false)
wyposazenie = Entry.new(name: 'entry 3: wyposazenie', document_number: 'fv4', journal: dukt2012f, is_expense: true)
transport = Entry.new(name: 'entry 4: transport', document_number: 'trnsprtdrwn', journal: wigryk2011b, is_expense: false)
wynagrodzenie_i_wyposazenie = Entry.new(name: 'entry 5: darowizna, wyposazenie', document_number: 'dar34', journal: wigryk2011b, is_expense: true)

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

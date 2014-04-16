# encoding: utf-8

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create!([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create!(name: 'Emanuel', city: cities.first)

darowizny_1997 = Category.create!(name: 'Darowizny', is_expense: false, year: 1997)
akcje_zarobkowe_1997 = Category.create!(name: 'Akcje zarobkowe', is_expense: false, year: 1997)
wynagrodzenia_1997 = Category.create!(name: 'Wynagrodzenia', is_expense: true, year: 1997)
wyposazenie_1997 = Category.create!(name: 'Wyposazenie', is_expense: true, year: 1997)

darowizny_1998 = Category.create!(name: 'Darowizny', is_expense: false, year: 1998)
akcje_zarobkowe_1998 = Category.create!(name: 'Akcje zarobkowe', is_expense: false, year: 1998)
wynagrodzenia_1998 = Category.create!(name: 'Wynagrodzenia', is_expense: true, year: 1998)
wyposazenie_1998 = Category.create!(name: 'Wyposazenie', is_expense: true, year: 1998)

darowizny_2010 = Category.create!(name: 'Darowizny', is_expense: false, year: 2010)
akcje_zarobkowe_2010 = Category.create!(name: 'Akcje zarobkowe', is_expense: false, year: 2010)
wynagrodzenia_2010 = Category.create!(name: 'Wynagrodzenia', is_expense: true, year: 2010)
wyposazenie_2010 = Category.create!(name: 'Wyposazenie', is_expense: true, year: 2010)

darowizny_2011 = Category.create!(name: 'Darowizny', is_expense: false, year: 2011)
akcje_zarobkowe_2011 = Category.create!(name: 'Akcje zarobkowe', is_expense: false, year: 2011)
wynagrodzenia_2011 = Category.create!(name: 'Wynagrodzenia', is_expense: true, year: 2011)
wyposazenie_2011 = Category.create!(name: 'Wyposazenie', is_expense: true, year: 2011)

pozostale_2012 = Category.create!(name: 'Pozostałe', is_expense: false, year: 2012)
skladki_2012 = Category.create!(name: 'Składki', is_expense: false, year: 2012)
darowizny_2012 = Category.create!(name: 'Darowizny', is_expense: false, year: 2012)
akcje_zarobkowe_2012 = Category.create!(name: 'Akcje zarobkowe', is_expense: false, year: 2012)
jeden_procent_2012 = Category.create!(name: '1%', is_expense: false, is_one_percent: true, year: 2012)

transport_2012 = Category.create!(name: 'Transport', is_expense: true, year: 2012)
wyposazenie_2012 = Category.create!(name: 'Wyposażenie', is_expense: true, year: 2012)
materialy_2012 = Category.create!(name: 'Materiały', is_expense: true, year: 2012)
wynagrodzenia_2012 = Category.create!(name: 'Wynagrodzenia', is_expense: true, year: 2012)
uslugi_2012 = Category.create!(name: 'Usługi', is_expense: true, year: 2012)
ubezpieczenia_2012 = Category.create!(name: 'Ubezpieczenia', is_expense: true, year: 2012)
wyzywienie_2012 = Category.create!(name: 'Wyżywienie', is_expense: true, year: 2012)
skladki_2012 = Category.create!(name: 'Składki', is_expense: true, year: 2012)
inne_2012 = Category.create!(name: 'Inne', is_expense: true, year: 2012)
czynsz_2012 = Category.create!(name: 'Czynsz, energia', is_expense: true, year: 2012)

pozostale_2013 = Category.create!(name: 'Pozostałe', is_expense: false, year: 2013)
skladki_2013 = Category.create!(name: 'Składki', is_expense: false, year: 2013)
darowizny_2013 = Category.create!(name: 'Darowizny', is_expense: false, year: 2013)
akcje_zarobkowe_2013 = Category.create!(name: 'Akcje zarobkowe', is_expense: false, year: 2013)
jeden_procent_2013 = Category.create!(name: '1%', is_expense: false, is_one_percent: true, year: 2013)

transport_2013 = Category.create!(name: 'Transport', is_expense: true, year: 2013)
wyposazenie_2013 = Category.create!(name: 'Wyposażenie', is_expense: true, year: 2013)
materialy_2013 = Category.create!(name: 'Materiały', is_expense: true, year: 2013)
wynagrodzenia_2013 = Category.create!(name: 'Wynagrodzenia', is_expense: true, year: 2013)
uslugi_2013 = Category.create!(name: 'Usługi', is_expense: true, year: 2013)
ubezpieczenia_2013 = Category.create!(name: 'Ubezpieczenia', is_expense: true, year: 2013)
wyzywienie_2013 = Category.create!(name: 'Wyżywienie', is_expense: true, year: 2013)
skladki_2013 = Category.create!(name: 'Składki', is_expense: true, year: 2013)
inne_2013 = Category.create!(name: 'Inne', is_expense: true, year: 2013)
czynsz_2013 = Category.create!(name: 'Czynsz, energia', is_expense: true, year: 2013)

pozostale_2014 = Category.create!(name: 'Pozostałe', is_expense: false, year: 2014)
skladki_2014 = Category.create!(name: 'Składki', is_expense: false, year: 2014)
darowizny_2014 = Category.create!(name: 'Darowizny', is_expense: false, year: 2014)
akcje_zarobkowe_2014 = Category.create!(name: 'Akcje zarobkowe', is_expense: false, year: 2014)
jeden_procent_2014 = Category.create!(name: '1%', is_expense: false, is_one_percent: true, year: 2014)

transport_2014 = Category.create!(name: 'Transport', is_expense: true, year: 2014)
wyposazenie_2014 = Category.create!(name: 'Wyposażenie', is_expense: true, year: 2014)
materialy_2014 = Category.create!(name: 'Materiały', is_expense: true, year: 2014)
wynagrodzenia_2014 = Category.create!(name: 'Wynagrodzenia', is_expense: true, year: 2014)
uslugi_2014 = Category.create!(name: 'Usługi', is_expense: true, year: 2014)
ubezpieczenia_2014 = Category.create!(name: 'Ubezpieczenia', is_expense: true, year: 2014)
wyzywienie_2014 = Category.create!(name: 'Wyżywienie', is_expense: true, year: 2014)
skladki_2014 = Category.create!(name: 'Składki', is_expense: true, year: 2014)
inne_2014 = Category.create!(name: 'Inne', is_expense: true, year: 2014)
czynsz_2014 = Category.create!(name: 'Czynsz, energia', is_expense: true, year: 2014)

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

wrch1 = Unit.create!(name: '1 Wrocławska Drużyna Harcerzy')
wrch2 = Unit.create!(name: '2 Wrocławska Drużyna Harcerzy')
wrdz1 = Unit.create!(name: '1 Wrocławska Drużyna Harcerek')
wrdz2 = Unit.create!(name: '2 Wrocławska Drużyna Harcerek')
wrhhy = Group.create!(name: 'Wrocławski Hufiec Harcerzy', units: [wrch1, wrch2])
wrhhek = Group.create!(name: 'Wrocławski Hufiec Harcerek', units: [wrdz1, wrdz2])
dchhy = Group.create!(name: 'Dolnośląska Chorągiew Harcerzy', subgroups: [wrhhy])
dchhek = Group.create!(name: 'Dolnośląska Chorągiew Harcerek', subgroups: [wrhhek])
okrdln = Group.create!(name: 'Okręg Dolnośląski', subgroups: [dchhy, dchhek])

zhr = Group.create!(name: 'Związek Harcerstwa Rzeczypospolitej', subgroups: [okrwlkp, okrdln])

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
UserUnitAssociation.create!(user: hufcowyzg, unit: dukt, can_view_entries: true, can_manage_entries: true)

hufcowazg = User.create!(email: 'hufcowa_zg@zhr.com', password: 'hufcowa_zg@zhr.com', confirmed_at: '2013-02-23 20:02:00', confirmation_sent_at: '2013-02-23 20:00:00')
hufcowazg.confirm!
UserGroupAssociation.create!(user: hufcowazg, group: zhhek, can_view_entries: true)
UserUnitAssociation.create!(user: hufcowazg, unit: orleta, can_view_entries: true, can_manage_entries: true)

skarbnik_okrwlkp = User.create!(email: 'skarbnik_okrwlkp@zhr.com', password: 'skarbnik_okrwlkp@zhr.com', confirmed_at: '2013-02-23 20:02:00', confirmation_sent_at: '2013-02-23 20:00:00')
skarbnik_okrwlkp.confirm!
UserGroupAssociation.create!(user: skarbnik_okrwlkp, group: okrwlkp, can_view_entries: true, can_manage_entries: true, can_close_journals: true, can_manage_users: true, can_manage_units: true, can_manage_groups: true)

druzynowy_wrch1 = User.create!(email: 'druzynowy_wrch1@zhr.com', password: 'druzynowy_wrch1@zhr.com', confirmed_at: '2013-08-26 01:01:01', confirmation_sent_at: '2013-08-26 20:00:00')
druzynowy_wrch1.confirm!
UserUnitAssociation.create!(user: druzynowy_wrch1, unit: wrch1, can_view_entries: true, can_manage_entries: true)

druzynowy_wrch2 = User.create!(email: 'druzynowy_wrch2@zhr.com', password: 'druzynowy_wrch2@zhr.com', confirmed_at: '2013-08-26 01:01:01', confirmation_sent_at: '2013-08-26 20:00:00')
druzynowy_wrch2.confirm!
UserUnitAssociation.create!(user: druzynowy_wrch2, unit: wrch2, can_view_entries: true, can_manage_entries: true)

druzynowa_wrdz1 = User.create!(email: 'druzynowa_wrdz1@zhr.com', password: 'druzynowa_wrdz1@zhr.com', confirmed_at: '2013-08-26 01:01:01', confirmation_sent_at: '2013-08-26 20:00:00')
druzynowa_wrdz1.confirm!
UserUnitAssociation.create!(user: druzynowa_wrdz1, unit: wrdz1, can_view_entries: true, can_manage_entries: true)

druzynowa_wrdz2 = User.create!(email: 'druzynowa_wrdz2@zhr.com', password: 'druzynowa_wrdz2@zhr.com', confirmed_at: '2013-08-26 01:01:01', confirmation_sent_at: '2013-08-26 20:00:00')
druzynowa_wrdz2.confirm!
UserUnitAssociation.create!(user: druzynowa_wrdz2, unit: wrdz2, can_view_entries: true, can_manage_entries: true)

hufcowywr = User.create!(email: 'hufcowy_wr@zhr.com', password: 'hufcowy_wr@zhr.com', confirmed_at: '2013-02-23 20:02:00', confirmation_sent_at: '2013-02-23 20:00:00')
hufcowywr.confirm!
UserGroupAssociation.create!(user: hufcowywr, group: wrhhy, can_view_entries: true)

hufcowawr = User.create!(email: 'hufcowa_wr@zhr.com', password: 'hufcowa_wr@zhr.com', confirmed_at: '2013-02-23 20:02:00', confirmation_sent_at: '2013-02-23 20:00:00')
hufcowawr.confirm!
UserGroupAssociation.create!(user: hufcowawr, group: wrhhek, can_view_entries: true)

skarbnik_okrdln = User.create!(email: 'skarbnik_okrdln@zhr.com', password: 'skarbnik_okrdln@zhr.com', confirmed_at: '2013-02-23 20:02:00', confirmation_sent_at: '2013-02-23 20:00:00')
skarbnik_okrdln.confirm!
UserGroupAssociation.create!(user: skarbnik_okrdln, group: okrdln, can_view_entries: true, can_manage_entries: true, can_close_journals: true, can_manage_users: true, can_manage_units: true, can_manage_groups: true)

skarbnik_zachodu = User.create!(email: 'skarbnik_zachodu@zhr.com', password: 'skarbnik_zachodu@zhr.com', confirmed_at: '2013-02-23 20:02:00', confirmation_sent_at: '2013-02-23 20:00:00')
skarbnik_zachodu.confirm!
UserGroupAssociation.create!(user: skarbnik_zachodu, group: okrwlkp, can_view_entries: true, can_manage_entries: true, can_close_journals: true, can_manage_users: true, can_manage_units: false, can_manage_groups: false)
UserGroupAssociation.create!(user: skarbnik_zachodu, group: okrdln, can_view_entries: true, can_manage_entries: true, can_close_journals: true, can_manage_users: true, can_manage_units: true, can_manage_groups: true)

finance = JournalType.create!(name: "Książka finansowa", is_default: true)
bank = JournalType.create!(name: "Książka bankowa")

dukt2010f = Journal.create!(year: 2010, journal_type: finance, unit: dukt, is_open: false, initial_balance: 9.00, initial_balance_one_percent: 9.00)
dukt2010b = Journal.create!(year: 2010, journal_type: bank, unit: dukt, is_open: false)
dukt2011f = Journal.create!(year: 2011, journal_type: finance, unit: dukt, is_open: false)
dukt2011b = Journal.create!(year: 2011, journal_type: bank, unit: dukt, is_open: false)
dukt2012f = Journal.create!(year: 2012, journal_type: finance, unit: dukt, is_open: true, initial_balance: 9.00, initial_balance_one_percent: 6.00)
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

darowizna = Entry.new(date: '2012-01-01', name: 'entry 1: darowizna', document_number: 'ey1', journal: dukt2012f, is_expense: false)
akcja_i_darowizna = Entry.new(date: '2012-01-01', name: 'entry 2: akcja, darowizna', document_number: 'ntr2', journal: dukt2012f, is_expense: false)
wyposazenie = Entry.new(date: '2012-01-01', name: 'entry 3: wyposazenie', document_number: 'fv4', journal: dukt2012f, is_expense: true)
transport = Entry.new(date: '2011-01-01', name: 'entry 4: transport', document_number: 'trnsprtdrwn', journal: wigryk2011b, is_expense: false)
wynagrodzenie_i_wyposazenie = Entry.new(date: '2011-01-01', name: 'entry 5: darowizna, wyposazenie', document_number: 'dar34', journal: wigryk2011b, is_expense: true)

darowizna.items << Item.create!(amount: 1, category: darowizny_2012)
akcja_i_darowizna.items << Item.create!(amount: 2, category: akcje_zarobkowe_2012)
akcja_i_darowizna.items << Item.create!(amount: 3, category: darowizny_2012)
wyposazenie.items << Item.create!(amount: 4, amount_one_percent: 2, category: wyposazenie_2012)
wyposazenie.items << Item.create!(amount: 3, amount_one_percent: 1, category: uslugi_2012)
transport.items << Item.create!(amount: 5, category: wynagrodzenia_2011)
wynagrodzenie_i_wyposazenie.items << Item.create!(amount: 6, category: wynagrodzenia_2011)
wynagrodzenie_i_wyposazenie.items << Item.create!(amount: 7, category: wyposazenie_2011)

darowizna.save!
akcja_i_darowizna.save!
wyposazenie.save!
transport.save!
wynagrodzenie_i_wyposazenie.save!

zrodlo_finansowe = InventorySource.create!(name: "ks. finansowa", is_active: true)
zrodlo_bankowe = InventorySource.create!(name: "ks. bankowa", is_active: true)

wpis_inwentarzowy = InventoryEntry.create!(date: '2011-01-02', stock_number: "symbol", name: "nazwa", document_number: "numer dokumentu", amount: 3, is_expense: false, total_value: 10, comment: "komentarz", unit: dukt, inventory_source: zrodlo_finansowe)
wpis_inwentarzowy = InventoryEntry.create!(date: '2011-02-01', stock_number: "symbol", name: "nazwa", document_number: "numer dokumentu", amount: 3, is_expense: true, total_value: 10, comment: "komentarz", unit: dukt, inventory_source: zrodlo_bankowe)

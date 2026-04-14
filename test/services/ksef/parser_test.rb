require 'test_helper'

class Ksef::ParserTest < ActiveSupport::TestCase
  def fixture_xml(name)
    File.read(Rails.root.join("test/fixtures/files/ksef/#{name}"))
  end

  test "parses FA(3) fixture into a Document" do
    doc = Ksef::Parser.parse(fixture_xml("sample_fa3_full.xml"))

    assert_equal "FA(3)",  doc.schema_version
    assert_equal "FA (3)", doc.naglowek.kod_systemowy
    assert_equal "1-0E",   doc.naglowek.wersja_schemy
    assert_equal "Ziher test suite", doc.naglowek.system_info

    assert_equal "5265877635", doc.sprzedawca.nip
    assert_equal "Bartkowiak, Dróżdż and Górecki Sp. z o.o.", doc.sprzedawca.nazwa
    assert_equal "PL", doc.sprzedawca.prefiks_podatnika
    assert_equal "ul. Kępa 332", doc.sprzedawca.adres.adres_l1
    assert_equal [{ email: "biuro@bdg.example", telefon: "17-756-90-14" }], doc.sprzedawca.dane_kontaktowe.entries

    assert_equal "6808208874",         doc.nabywca.nip
    assert_equal "ZHR Hufiec Testowy", doc.nabywca.nazwa
    assert_equal "KL-7615",            doc.nabywca.nr_klienta

    fa = doc.fa
    assert_equal "PLN",                     fa.kod_waluty
    assert_equal "FA/YUCFO-4342344706/03/2026", fa.p_2
    assert_equal Date.new(2026, 3, 15),     fa.issue_date
    assert_equal Date.new(2026, 3, 10),     fa.sale_date
    assert_equal BigDecimal("1000.00"),     fa.net_amount
    assert_equal BigDecimal("1430.00"),     fa.gross_amount
    assert_equal "VAT",                     fa.rodzaj_faktury
    assert_not fa.korekta?
  end

  test "parses FA(3) tax summary buckets" do
    doc = Ksef::Parser.parse(fixture_xml("sample_fa3_full.xml"))
    rows = doc.fa.tax_summary

    assert_equal 2, rows.size

    bucket23 = rows.find { |r| r[:label] == "23% lub 22%" }
    assert_equal BigDecimal("1000.00"), bucket23[:net]
    assert_equal BigDecimal("230.00"),  bucket23[:tax]
    assert_equal BigDecimal("1230.00"), bucket23[:gross]

    zwolnione = rows.find { |r| r[:label] == "zwolnione od podatku" }
    assert_equal BigDecimal("200.00"), zwolnione[:net]
    assert_equal BigDecimal("0"),      zwolnione[:tax]
    assert_equal BigDecimal("200.00"), zwolnione[:gross]
  end

  test "parses FA(3) wiersze" do
    doc = Ksef::Parser.parse(fixture_xml("sample_fa3_full.xml"))
    wiersze = doc.fa.wiersze

    assert_equal 3, wiersze.size
    assert_equal "1", wiersze.first[:nr]
    assert_equal "Materiały szkoleniowe", wiersze.first[:nazwa]
    assert_equal "szt.", wiersze.first[:miara]
    assert_equal "10",   wiersze.first[:ilosc]
    assert_equal "500.00", wiersze.first[:wartosc_netto]
    assert_equal "23", wiersze.first[:stawka]
    assert_equal "zw", wiersze.last[:stawka]
  end

  test "parses Adnotacje and Platnosc" do
    doc = Ksef::Parser.parse(fixture_xml("sample_fa3_full.xml"))

    adn = doc.fa.adnotacje
    assert adn.present?
    assert_equal "2", adn.p_16
    assert_equal "1", adn.zwolnienie[:p_19n]
    assert_equal "1", adn.pmarzy[:p_pmarzyn]

    platnosc = doc.fa.platnosc
    assert platnosc.present?
    assert_equal "6", platnosc.forma_platnosci
    assert_equal "2", platnosc.zaplacono
    assert_equal [{ termin: "2026-03-29" }], platnosc.terminy_platnosci
    assert_equal [{ nr_rb: "PL61109010140000071219812874", nazwa_banku: "Bank Testowy SA" }], platnosc.rachunki_bankowe
  end

  test "persistence_attrs returns legacy shape" do
    doc = Ksef::Parser.parse(fixture_xml("sample_fa3_full.xml"))
    attrs = Ksef::Parser.persistence_attrs(doc)

    assert_equal "5265877635", attrs[:seller_nip]
    assert_equal "Bartkowiak, Dróżdż and Górecki Sp. z o.o.", attrs[:seller_name]
    assert_equal "6808208874", attrs[:buyer_nip]
    assert_equal "FA/YUCFO-4342344706/03/2026", attrs[:invoice_number]
    assert_equal Date.new(2026, 3, 15), attrs[:issue_date]
    assert_equal BigDecimal("1000.00"), attrs[:net_amount]
    assert_equal BigDecimal("1430.00"), attrs[:gross_amount]
    assert_equal "PLN", attrs[:currency]
    assert_equal({ "schema_version" => "FA(3)" }, attrs[:metadata])
  end

  test "raises on XML without default namespace" do
    assert_raises(ArgumentError) { Ksef::Parser.parse("<Faktura><Foo/></Faktura>") }
  end
end

module Ksef
  module Parser
    def self.parse(xml)
      Document.new(xml)
    end

    def self.persistence_attrs(document)
      {
        seller_nip:     document.sprzedawca.nip,
        seller_name:    document.sprzedawca.nazwa,
        buyer_nip:      document.nabywca.nip,
        invoice_number: document.fa.p_2,
        issue_date:     document.fa.issue_date,
        net_amount:     document.fa.net_amount,
        gross_amount:   document.fa.gross_amount,
        currency:       document.fa.kod_waluty.presence || "PLN",
        metadata:       { "schema_version" => document.schema_version }
      }
    end

    class Document
      attr_reader :xml, :doc, :ns, :ns_href

      def initialize(xml)
        @xml = xml
        @doc = Nokogiri::XML(xml)
        @ns_href = @doc.root&.namespace&.href
        raise ArgumentError, "KSeF invoice XML has no default namespace" if @ns_href.blank?
        @ns = { "f" => @ns_href }
      end

      def schema_version
        case @ns_href
        when "http://crd.gov.pl/wzor/2025/06/25/13775/" then "FA(3)"
        when "http://crd.gov.pl/wzor/2023/06/29/12648/" then "FA(2)"
        when "http://crd.gov.pl/wzor/2021/11/29/11089/" then "FA(1)"
        else @ns_href
        end
      end

      def naglowek
        @naglowek ||= Naglowek.new(@doc.at_xpath("//f:Naglowek", @ns), @ns)
      end

      def sprzedawca
        @sprzedawca ||= Podmiot.new(@doc.at_xpath("//f:Podmiot1", @ns), @ns)
      end

      def nabywca
        @nabywca ||= Podmiot.new(@doc.at_xpath("//f:Podmiot2", @ns), @ns)
      end

      def odbiorcy
        @odbiorcy ||= @doc.xpath("//f:Podmiot3", @ns).map { |node| Podmiot.new(node, @ns) }
      end

      def fa
        @fa ||= Fa.new(@doc.at_xpath("//f:Fa", @ns), @ns)
      end

      def stopka
        @stopka ||= Stopka.new(@doc.at_xpath("//f:Stopka", @ns), @ns)
      end
    end

    module NodeHelpers
      def text(node, xpath)
        return nil if node.nil?
        node.at_xpath(xpath, @ns)&.text&.strip.presence
      end

      def decimal(node, xpath)
        raw = text(node, xpath)
        raw.nil? ? nil : BigDecimal(raw)
      rescue ArgumentError
        nil
      end

      def all(node, xpath)
        return [] if node.nil?
        node.xpath(xpath, @ns)
      end

      def present?(node, xpath)
        !text(node, xpath).nil?
      end
    end

    class Naglowek
      include NodeHelpers
      attr_reader :node

      def initialize(node, ns)
        @node = node
        @ns = ns
      end

      def kod_systemowy
        return nil if @node.nil?
        @node.at_xpath("f:KodFormularza", @ns)&.attr("kodSystemowy")
      end

      def wersja_schemy
        return nil if @node.nil?
        @node.at_xpath("f:KodFormularza", @ns)&.attr("wersjaSchemy")
      end

      def wariant_formularza
        text(@node, "f:WariantFormularza")
      end

      def data_wytworzenia
        text(@node, "f:DataWytworzeniaFa")
      end

      def system_info
        text(@node, "f:SystemInfo")
      end
    end

    class Adres
      include NodeHelpers

      def initialize(node, ns)
        @node = node
        @ns = ns
      end

      def present?
        !@node.nil? && (kod_kraju || adres_l1 || adres_l2 || gln)
      end

      def kod_kraju; text(@node, "f:KodKraju"); end
      def adres_l1;  text(@node, "f:AdresL1");  end
      def adres_l2;  text(@node, "f:AdresL2");  end
      def gln;       text(@node, "f:GLN");      end

      def lines
        country = Ksef::Pdf::Dictionaries.kraj(kod_kraju) if kod_kraju.present?
        [adres_l1, adres_l2, country].reject(&:blank?)
      end
    end

    class DaneKontaktowe
      include NodeHelpers

      def initialize(nodes, ns)
        @nodes = nodes
        @ns = ns
      end

      def entries
        @entries ||= @nodes.map do |node|
          {
            email:    text(node, "f:Email"),
            telefon:  text(node, "f:Telefon")
          }.compact
        end.reject(&:empty?)
      end

      def any?
        entries.any?
      end
    end

    class Podmiot
      include NodeHelpers
      attr_reader :node

      def initialize(node, ns)
        @node = node
        @ns = ns
      end

      def present?
        !@node.nil?
      end

      def prefiks_podatnika
        text(@node, "f:PrefiksPodatnika")
      end

      def nr_eori
        text(@node, "f:NrEORI")
      end

      def nip
        text(@node, "f:DaneIdentyfikacyjne/f:NIP")
      end

      def kod_uz
        text(@node, "f:DaneIdentyfikacyjne/f:KodUE") ||
          text(@node, "f:DaneIdentyfikacyjne/f:KodKraju")
      end

      def nr_vat_ue
        text(@node, "f:DaneIdentyfikacyjne/f:NrVatUE")
      end

      def brak_id
        text(@node, "f:DaneIdentyfikacyjne/f:BrakID")
      end

      def nazwa
        text(@node, "f:DaneIdentyfikacyjne/f:Nazwa") ||
          text(@node, "f:DaneIdentyfikacyjne/f:ImieNazwisko")
      end

      def adres
        @adres ||= Adres.new(@node&.at_xpath("f:Adres", @ns), @ns)
      end

      def adres_koresp
        @adres_koresp ||= Adres.new(@node&.at_xpath("f:AdresKoresp", @ns), @ns)
      end

      def dane_kontaktowe
        @dane_kontaktowe ||= DaneKontaktowe.new(all(@node, "f:DaneKontaktowe"), @ns)
      end

      def nr_klienta
        text(@node, "f:NrKlienta")
      end

      def id_nabywcy
        text(@node, "f:IDNabywcy")
      end

      def jst?
        text(@node, "f:JST") == "1"
      end

      def gv?
        text(@node, "f:GV") == "1"
      end

      def status_info_podatnika
        text(@node, "f:StatusInfoPodatnika")
      end

      def rola_podmiotu3
        text(@node, "f:RolaPodmiotu3") || text(@node, "f:Rola")
      end

      def udzial_podmiotu3
        text(@node, "f:UdzialPodmiotu3")
      end
    end

    class Fa
      include NodeHelpers
      attr_reader :node

      def initialize(node, ns)
        @node = node
        @ns = ns
      end

      def kod_waluty; text(@node, "f:KodWaluty"); end
      def p_1;   text(@node, "f:P_1"); end
      def p_1m;  text(@node, "f:P_1M"); end
      def p_2;   text(@node, "f:P_2"); end
      def p_6;   text(@node, "f:P_6"); end
      def p_15;  decimal(@node, "f:P_15"); end

      def issue_date
        raw = p_1
        raw.present? ? Date.parse(raw) : nil
      rescue ArgumentError
        nil
      end

      def sale_date
        raw = p_6
        raw.present? ? Date.parse(raw) : nil
      rescue ArgumentError
        nil
      end

      def net_amount
        decimal(@node, "f:P_13_1")
      end

      def gross_amount
        p_15
      end

      def rodzaj_faktury
        text(@node, "f:RodzajFaktury")
      end

      def okres_fa_korygowanej
        text(@node, "f:OkresFaKorygowanej")
      end

      VAT_BUCKETS = {
        p_13_1: { net: "P_13_1", tax: "P_14_1", label: "23% lub 22%" },
        p_13_2: { net: "P_13_2", tax: "P_14_2", label: "8% lub 7%" },
        p_13_3: { net: "P_13_3", tax: "P_14_3", label: "5%" },
        p_13_4: { net: "P_13_4", tax: "P_14_4", label: "4% lub 3%" },
        p_13_5: { net: "P_13_5", tax: "P_14_5", label: "OSS" },
        p_13_6_1: { net: "P_13_6_1", tax: nil, label: "0% (krajowe)" },
        p_13_6_2: { net: "P_13_6_2", tax: nil, label: "0% WDT" },
        p_13_6_3: { net: "P_13_6_3", tax: nil, label: "0% eksport" },
        p_13_7:   { net: "P_13_7", tax: nil, label: "zwolnione od podatku" },
        p_13_8:   { net: "P_13_8", tax: nil, label: "np. z wył. art. 100 ust. 1 pkt 4" },
        p_13_9:   { net: "P_13_9", tax: nil, label: "np. art. 100 ust. 1 pkt 4" },
        p_13_10:  { net: "P_13_10", tax: nil, label: "odwrotne obciążenie" },
        p_13_11:  { net: "P_13_11", tax: nil, label: "marża" }
      }.freeze

      def tax_summary
        rows = []
        VAT_BUCKETS.each_value do |bucket|
          net = decimal(@node, "f:#{bucket[:net]}")
          tax = bucket[:tax] ? decimal(@node, "f:#{bucket[:tax]}") : nil
          next if net.nil? && tax.nil?
          next if (net || 0).zero? && (tax || 0).zero?
          rows << {
            label: bucket[:label],
            net:   net || BigDecimal("0"),
            tax:   tax || BigDecimal("0"),
            gross: (net || BigDecimal("0")) + (tax || BigDecimal("0"))
          }
        end
        rows
      end

      def brutto_mode?
        rows = wiersze
        return false if rows.empty?
        rows.none? { |r| r[:cena_netto].present? || r[:wartosc_netto].present? }
      end

      def wiersze
        all(@node, "f:FaWiersz").map do |row|
          {
            nr:      text(row, "f:NrWierszaFa"),
            nazwa:   text(row, "f:P_7"),
            miara:   text(row, "f:P_8A"),
            ilosc:   text(row, "f:P_8B"),
            cena_netto:  text(row, "f:P_9A"),
            cena_brutto: text(row, "f:P_9B"),
            rabat:   text(row, "f:P_10"),
            stawka:  text(row, "f:P_12"),
            wartosc_netto:  text(row, "f:P_11"),
            wartosc_brutto: text(row, "f:P_11A"),
            gtin:    text(row, "f:GTIN"),
            pkwiu:   text(row, "f:PKWiU"),
            cn:      text(row, "f:CN")
          }.compact
        end
      end

      def adnotacje
        @adnotacje ||= Adnotacje.new(@node&.at_xpath("f:Adnotacje", @ns), @ns)
      end

      def platnosc
        @platnosc ||= Platnosc.new(@node&.at_xpath("f:Platnosc", @ns), @ns)
      end

      def rozliczenie
        @rozliczenie ||= Rozliczenie.new(@node&.at_xpath("f:Rozliczenie", @ns), @ns)
      end

      def warunki_transakcji
        @warunki_transakcji ||= WarunkiTransakcji.new(@node&.at_xpath("f:WarunkiTransakcji", @ns), @ns)
      end

      def dane_fa_korygowanej
        all(@node, "f:DaneFaKorygowanej").map do |n|
          {
            numer:          text(n, "f:NrFaKorygowanej"),
            data_wystawienia: text(n, "f:DataWystFaKorygowanej"),
            nr_ksef:        text(n, "f:NrKSeFFaKorygowanej")
          }.compact
        end
      end

      def korekta?
        rodzaj_faktury == "KOR"
      end

      def korekta_zbiorcza_rabat?
        korekta? && okres_fa_korygowanej.present?
      end
    end

    class Adnotacje
      include NodeHelpers

      def initialize(node, ns)
        @node = node
        @ns = ns
      end

      def present?
        !@node.nil?
      end

      def p_16;  text(@node, "f:P_16");  end
      def p_17;  text(@node, "f:P_17");  end
      def p_18;  text(@node, "f:P_18");  end
      def p_18a; text(@node, "f:P_18A"); end
      def p_23;  text(@node, "f:P_23");  end

      def zwolnienie
        return {} if @node.nil?
        node = @node.at_xpath("f:Zwolnienie", @ns)
        return {} if node.nil?
        {
          p_19:   text(node, "f:P_19"),
          p_19a:  text(node, "f:P_19A"),
          p_19b:  text(node, "f:P_19B"),
          p_19c:  text(node, "f:P_19C"),
          p_19n:  text(node, "f:P_19N")
        }.compact
      end

      def nowe_srodki_transportu
        return {} if @node.nil?
        node = @node.at_xpath("f:NoweSrodkiTransportu", @ns)
        return {} if node.nil?
        {
          p_22:   text(node, "f:P_22"),
          p_42_5: text(node, "f:P_42_5"),
          p_22n:  text(node, "f:P_22N")
        }.compact
      end

      def pmarzy
        return {} if @node.nil?
        node = @node.at_xpath("f:PMarzy", @ns)
        return {} if node.nil?
        {
          p_pmarzy:     text(node, "f:P_PMarzy"),
          p_pmarzy_2:   text(node, "f:P_PMarzy_2"),
          p_pmarzy_3_1: text(node, "f:P_PMarzy_3_1"),
          p_pmarzy_3_2: text(node, "f:P_PMarzy_3_2"),
          p_pmarzy_3_3: text(node, "f:P_PMarzy_3_3"),
          p_pmarzyn:    text(node, "f:P_PMarzyN")
        }.compact
      end
    end

    class Platnosc
      include NodeHelpers

      def initialize(node, ns)
        @node = node
        @ns = ns
      end

      def present?
        !@node.nil?
      end

      def zaplacono;                  text(@node, "f:Zaplacono"); end
      def data_zaplaty;               text(@node, "f:DataZaplaty"); end
      def znacznik_zaplaty_czesciowej; text(@node, "f:ZnacznikZaplatyCzesciowej"); end
      def forma_platnosci;            text(@node, "f:FormaPlatnosci"); end
      def platnosc_inna;              text(@node, "f:PlatnoscInna"); end
      def opis_platnosci;             text(@node, "f:OpisPlatnosci"); end
      def link_do_platnosci;          text(@node, "f:LinkDoPlatnosci"); end
      def ip_ksef;                    text(@node, "f:IPKSeF"); end

      def terminy_platnosci
        all(@node, "f:TerminPlatnosci").map do |n|
          {
            termin:        text(n, "f:Termin"),
            termin_opis:   [
              text(n, "f:TerminOpis/f:Ilosc"),
              text(n, "f:TerminOpis/f:Jednostka"),
              text(n, "f:TerminOpis/f:ZdarzeniePoczatkowe")
            ].reject(&:blank?).join(" ").presence
          }.compact
        end
      end

      def rachunki_bankowe
        collect_rachunki("f:RachunekBankowy")
      end

      def rachunki_bankowe_faktora
        collect_rachunki("f:RachunekBankowyFaktora")
      end

      def skonto
        return {} if @node.nil?
        node = @node.at_xpath("f:Skonto", @ns)
        return {} if node.nil?
        {
          warunki:  text(node, "f:WarunkiSkonta"),
          wysokosc: text(node, "f:WysokoscSkonta")
        }.compact
      end

      def zaplata_czesciowa
        all(@node, "f:ZaplataCzesciowa").map do |n|
          {
            kwota:            text(n, "f:KwotaZaplatyCzesciowej"),
            data:             text(n, "f:DataZaplatyCzesciowej"),
            forma_platnosci:  text(n, "f:FormaPlatnosci"),
            platnosc_inna:    text(n, "f:PlatnoscInna"),
            opis_platnosci:   text(n, "f:OpisPlatnosci")
          }.compact
        end
      end

      private

      def collect_rachunki(xpath)
        all(@node, xpath).map do |n|
          {
            nr_rb:          text(n, "f:NrRB"),
            swift:          text(n, "f:SWIFT"),
            nazwa_banku:    text(n, "f:NazwaBanku"),
            rachunek_wlasny_banku: text(n, "f:RachunekWlasnyBanku"),
            opis:           text(n, "f:OpisRachunku")
          }.compact
        end
      end
    end

    class Rozliczenie
      include NodeHelpers

      def initialize(node, ns)
        @node = node
        @ns = ns
      end

      def present?
        !@node.nil?
      end

      def obciazenia
        all(@node, "f:Obciazenia").map do |n|
          {
            kwota: text(n, "f:Kwota"),
            powod: text(n, "f:Powod")
          }.compact
        end
      end

      def odliczenia
        all(@node, "f:Odliczenia").map do |n|
          {
            kwota: text(n, "f:Kwota"),
            powod: text(n, "f:Powod")
          }.compact
        end
      end

      def suma_obciazen; decimal(@node, "f:SumaObciazen"); end
      def suma_odliczen; decimal(@node, "f:SumaOdliczen"); end
      def do_zaplaty;    decimal(@node, "f:DoZaplaty");    end
      def do_rozliczenia; decimal(@node, "f:DoRozliczenia"); end
    end

    class WarunkiTransakcji
      include NodeHelpers

      def initialize(node, ns)
        @node = node
        @ns = ns
      end

      def present?
        !@node.nil?
      end

      def warunki_dostawy; text(@node, "f:WarunkiDostawy"); end
      def kurs_umowny;     text(@node, "f:KursUmowny");     end
      def waluta_umowna;   text(@node, "f:WalutaUmowna");   end
      def podmiot_posredniczacy; text(@node, "f:PodmiotPosredniczacy"); end
      def rodzaj_transportu; text(@node, "f:RodzajTransportu"); end
      def numer_srodka_transportu; text(@node, "f:NumerSrodkaTransportu"); end

      def umowy
        all(@node, "f:Umowy").map do |n|
          {
            data: text(n, "f:DataUmowy"),
            numer: text(n, "f:NrUmowy")
          }.compact
        end
      end

      def zamowienia
        all(@node, "f:Zamowienia").map do |n|
          {
            data: text(n, "f:DataZamowienia"),
            numer: text(n, "f:NrZamowienia")
          }.compact
        end
      end

      def nr_partii_towaru
        all(@node, "f:NrPartiiTowaru").map(&:text).map(&:strip).reject(&:blank?)
      end
    end

    class Stopka
      include NodeHelpers

      def initialize(node, ns)
        @node = node
        @ns = ns
      end

      def present?
        !@node.nil?
      end

      def informacje
        all(@node, "f:Informacje/f:StopkaFaktury").map(&:text).map(&:strip).reject(&:blank?)
      end

      def rejestry
        all(@node, "f:Rejestry").map do |n|
          {
            krs:       text(n, "f:KRS"),
            regon:     text(n, "f:REGON"),
            bdo:       text(n, "f:BDO")
          }.compact
        end
      end
    end
  end
end

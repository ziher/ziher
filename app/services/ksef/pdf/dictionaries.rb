module Ksef
  module Pdf
    module Dictionaries
      module_function

      RODZAJ_FAKTURY = {
        "VAT"     => "Faktura podstawowa",
        "ZAL"     => "Faktura zaliczkowa",
        "ROZ"     => "Faktura rozliczeniowa",
        "KOR"     => "Faktura korygująca",
        "KOR_ZAL" => "Faktura korygująca zaliczkową",
        "KOR_ROZ" => "Faktura korygująca rozliczeniową",
        "UPR"     => "Faktura uproszczona"
      }.freeze

      FORMA_PLATNOSCI = {
        "1" => "Gotówka",
        "2" => "Karta",
        "3" => "Bon",
        "4" => "Czek",
        "5" => "Kredyt",
        "6" => "Przelew",
        "7" => "Mobilna"
      }.freeze

      TAXPAYER_STATUS = {
        "1" => "Stan likwidacji",
        "2" => "Postępowanie restrukturyzacyjne",
        "3" => "Stan upadłości",
        "4" => "Przedsiębiorstwo w spadku"
      }.freeze

      STAWKA_PODATKU = {
        "23"    => "23%",
        "22"    => "22%",
        "8"     => "8%",
        "7"     => "7%",
        "5"     => "5%",
        "4"     => "4%",
        "3"     => "3%",
        "0"     => "0%",
        "0 KR"  => "0% (krajowe)",
        "0 WDT" => "0% (WDT)",
        "0 EX"  => "0% (eksport)",
        "zw"    => "zw.",
        "oo"    => "odwrotne obciążenie",
        "np"    => "nie podlega",
        "np I"  => "np I",
        "np II" => "np II"
      }.freeze

      ROLA_PODMIOTU3 = {
        "1" => "Odbiorca",
        "2" => "Dodatkowy nabywca",
        "3" => "Faktor",
        "4" => "Wystawca faktury",
        "5" => "Odbierający fakturę",
        "6" => "Jednostka wewnętrzna",
        "7" => "Członek grupy VAT",
        "8" => "Płatnik",
        "9" => "Inny"
      }.freeze

      TYP_KOREKTY = {
        "1" => "Korekta skutkująca w dacie ujęcia faktury pierwotnej",
        "2" => "Korekta skutkująca w dacie wystawienia faktury korygującej",
        "3" => "Korekta skutkująca w dacie innej (różne daty dla pozycji)"
      }.freeze

      def rodzaj_faktury(code, okres_korygowanej: nil)
        base = RODZAJ_FAKTURY[code.to_s]
        return "Faktura korygująca zbiorcza (rabat)" if code == "KOR" && okres_korygowanej.present?
        base || code.to_s
      end

      def forma_platnosci(code)
        FORMA_PLATNOSCI[code.to_s] || code.to_s
      end

      def taxpayer_status(code)
        TAXPAYER_STATUS[code.to_s]
      end

      def stawka_podatku(code)
        STAWKA_PODATKU[code.to_s] || code.to_s
      end

      def typ_korekty(code)
        TYP_KOREKTY[code.to_s]
      end

      def rola_podmiotu3(code)
        return nil if code.blank?
        ROLA_PODMIOTU3[code.to_s] || "Odbiorca"
      end

      # Adnotacje flags → human labels.
      # Returns an array of strings for every flag set to "1".
      def adnotacje_flags(adnotacje)
        return [] if adnotacje.nil?

        result = []
        result << "Metoda kasowa" if adnotacje.p_16 == "1"
        result << "Samofakturowanie" if adnotacje.p_17 == "1"
        result << "Odwrotne obciążenie" if adnotacje.p_18 == "1"
        result << "Mechanizm podzielonej płatności" if adnotacje.p_18a == "1"
        result << "Procedura trójstronna uproszczona" if adnotacje.p_23 == "1"

        if adnotacje.zwolnienie[:p_19] == "1"
          result << "Dostawa / usługa zwolniona z VAT (art. 43 ust. 1, art. 113 ust. 1 i 9 albo inne przepisy)"
        end

        nst = adnotacje.nowe_srodki_transportu
        case nst[:p_42_5]
        when "1" then result << "Wewnątrzwspólnotowa dostawa nowych środków transportu (obowiązek VAT-22)"
        when "2" then result << "Wewnątrzwspólnotowa dostawa nowych środków transportu (brak obowiązku VAT-22)"
        end

        pm = adnotacje.pmarzy
        if pm[:p_pmarzy] == "1"
          suffixes = []
          suffixes << "towary używane" if pm[:p_pmarzy_3_1] == "1"
          suffixes << "dzieła sztuki" if pm[:p_pmarzy_3_2] == "1"
          suffixes << "przedmioty kolekcjonerskie i antyki" if pm[:p_pmarzy_3_3] == "1"
          base = "Procedura marży"
          base += " — #{suffixes.join(', ')}" if suffixes.any?
          result << base
        elsif pm[:p_pmarzy_2] == "1"
          result << "Procedura marży dla biur podróży"
        end

        result
      end
    end
  end
end

module Ksef
  module Pdf
    # Code → human-readable label dictionaries for FA(3) invoice visualization.
    # Values mirror the official CIRFMF/ksef-pdf-generator constants so the
    # Ruby PDF output stays in lockstep with the reference implementation.
    module Dictionaries
      module_function

      RODZAJ_FAKTURY = {
        "VAT"        => "Faktura podstawowa",
        "KOR"        => "Faktura korygująca",
        "ZAL"        => "Faktura dokumentująca otrzymanie zapłaty lub jej części przed dokonaniem czynności oraz faktura wystawiona w związku z art. 106f ust. 4 ustawy",
        "ROZ"        => "Faktura wystawiona w związku z art. 106f ust. 3 ustawy",
        "UPR"        => "Faktura, o której mowa w art. 106e ust. 5 pkt 3 ustawy",
        "KOR_ZAL"    => "Faktura korygująca fakturę dokumentującą otrzymanie zapłaty lub jej części przed dokonaniem czynności oraz fakturę wystawioną w związku z art. 106f ust. 4 ustawy",
        "KOR_ROZ"    => "Faktura korygująca fakturę wystawioną w związku z art. 106f ust. 3 ustawy",
        "VAT_RR"     => "Faktura pierwotna",
        "KOR_VAT_RR" => "Faktura korygująca"
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
        "0 KR"  => "0% - KR",
        "0 WDT" => "0% - WDT",
        "0 EX"  => "0% - EX",
        "zw"    => "zw",
        "oo"    => "oo",
        "np"    => "niepodlegające opodatkowaniu",
        "np I"  => "np I",
        "np II" => "np II"
      }.freeze

      TYP_KOREKTY = {
        "1" => "Korekta skutkująca w dacie ujęcia faktury pierwotnej",
        "2" => "Korekta skutkująca w dacie wystawienia faktury korygującej",
        "3" => "Korekta skutkująca w dacie innej, w tym gdy dla różnych pozycji faktury korygującej daty te są różne"
      }.freeze

      # FA(3) RolaPodmiotu3 — values per Schemat_FA(3).
      # For short column titles in podmioty section use `rola_podmiotu3_short`.
      ROLA_PODMIOTU3 = {
        "1"  => "Faktor",
        "2"  => "Odbiorca",
        "3"  => "Podmiot pierwotny",
        "4"  => "Dodatkowy nabywca",
        "5"  => "Wystawca faktury",
        "6"  => "Dokonujący płatności",
        "7"  => "Jednostka samorządu terytorialnego (wystawca)",
        "8"  => "Jednostka samorządu terytorialnego (odbiorca)",
        "9"  => "Członek grupy VAT (wystawca)",
        "10" => "Członek grupy VAT (odbiorca)",
        "11" => "Pracownik"
      }.freeze

      ROLA_PODMIOTU_UPOWAZNIONEGO = {
        "1" => "Organ egzekucyjny",
        "2" => "Komornik sądowy",
        "3" => "Przedstawiciel podatkowy"
      }.freeze

      ZAPLACONO = {
        "1" => "Zapłacono",
        "2" => "Brak zapłaty"
      }.freeze

      ZNACZNIK_ZAPLATY_CZESCIOWEJ = {
        "1" => "Zapłacono w części",
        "2" => "Zapłacono całość w częściach"
      }.freeze

      RODZAJ_TRANSPORTU = {
        "1" => "Transport morski",
        "2" => "Transport kolejowy",
        "3" => "Transport drogowy",
        "4" => "Transport lotniczy",
        "5" => "Przesyłka pocztowa",
        "7" => "Stałe instalacje przesyłowe",
        "8" => "Żegluga śródlądowa"
      }.freeze

      TYP_RACHUNKOW_WLASNYCH = {
        "1" => "Rachunek służący do rozliczeń z tytułu nabywanych wierzytelności pieniężnych",
        "2" => "Rachunek wykorzystywany do pobrania należności od nabywcy i przekazania jej dostawcy",
        "3" => "Rachunek prowadzony w ramach gospodarki własnej (niebędący rozliczeniowym)"
      }.freeze

      PROCEDURA = {
        "1" => "Stawka 0% stosowana w ramach sprzedaży krajowej",
        "2" => "Stawka 0% — wewnątrzwspólnotowa dostawa towarów",
        "3" => "Stawka 0% — eksport towarów",
        "4" => "Dostawa towarów oraz świadczenie usług opodatkowane poza terytorium kraju",
        "5" => "Świadczenie usług z art. 100 ust. 1 pkt 4 ustawy",
        "6" => "Towar/usługa wymienione w załączniku 15",
        "7" => "Pozostała sprzedaż krajowa"
      }.freeze

      TYP_LADUNKU = {
        "1"  => "Bańka",
        "2"  => "Beczka",
        "3"  => "Butla",
        "4"  => "Karton",
        "5"  => "Kanister",
        "6"  => "Klatka",
        "7"  => "Kontener",
        "8"  => "Kosz/koszyk",
        "9"  => "Łubianka",
        "10" => "Opakowanie zbiorcze",
        "11" => "Paczka",
        "12" => "Pakiet",
        "13" => "Paleta",
        "14" => "Pojemnik",
        "15" => "Pojemnik do ładunków masowych stałych",
        "16" => "Pojemnik do ładunków masowych w postaci płynnej",
        "17" => "Pudełko",
        "18" => "Puszka",
        "19" => "Skrzynia",
        "20" => "Worek"
      }.freeze

      KRAJ = {
        "AF" => "Afganistan", "AX" => "Wyspy Alandzkie", "AL" => "Albania",
        "DZ" => "Algieria", "AD" => "Andora", "AO" => "Angola", "AI" => "Anguilla",
        "AQ" => "Antarktyda", "AG" => "Antigua i Barbuda", "AN" => "Antyle Holenderskie",
        "SA" => "Arabia Saudyjska", "AR" => "Argentyna", "AM" => "Armenia", "AW" => "Aruba",
        "AU" => "Australia", "AT" => "Austria", "AZ" => "Azerbejdżan", "BS" => "Bahamy",
        "BH" => "Bahrajn", "BD" => "Bangladesz", "BB" => "Barbados", "BE" => "Belgia",
        "BZ" => "Belize", "BJ" => "Benin", "BM" => "Bermudy", "BT" => "Bhutan",
        "BY" => "Białoruś", "BO" => "Boliwia", "BQ" => "Bonaire, Sint Eustatius i Saba",
        "BA" => "Bośnia i Hercegowina", "BW" => "Botswana", "BR" => "Brazylia",
        "BN" => "Brunei Darussalam", "IO" => "Brytyjskie Terytorium Oceanu Indyjskiego",
        "BG" => "Bułgaria", "BF" => "Burkina Faso", "BI" => "Burundi", "XC" => "Ceuta",
        "CL" => "Chile", "CN" => "Chiny", "HR" => "Chorwacja", "CW" => "Curaçao",
        "CY" => "Cypr", "TD" => "Czad", "ME" => "Czarnogóra", "DK" => "Dania",
        "DM" => "Dominika", "DO" => "Dominikana", "DJ" => "Dżibuti", "EG" => "Egipt",
        "EC" => "Ekwador", "ER" => "Erytrea", "EE" => "Estonia", "ET" => "Etiopia",
        "FK" => "Falklandy", "FJ" => "Fidżi", "PH" => "Filipiny", "FI" => "Finlandia",
        "FR" => "Francja", "TF" => "Francuskie Terytorium Południowe", "GA" => "Gabon",
        "GM" => "Gambia", "GH" => "Ghana", "GI" => "Gibraltar", "GR" => "Grecja",
        "GD" => "Grenada", "GL" => "Grenlandia", "GE" => "Gruzja", "GU" => "Guam",
        "GG" => "Guernsey", "GY" => "Gujana", "GF" => "Gujana Francuska", "GP" => "Gwadelupa",
        "GT" => "Gwatemala", "GN" => "Gwinea", "GQ" => "Gwinea Równikowa",
        "GW" => "Gwinea Bissau", "HT" => "Haiti", "ES" => "Hiszpania", "HN" => "Honduras",
        "HK" => "Hongkong", "IN" => "Indie", "ID" => "Indonezja", "IQ" => "Irak",
        "IR" => "Iran", "IE" => "Irlandia", "IS" => "Islandia", "IL" => "Izrael",
        "JM" => "Jamajka", "JP" => "Japonia", "YE" => "Jemen", "JE" => "Jersey",
        "JO" => "Jordania", "KY" => "Kajmany", "KH" => "Kambodża", "CM" => "Kamerun",
        "CA" => "Kanada", "QA" => "Katar", "KZ" => "Kazachstan", "KE" => "Kenia",
        "KG" => "Kirgistan", "KI" => "Kiribati", "CO" => "Kolumbia", "KM" => "Komory",
        "CG" => "Kongo", "CD" => "Kongo, Republika Demokratyczna",
        "KP" => "Koreańska Republika Ludowo-Demokratyczna", "XK" => "Kosowo",
        "CR" => "Kostaryka", "CU" => "Kuba", "KW" => "Kuwejt", "LA" => "Laos",
        "LS" => "Lesotho", "LB" => "Liban", "LR" => "Liberia", "LY" => "Libia",
        "LI" => "Liechtenstein", "LT" => "Litwa", "LV" => "Łotwa", "LU" => "Luksemburg",
        "MK" => "Macedonia", "MG" => "Madagaskar", "YT" => "Majotta", "MO" => "Makau",
        "MW" => "Malawi", "MV" => "Malediwy", "MY" => "Malezja", "ML" => "Mali",
        "MT" => "Malta", "MP" => "Mariany Północne", "MA" => "Maroko", "MQ" => "Martynika",
        "MR" => "Mauretania", "MU" => "Mauritius", "MX" => "Meksyk", "XL" => "Melilla",
        "FM" => "Mikronezja", "UM" => "Minor", "MD" => "Mołdawia", "MC" => "Monako",
        "MN" => "Mongolia", "MS" => "Montserrat", "MZ" => "Mozambik", "MM" => "Mjanma",
        "NA" => "Namibia", "NR" => "Nauru", "NP" => "Nepal", "NL" => "Niderlandy",
        "DE" => "Niemcy", "NE" => "Niger", "NG" => "Nigeria", "NI" => "Nikaragua",
        "NU" => "Niue", "NF" => "Norfolk", "NO" => "Norwegia", "NC" => "Nowa Kaledonia",
        "NZ" => "Nowa Zelandia", "PS" => "Palestyna", "OM" => "Oman", "PK" => "Pakistan",
        "PW" => "Palau", "PA" => "Panama", "PG" => "Papua Nowa Gwinea", "PY" => "Paragwaj",
        "PE" => "Peru", "PN" => "Pitcairn", "PF" => "Polinezja Francuska", "PL" => "Polska",
        "GS" => "Południowa Georgia i Połud. Wyspy Sandwich", "PT" => "Portugalia",
        "PR" => "Portoryko", "CF" => "Republika Środkowoafrykańska",
        "CZ" => "Republika Czeska", "KR" => "Republika Korei",
        "ZA" => "Republika Południowej Afryki", "RE" => "Reunion", "RU" => "Rosja",
        "RO" => "Rumunia", "RW" => "Rwanda", "EH" => "Sahara Zachodnia",
        "BL" => "Saint Barthelemy", "KN" => "Saint Kitts i Nevis", "LC" => "Saint Lucia",
        "MF" => "Saint Martin", "VC" => "Saint Vincent i Grenadyny", "SV" => "Salwador",
        "WS" => "Samoa", "AS" => "Samoa Amerykańskie", "SM" => "San Marino",
        "SN" => "Senegal", "RS" => "Serbia", "SC" => "Seszele", "SL" => "Sierra Leone",
        "SG" => "Singapur", "SK" => "Słowacja", "SI" => "Słowenia", "SO" => "Somalia",
        "LK" => "Sri Lanka", "PM" => "Saint Pierre i Miquelon",
        "US" => "Stany Zjednoczone Ameryki", "SZ" => "Suazi", "SD" => "Sudan",
        "SS" => "Sudan Południowy", "SR" => "Surinam", "SJ" => "Svalbard i Jan Mayen",
        "SH" => "Święta Helena", "SY" => "Syria", "CH" => "Szwajcaria", "SE" => "Szwecja",
        "TJ" => "Tadżykistan", "TH" => "Tajlandia", "TW" => "Tajwan", "TZ" => "Tanzania",
        "TG" => "Togo", "TK" => "Tokelau", "TO" => "Tonga", "TT" => "Trynidad i Tobago",
        "TN" => "Tunezja", "TR" => "Turcja", "TM" => "Turkmenistan", "TV" => "Tuvalu",
        "UG" => "Uganda", "UA" => "Ukraina", "UY" => "Urugwaj", "UZ" => "Uzbekistan",
        "VU" => "Vanuatu", "WF" => "Wallis i Futuna", "VA" => "Watykan", "HU" => "Węgry",
        "VE" => "Wenezuela", "GB" => "Wielka Brytania", "VN" => "Wietnam", "IT" => "Włochy",
        "TL" => "Wschodni Timor", "CI" => "Wybrzeże Kości Słoniowej", "BV" => "Wyspa Bouveta",
        "CX" => "Wyspa Bożego Narodzenia", "IM" => "Wyspa Man",
        "SX" => "Sint Maarten (część holenderska)", "CK" => "Wyspy Cooka",
        "VI" => "Wyspy Dziewicze Stanów Zjednoczonych",
        "VG" => "Brytyjskie Wyspy Dziewicze", "HM" => "Wyspy Heard i McDonalda",
        "CC" => "Wyspy Kokosowe (Keelinga)", "MH" => "Wyspy Marshalla", "FO" => "Wyspy Owcze",
        "SB" => "Wyspy Salomona", "ST" => "Wyspy Świętego Tomasza i Książęca",
        "TC" => "Wyspy Turks i Caicos", "ZM" => "Zambia", "CV" => "Republika Zielonego Przylądka",
        "ZW" => "Zimbabwe", "AE" => "Zjednoczone Emiraty Arabskie",
        "XI" => "Zjednoczone Królestwo (Irlandia Północna)"
      }.freeze

      def rodzaj_faktury(code, okres_korygowanej: nil)
        return "Faktura korygująca zbiorcza (rabat)" if code == "KOR" && okres_korygowanej.present?
        RODZAJ_FAKTURY[code.to_s] || code.to_s
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

      # Full description — used in detail lists.
      def rola_podmiotu3(code)
        return nil if code.blank?
        ROLA_PODMIOTU3[code.to_s] || "Odbiorca"
      end

      # Short label — used for podmioty column titles.
      def rola_podmiotu3_short(code)
        return nil if code.blank?
        full = ROLA_PODMIOTU3[code.to_s]
        return "Odbiorca" if full.nil?
        full.split(/\s*\(/).first
      end

      def rola_podmiotu_upowaznionego(code)
        ROLA_PODMIOTU_UPOWAZNIONEGO[code.to_s] || code.to_s
      end

      def zaplacono(code)
        ZAPLACONO[code.to_s]
      end

      def znacznik_zaplaty_czesciowej(code)
        ZNACZNIK_ZAPLATY_CZESCIOWEJ[code.to_s]
      end

      def rodzaj_transportu(code)
        RODZAJ_TRANSPORTU[code.to_s] || code.to_s
      end

      def typ_rachunkow_wlasnych(code)
        TYP_RACHUNKOW_WLASNYCH[code.to_s]
      end

      def procedura(code)
        PROCEDURA[code.to_s]
      end

      def typ_ladunku(code)
        TYP_LADUNKU[code.to_s] || code.to_s
      end

      def kraj(code)
        return nil if code.blank?
        KRAJ[code.to_s.upcase] || code.to_s
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

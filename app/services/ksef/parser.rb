module Ksef
  module Parser
    NS = { "f" => "http://crd.gov.pl/wzor/2023/06/29/12648/" }.freeze

    def self.parse(xml)
      doc = Nokogiri::XML(xml)

      {
        seller_nip:    text(doc, "//f:Podmiot1/f:DaneIdentyfikacyjne/f:NIP"),
        seller_name:   text(doc, "//f:Podmiot1/f:DaneIdentyfikacyjne/f:Nazwa"),
        buyer_nip:     text(doc, "//f:Podmiot2/f:DaneIdentyfikacyjne/f:NIP"),
        invoice_number: text(doc, "//f:Fa/f:P_2"),
        issue_date:    Date.parse(text(doc, "//f:Fa/f:P_1")),
        net_amount:    decimal(doc, "//f:Fa/f:P_13_1"),
        gross_amount:  decimal(doc, "//f:Fa/f:P_15"),
        currency:      text(doc, "//f:Fa/f:KodWaluty").presence || "PLN",
        metadata: {
          "lines" => doc.xpath("//f:Fa/f:FaWiersz", NS).map do |row|
            {
              "name" => row.at_xpath("f:P_7", NS)&.text,
              "net"  => row.at_xpath("f:P_11", NS)&.text,
              "vat"  => row.at_xpath("f:P_12", NS)&.text,
            }
          end
        }
      }
    end

    def self.text(doc, xpath)
      doc.at_xpath(xpath, NS)&.text
    end

    def self.decimal(doc, xpath)
      raw = text(doc, xpath)
      raw.present? ? BigDecimal(raw) : nil
    end
  end
end

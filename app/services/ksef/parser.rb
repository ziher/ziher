module Ksef
  module Parser
    def self.parse(xml)
      doc = Nokogiri::XML(xml)
      ns_href = doc.root&.namespace&.href
      raise ArgumentError, "KSeF invoice XML has no default namespace" if ns_href.blank?

      ns = { "f" => ns_href }
      raw_issue_date = text(doc, "//f:Fa/f:P_1", ns)

      {
        seller_nip:     text(doc, "//f:Podmiot1/f:DaneIdentyfikacyjne/f:NIP", ns),
        seller_name:    text(doc, "//f:Podmiot1/f:DaneIdentyfikacyjne/f:Nazwa", ns),
        buyer_nip:      text(doc, "//f:Podmiot2/f:DaneIdentyfikacyjne/f:NIP", ns),
        invoice_number: text(doc, "//f:Fa/f:P_2", ns),
        issue_date:     raw_issue_date.present? ? Date.parse(raw_issue_date) : nil,
        net_amount:     decimal(doc, "//f:Fa/f:P_13_1", ns),
        gross_amount:   decimal(doc, "//f:Fa/f:P_15", ns),
        currency:       text(doc, "//f:Fa/f:KodWaluty", ns).presence || "PLN",
        metadata: {
          "lines" => doc.xpath("//f:Fa/f:FaWiersz", ns).map do |row|
            {
              "name" => row.at_xpath("f:P_7", ns)&.text,
              "net"  => row.at_xpath("f:P_11", ns)&.text,
              "vat"  => row.at_xpath("f:P_12", ns)&.text,
            }
          end
        }
      }
    end

    def self.text(doc, xpath, ns)
      doc.at_xpath(xpath, ns)&.text
    end

    def self.decimal(doc, xpath, ns)
      raw = text(doc, xpath, ns)
      raw.present? ? BigDecimal(raw) : nil
    end
  end
end

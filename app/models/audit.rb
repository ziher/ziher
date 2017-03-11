Audit = Audited.audit_class

class Audit
  scope :newest_first, -> do
    reorder("created_at DESC")
  end

  def formatted_changes
    pretty_hash = Hash.new
    audited_changes.each do |key, value|
      if value.class == Array
        pretty_hash[key] = '[' + value.join(', ') + ']'
      else
        pretty_hash[key] = value.to_s
      end
    end
    pretty_hash
  end
end

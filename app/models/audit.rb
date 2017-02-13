Audit = Audited.audit_class

class Audit
  scope :newest_first, -> do
    reorder("created_at DESC")
  end
end
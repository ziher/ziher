class KsefInvoice < ApplicationRecord
  audited except: [:invoice_xml, :metadata]

  belongs_to :unit, optional: true
  belongs_to :assigned_by, class_name: "User", optional: true
  belongs_to :imported_entry, class_name: "Entry", optional: true

  enum :status, { unassigned: 0, to_clarify: 1, imported: 2, dismissed: 3 }, default: :unassigned

  validates :ksef_number, presence: true, uniqueness: true
  validates :issue_date, presence: true
  validates :synced_at, presence: true

  scope :claimable, -> { where(unit_id: nil, status: [statuses[:unassigned], statuses[:to_clarify]]) }

  def self.for_user(user)
    return all if user.is_superadmin

    unit_ids = user.units.pluck(:id)
    where(
      "(unit_id IS NULL AND status IN (:open)) OR (unit_id IN (:units) AND status IN (:assigned))",
      open: [statuses[:unassigned], statuses[:to_clarify]],
      units: unit_ids,
      assigned: [statuses[:to_clarify], statuses[:imported]]
    )
  end

  def assignable?
    !imported? && !dismissed?
  end
end

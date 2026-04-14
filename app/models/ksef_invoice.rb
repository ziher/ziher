class KsefInvoice < ApplicationRecord
  audited except: [:invoice_xml, :metadata]

  belongs_to :unit, optional: true
  belongs_to :assigned_by, class_name: "User", optional: true
  belongs_to :imported_entry, class_name: "Entry", optional: true

  # pending    — freshly synced, awaiting superadmin review ("nowa")
  # unassigned — released to the claim pool ("nieprzypisana")
  # assigned   — attached to a unit ("przypisana")
  # imported   — already imported into a journal
  # dismissed  — rejected
  enum :status, { pending: 0, unassigned: 1, assigned: 2, imported: 3, dismissed: 4 }, default: :pending

  STATUS_LABELS = {
    "pending"    => "nowa",
    "unassigned" => "nieprzypisana",
    "assigned"   => "przypisana",
    "imported"   => "zaimportowana",
    "dismissed"  => "odrzucona"
  }.freeze

  validates :ksef_number, presence: true, uniqueness: true
  validates :issue_date, presence: true
  validates :synced_at, presence: true

  scope :claimable, -> { where(unit_id: nil, status: :unassigned) }

  def self.for_user(user)
    return all if user.is_superadmin

    unit_ids = user.units.pluck(:id)
    return where(unit_id: nil, status: statuses[:unassigned]) if unit_ids.empty?

    where(
      "(unit_id IS NULL AND status = :pool) OR (unit_id IN (:units) AND status IN (:visible))",
      pool: statuses[:unassigned],
      units: unit_ids,
      visible: [statuses[:assigned], statuses[:imported]]
    )
  end

  def status_label
    STATUS_LABELS[status] || status
  end

  def assignable?
    !imported? && !dismissed?
  end

  def releasable?
    pending? || assigned?
  end
end

module KsefInvoicesHelper
  STATUS_BADGE_CLASSES = {
    "pending"    => "label label-warning",
    "unassigned" => "label label-info",
    "assigned"   => "label label-primary",
    "imported"   => "label label-success",
    "dismissed"  => "label label-default"
  }.freeze

  def ksef_status_badge(invoice)
    klass = STATUS_BADGE_CLASSES[invoice.status] || "label label-default"
    content_tag(:span, invoice.status_label, class: klass)
  end

  def ksef_manageable_units_for(user)
    @ksef_manageable_units_cache ||= {}
    @ksef_manageable_units_cache[user.id] ||= if user.is_superadmin
      Unit.order(:name).to_a
    else
      user.units.select { |u| user.can_manage_unit_entries(u) }.sort_by { |u| u.name.to_s }
    end
  end
end

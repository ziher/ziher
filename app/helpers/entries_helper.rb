module EntriesHelper
  def print_item_grants_form(item_fields)
    result = ""

    year = item_fields.object.entry.journal.year

    Category.find_grants_by_year(year).each_with_index do |category, index|

      grant = Grant.find(category.grant_id)

      # Take the grant from the in-memory association, not from the database: after a failed
      # validation the association holds the values the user has just submitted (for a new entry
      # there is nothing in the database yet, for an existing one the database has the old values).
      # A grant emptied or set to 0 in the form is destroyed by Item#remove_*_amount_grants but
      # stays in the association - keep its id so a resubmit updates the row instead of duplicating it,
      # but do not show its amount.
      item_grant = item_fields.object.item_grants.find { |ig| ig.grant_id == grant.id }
      item_grant_id = item_grant.nil? ? "" : item_grant.id.to_s
      if item_grant.nil? || item_grant.destroyed? || item_grant.amount.blank? || item_grant.amount == 0
        item_grant_amount = ""
      else
        # like FormBuilder#text_field: show what was typed (or stored), not the type-cast BigDecimal
        item_grant_amount = ERB::Util.html_escape(item_grant.amount_before_type_cast.to_s)
      end

      entry_name_key_prefix = "entry[items_attributes][#{item_fields.index}][item_grants_attributes][#{index}]"
      entry_id_key_prefix = "entry_items_attributes_#{item_fields.index}_item_grants_attributes_#{index}"

      result += "<div class='col-md-2'>"
      result += "  <label style='width: 100%;' for='entry_items_attributes_#{item_fields.index}_item_grants_attributes_#{index}_grant_name'>w tym #{grant.name}</label>"
      result += "  <input class='form-control amount-input-grants grant-#{grant.id}' type='text' value='#{item_grant_amount}' name='#{entry_name_key_prefix}[amount]' id='#{entry_id_key_prefix}_amount'>"
      result += "  <input class='grant_id' type='hidden' value='#{grant.id}' name='#{entry_name_key_prefix}[grant_id]' id='#{entry_id_key_prefix}_grant_id'>"
      result += "  <input class='item_id' type='hidden' value='#{item_fields.object.id}' name='#{entry_name_key_prefix}[item_id]' id='#{entry_id_key_prefix}_item_id'>"
      result += "  <input type='hidden' value='#{item_grant_id}' name='#{entry_name_key_prefix}[id]' id='#{entry_id_key_prefix}_id'>"
      result += "</div>"
    end

    concat result.html_safe
  end
end

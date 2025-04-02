module EntriesHelper
  def print_item_grants_form(item_fields)
    result = ""

    year = item_fields.object.entry.journal.year

    Category.find_grants_by_year(year).each_with_index do |category, index|

      grant = Grant.find(category.grant_id)

      itemGrant = ItemGrant.where(grant_id: grant.id, item_id: item_fields.object.id).first
      item_grant_amount = itemGrant.blank? ? "" : itemGrant.amount
      item_grant_id = itemGrant.blank? ? "" : itemGrant.id

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

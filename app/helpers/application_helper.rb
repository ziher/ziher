module ApplicationHelper
  def menu_active?(page_name)
    case page_name
    when :journal_finance
      "active" if
        request.path_parameters[:controller].to_s == "journals" and
        Journal.find_by_id(params[:id]) != nil and
        Journal.find_by_id(params[:id]).journal_type_id == 1
        # TODO: wywalić magic number

    when :journal_bank
      "active" if
        request.path_parameters[:controller].to_s == "journals" and
        Journal.find_by_id(params[:id]) != nil and
        Journal.find_by_id(params[:id]).journal_type_id == 2
        # TODO: wywalić magic number

    when :inventory
      "active" if current_page?(inventory_entries_path)

    when :units
      "active" if current_page?(units_path)

    when :groups
      "active" if current_page?(groups_path)

    when :categories
      "active" if current_page?(categories_path)

    when :journals
      "active" if current_page?(journals_path)

    when :journal_types
      "active" if current_page?(journal_types_path)

    when :users
      "active" if current_page?(users_path)

    when :inventory_sources
      "active" if current_page?(inventory_sources_path)

    when :reports_dropdown
      "active" if
        false

    when :administration_dropdown
      "active" if
        current_page?(units_path) or
        current_page?(groups_path) or
        current_page?(categories_path) or
        current_page?(journals_path) or
        current_page?(journal_types_path) or
        current_page?(users_path) or
        current_page?(inventory_sources_path)
    end
  end

  def render_boolean_icon(value)
    return value ? "<i class='icon-ok'>".html_safe : "<i class='icon-minus'>".html_safe
  end
end

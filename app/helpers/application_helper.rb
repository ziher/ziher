module ApplicationHelper
  def menu_active?(page_name)
    case page_name
    when :journal_finance
      "active" if (
        request.path_parameters[:controller].to_s == "journals" &&
        Journal.find_by_id(params[:id]) != nil &&
        Journal.find_by_id(params[:id]).journal_type_id == 1
      ) || (
        current_page?(new_entry_path) &&
        Journal.find_by_id(params[:journal_id]) != nil &&
        Journal.find_by_id(params[:journal_id]).journal_type_id == 1
      )
      # TODO: wywalić magic number

    when :journal_bank
      "active" if (
        request.path_parameters[:controller].to_s == "journals" &&
        Journal.find_by_id(params[:id]) != nil &&
        Journal.find_by_id(params[:id]).journal_type_id == 2
      ) || (
        current_page?(new_entry_path) &&
        Journal.find_by_id(params[:journal_id]) != nil &&
        Journal.find_by_id(params[:journal_id]).journal_type_id == 2
      )
      # TODO: wywalić magic number

    when :inventory
      "active" if
        current_page?(inventory_entries_path) ||
        current_page?(new_inventory_entry_path)

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

    when :audits
      "active" if current_page?(audits_index_path)

    when :finance_report
      "active" if current_page?(finance_report_path)

    when :finance_one_percent_report
      "active" if current_page?(finance_one_percent_report_path)

    when :all_finance_report
      "active" if current_page?(all_finance_report_path)

    when :all_finance_one_percent_report
      "active" if current_page?(all_finance_one_percent_report_path)

    when :reports_dropdown
      "active" if
          current_page?(finance_report_path) or
          current_page?(finance_one_percent_report_path) or
          current_page?(all_finance_report_path) or
          current_page?(all_finance_one_percent_report_path)

    when :administration_dropdown
      "active" if
        current_page?(units_path) or
        current_page?(groups_path) or
        current_page?(categories_path) or
        current_page?(grants_path) or
        current_page?(journals_path) or
        current_page?(journal_types_path) or
        current_page?(users_path) or
        current_page?(inventory_sources_path) or
        current_page?(audits_index_path)
    end
  end

  def render_boolean_icon(value)
    return value ?
        "<span class='glyphicon glyphicon-ok'></span>".html_safe :
        "<i class='glyphicon glyphicon-minus'></i>".html_safe
  end

  def render_boolean_icon_centered(value)
    return ("<div class='text-center'>" + render_boolean_icon(value) + "</div>").html_safe
  end

  include Pagy::Frontend

end

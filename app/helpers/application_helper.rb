module ApplicationHelper
  def menu_active?(page_name)
    case page_name
    when :journal_finance
      "active" if false

    when :journal_bank
      "active" if false

    when :journal_inventory
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

    when :administration_dropdown
      "active" if
        current_page?(units_path) or
        current_page?(groups_path) or
        current_page?(categories_path) or
        current_page?(journals_path) or
        current_page?(journal_types_path) or
        current_page?(users_path)

    end
  end
end

module ApplicationHelper
  def menu_active?(page_name)
    "active" if current_page?(page_name)
  end
end

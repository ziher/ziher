class Category < ActiveRecord::Base
#commented out until this becomes valid
  #validates :order, :presence => true

  def Category.get_all_years
    years = []
    Category.all.each do |category| 
      years << category.year
    end
    return years.uniq.sort
  end

  def Category.find_by_year_and_type(year, isExpense)
    Category.find(:all, :conditions => {:year => year, :isExpense => isExpense}, :order => "'order' ASC")
  end
end

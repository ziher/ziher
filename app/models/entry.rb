class Entry < ActiveRecord::Base
  has_many :items

  def get_amount_for_category(categoryID)
    result = self.items.find(:first, :conditions=>{:category_id=>categoryID})

    if result != nil
      return result.amount
    else
      return 0
    end
  end
end

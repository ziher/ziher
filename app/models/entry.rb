class Entry < ActiveRecord::Base
	include ActiveModel::Validations

	has_many :items

	validates :items, :presence => true, :allow_blank => false
	validate :cannot_have_multiple_items_in_one_category, :on => :create

	def get_amount_for_category(categoryID)
		result = self.items.find(:first, :conditions=>{:category_id=>categoryID})

		if result != nil
			return result.amount
		else
			return 0
		end
	end

	def cannot_have_multiple_items_in_one_category
		if items.blank?
			errors[:items] << "Wpis musi miec co najmniej jedna sume"
		end
		categories = []
		items.each do |item|
			categories << item.category.id
		end

		if categories.length != categories.uniq.length
			errors[:items] << 'Wpis nie moze miec kilku sum z tej samej kategorii'
		end
	
	end
end


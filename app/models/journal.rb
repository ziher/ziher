class Journal < ActiveRecord::Base
  belongs_to :journal_type
  has_many :entries

  validates :journal_type, :presence => true
  validate :cannot_have_duplicated_type

  def cannot_have_duplicated_type
    if self.journal_type and Journal.find_by_year_and_type(self.year, self.journal_type).size > 0
      errors[:journal_type] = I18n.t :journal_for_this_year_and_type_already_exists, :year => self.year, :type => self.journal_type.name, :scope => :journal
    end
  end

  def Journal.find_by_year_and_type(year, type)
    return Journal.where(:year => year, :journal_type_id => type.id)
  end
end

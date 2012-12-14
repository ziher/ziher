class Journal < ActiveRecord::Base
  belongs_to :journal_type
  has_many :entries
end

class Group < ActiveRecord::Base
  has_and_belongs_to_many :units
  has_and_belongs_to_many :users
  has_and_belongs_to_many :subgroups, :join_table => "subgroups", :class_name => "Group", :foreign_key => :subgroup_id
end

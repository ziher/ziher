class Group < ActiveRecord::Base
  has_and_belongs_to_many :units
  has_many :user_group_associations
  has_many :users, through: :user_group_associations
  has_and_belongs_to_many :subgroups, :join_table => "subgroups", :class_name => "Group", :association_foreign_key => :subgroup_id
end

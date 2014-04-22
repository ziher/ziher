class Group < ActiveRecord::Base
  has_and_belongs_to_many :units
  has_many :user_group_associations
  has_many :users, through: :user_group_associations
  has_and_belongs_to_many :subgroups, :join_table => "subgroups", :class_name => "Group", :association_foreign_key => :subgroup_id

  def Group.find_by_user(user, privileges = {})
    if (user.is_superadmin)
      groups = Group.order("name")
    else
      
      privileges_string = ""
      privileges.each { |key, value| privileges_string.concat(" and #{key} = #{value}") } 

      groups = Group.find_by_sql(["with recursive G as (
  select uga.group_id
    from user_group_associations uga
    where uga.user_id = :user_id
      #{privileges_string}
  union
  select subg.subgroup_id
    from subgroups subg
      inner join G on G.group_id = subg.group_id
)
select * from groups where id in (select group_id from G) order by name", 
        { :user_id => user.id }])
    end
  end

  def Group.find_all_subgroups(group)
    subgroups = group.subgroups.dup

    unless group.subgroups.empty?
      group.subgroups.each do |sub|
        Group.find_all_subgroups(sub).each do |recursive_sub|
          subgroups << recursive_sub
        end
      end
    end

    return subgroups
  end
end

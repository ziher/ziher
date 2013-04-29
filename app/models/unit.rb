class Unit < ActiveRecord::Base
  has_and_belongs_to_many :groups
  has_and_belongs_to_many :users

  def Unit.find_by_user(user)
    units = Unit.find_by_sql(["with recursive G as (
  select group_id, subgroup_id
    from subgroups
      where group_id in (select gus.group_id from groups_users gus where gus.user_id = :user_id)
  union all
  select subg.group_id, subg.subgroup_id
    from subgroups subg
      join G on G.subgroup_id = subg.group_id
)
select *
  from units u
    where 1=1
      and (u.id in (select uus.unit_id from units_users uus where uus.user_id = :user_id)
        or u.id in (select gu.unit_id from groups_units gu inner join groups_users gus on gus.group_id = gu.group_id where gus.user_id = :user_id)
        or u.id in (select gu.unit_id from groups_units gu where group_id in (select group_id from G union select subgroup_id from G)))", 
      { :user_id => user.id }])
  end
end

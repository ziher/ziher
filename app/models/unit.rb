class Unit < ActiveRecord::Base
  has_and_belongs_to_many :groups
  has_many :user_unit_associations
  has_many :users, through: :user_unit_associations
  has_many :journals
  has_many :inventory_entries

  def Unit.find_by_user(user)
    if (user.is_superadmin)
      units = Unit.order("name")
    else
      units = Unit.find_by_sql(["with recursive G as (
  select group_id, subgroup_id
    from subgroups
      where group_id in (select uga.group_id from user_group_associations uga where uga.user_id = :user_id)
  union all
  select subg.group_id, subg.subgroup_id
    from subgroups subg
      join G on G.subgroup_id = subg.group_id
)
select *
  from units u
    where 1=1
      and (u.id in (select uua.unit_id from user_unit_associations uua where uua.user_id = :user_id)
        or u.id in (select gu.unit_id from groups_units gu inner join user_group_associations uga on uga.group_id = gu.group_id where uga.user_id = :user_id)
        or u.id in (select gu.unit_id from groups_units gu where group_id in (select group_id from G union select subgroup_id from G)))", 
        { :user_id => user.id }])
    end
  end

  # Returns years for which the unit has journals of given type, plus current year.
  # Years are sorted oldest first.
  def find_journal_years(journal_type)
    result = self.journals.select{|journal| journal.journal_type == journal_type}.map{|journal| journal.year}
    result << Time.now.year
    result.uniq.sort
  end

end

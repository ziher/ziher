class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable, :invitable, :timeoutable
  audited except: [:encrypted_password, :confirmation_token, :invitation_token, :reset_password_token]

  has_many :user_group_associations, dependent: :destroy
  has_many :groups, through: :user_group_associations

  has_many :user_unit_associations, dependent: :destroy
  has_many :units, through: :user_unit_associations

  # validates :email, :presence => true

  def to_s
    return "User(#{self.id}, #{self.email})"
  end

  def name
    return self.first_name.to_s + " " + self.last_name.to_s
  end

  def status
    if self.confirmed_at == nil
      :invited
    else
      :active
    end
  end

  def valid_email
    self.email =~ /\A[^@]+@([^@]+\.|)zhr\.pl\z/
  end

  def active_for_authentication?
    super && !self.is_blocked
  end

  def find_groups(privileges = {})
    Group.find_by_user(self, privileges)
  end

  def can_manage_any_group
    self.is_superadmin || !self.groups_to_manage.empty?
  end

  def groups_to_manage
    find_groups({ :can_manage_groups => true })
  end

  def can_manage_group(group)
    Group.find_by_user(self, {:can_manage_groups => true}).include?(group)
  end

  def can_manage_any_unit
    self.is_superadmin || !self.find_units.empty?
  end

  def find_units
    Unit.find_by_user(self)
  end

  def can_view_unit_entries(unit)
    rights_to(unit)["can_view_entries"] == true
  end

  def can_view_entries(journal)
    can_view_unit_entries(journal.unit)
  end
  
  def can_manage_unit_entries(unit)
    rights_to(unit)["can_manage_entries"] == true
  end

  def can_manage_entries(journal)
    can_manage_unit_entries(journal.unit)
  end

  def can_close_unit_journals(unit)
    rights_to(unit)["can_close_journals"] == true
  end

  def can_close_journal(journal)
    can_close_unit_journals(journal.unit)
  end

  def rights_to(unit)
    rights = ApplicationRecord.connection.execute("select
  bool_or(can_view_entries) as can_view_entries, 
  bool_or(can_manage_entries) as can_manage_entries, 
  bool_or(can_close_journals) as can_close_journals,
  bool_or(can_manage_users) as can_manage_users 
  from (

with recursive G as (
  select uga.group_id, uga.group_id as subgroup_id, gu.unit_id
    from user_group_associations uga 
      left join groups_units gu on gu.group_id = uga.group_id
    where uga.user_id = #{self.id}
  union all
  select G.group_id, subg.subgroup_id, gu2.unit_id
    from subgroups subg
      inner join G on G.subgroup_id = subg.group_id
      left join groups_units gu2 on gu2.group_id = subg.subgroup_id
)

select 'U' as source, null as master_group, uua.can_view_entries, uua.can_manage_entries, uua.can_close_journals, uua.can_manage_users
  from user_unit_associations uua
  where uua.user_id = #{self.id}
    and uua.unit_id = #{unit.id}

union

select 'G', uga.group_id, uga.can_view_entries, uga.can_manage_entries, uga.can_close_journals, uga.can_manage_users
  from user_group_associations uga
  where uga.group_id in (select group_id from G where G.unit_id = #{unit.id})
    and uga.user_id = #{self.id}
) as x")[0]
  end
  
  def can_manage_user(other_user)
    self.users_to_manage.include? other_user
  end
  
  def can_manage_any_user
    self.is_superadmin || !self.users_to_manage.empty?
  end

  def users_to_manage
    if (self.is_superadmin)
      User.order("email")
    else
      User.find_by_sql("select * from users where id in (
with recursive G as (
  select uga.user_id, uga.group_id, uga.group_id as subgroup_id, gu.unit_id
    from user_group_associations uga 
      left join groups_units gu on gu.group_id = uga.group_id
    where uga.can_manage_users = 't'
  union all
  select G.user_id, G.group_id, subg.subgroup_id, gu2.unit_id
    from subgroups subg
      inner join G on G.subgroup_id = subg.group_id
      left join groups_units gu2 on gu2.group_id = subg.subgroup_id
)

select uua.user_id
  from user_unit_associations uua
  where uua.unit_id in (select G.unit_id from G where G.user_id = #{self.id})
    and uua.user_id <> #{self.id}
    and not exists (select G1.unit_id from G as G1 where exists (select 1 from G as G2 where G2.unit_id = G1.unit_id and G2.user_id = uua.user_id) and not exists (select 1 from G as G3 where G3.unit_id = G1.unit_id and G3.user_id = #{self.id}))

union

select G.user_id
  from G 
  where G.unit_id in (select G.unit_id from G where G.user_id = #{self.id})
    and G.user_id <> #{self.id}
    and not exists (select G1.unit_id from G as G1 where exists (select 1 from G as G2 where G2.unit_id = G1.unit_id and G2.user_id = G.user_id) and not exists (select 1 from G as G3 where G3.unit_id = G1.unit_id and G3.user_id = #{self.id}))
)")
    end
  end

protected

  def password_required?
    false
  end

  def confirmation_required?
    false
  end
end

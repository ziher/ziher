class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable, :invitable

  has_many :user_group_associations
  has_many :groups, through: :user_group_associations

  has_many :user_unit_associations
  has_many :units, through: :user_unit_associations

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :is_superadmin, :confirmed_at, :confirmation_sent_at, :units, :unit_ids, :groups, :group_ids, :is_blocked

  def status
    if self.confirmed_at == nil
      :invited
    else
      :active
    end
  end

  def active_for_authentication?
    super && !self.is_blocked
  end

  def find_units
    Unit.find_by_user(self)
  end

  def can_view_entries(journal)
    rights_to(journal.unit)["can_view_entries"] == "t"
  end
  
  def can_manage_entries(journal)
    rights_to(journal.unit)["can_manage_entries"] == "t"
  end
  
  def rights_to(unit)
    rights = self.connection.execute("select bool_or(can_view_entries) as can_view_entries, bool_or(can_manage_entries) as can_manage_entries from (

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

select 'U' as source, null as master_group, uua.can_view_entries, uua.can_manage_entries
  from user_unit_associations uua
  where uua.user_id = #{self.id}
    and uua.unit_id = #{unit.id}

union

select 'G', uga.group_id, uga.can_view_entries, uga.can_manage_entries
  from user_group_associations uga
  where uga.group_id in (select group_id from G where G.unit_id = #{unit.id})
) as x")[0]
  end


protected

  def password_required?
    false
  end

  def confirmation_required?
    false
  end
end

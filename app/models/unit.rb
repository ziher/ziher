class Unit < ActiveRecord::Base
  audited

  default_scope { order(:code, :name) }

  has_and_belongs_to_many :groups
  has_many :user_unit_associations
  has_many :users, through: :user_unit_associations
  has_many :journals
  has_many :inventory_entries

  # validates :name, :presence => true
  # validates :code, :presence => true

  def Unit.find_by_user(user, is_active = true)
    if (user.is_superadmin)
      return Unit.where(is_active: is_active)
    end

    return Unit.find_all_by_user(user)
               .select{|unit| unit.is_active == is_active and user.can_view_unit_entries(unit)}
  end

  def Unit.get_default_unit(user, unit_id = nil)
    user_units = Unit.find_by_user(user)

    if unit_id.nil?
      return user_units.first
    end

    if unit_id.in? user_units.map{|unit| unit.id}
      return user_units.find{ |unit| unit.id == unit_id }
    end

    if unit_id.in? Unit.find_by_user(user, false).map{|unit| unit.id}
      return user_units.first
    end

    return nil
  end

  # Returns years for which the unit has journals of given type, plus current year.
  # Years are sorted oldest first.
  def find_journal_years(journal_type)
    result = self.journals.where(journal_type_id: journal_type.id).map{|journal| journal.year}
    result << Time.now.year
    result.uniq.sort
  end

  def initial_finance_balance(year)
    journal = get_journal_by_type_and_year(JournalType::FINANCE_TYPE_ID, year)
    if journal.nil?
      nil
    else
      journal.initial_balance
    end
  end

  def initial_finance_balance_one_percent(year)
    journal = get_journal_by_type_and_year(JournalType::FINANCE_TYPE_ID, year)
    if journal.nil?
      nil
    else
      journal.initial_balance_one_percent
    end
  end

  def initial_bank_balance(year)
    journal = get_journal_by_type_and_year(JournalType::BANK_TYPE_ID, year)
    if journal.nil?
      nil
    else
      journal.initial_balance
    end
  end

  def initial_bank_balance_one_percent(year)
    journal = get_journal_by_type_and_year(JournalType::BANK_TYPE_ID, year)
    if journal.nil?
      nil
    else
      journal.initial_balance_one_percent
    end
  end

  def full_name
    return self.code.blank? ? "#{self.name}" : "#{self.code} - #{self.name}"
  end

  def unit_has_open_journals
    open_journals = self.journals.where(is_open: true)
    if open_journals.count > 0
      errors[:journal] << "jednostka posiada niezamknięte książki " + open_journals.map(&:id).join(', ')
      return false
    end

    return true
  end

  def verify_unit
    return false unless unit_has_open_journals

    return true
  end

  def disable
    if verify_unit then
      self.is_active = false
      return self.save!
    else
      return false
    end
  end

  private

  def Unit.find_all_by_user(user)
    if (user.is_superadmin)
      units = Unit.all
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

  def get_journal_by_type_and_year(type, year)
    return self.journals.where(journal_type_id: type, year: year).first
  end
end

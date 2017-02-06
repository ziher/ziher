class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    if user.is_superadmin
      can :manage, :all
    else
#      cannot :manage, :all

# Entry
      can :read, Entry do |entry|
        user.can_view_entries(entry.journal)
      end

      can [:create, :update, :destroy], Entry do |entry|
        user.can_manage_entries(entry.journal)
      end

# Group
      can :read, Group do |group|
        user.groups_to_manage.include?(group)
      end
      can :update, Group do |group|
        user.groups_to_manage.include?(group)
      end
      can :destroy, Group do |group|
        user.groups_to_manage.index { |g| g.subgroups.include?(group) } != nil # A user cannot destroy the topmost group they are assigned to.
      end

# Journal
      can :default, Journal

      can :read, Journal do |journal|
        user.can_view_entries(journal)
      end

      can :update, Journal do |journal|
        user.can_manage_entries(journal)
      end
      
      can [:close, :open], Journal do |journal|
        user.can_close_journal(journal)
      end

# Inventory
      can :read, InventoryEntry do |inventory|
        user.can_view_unit_entries(inventory.unit)
      end

      can [:create, :update, :delete], InventoryEntry do |inventory|
        user.can_manage_unit_entries(inventory.unit)
      end

# Unit
      can :manage, Unit do |unit|
        !(unit.groups & user.find_groups({ :can_manage_units => true })).empty?
      end

      can :view_unit_entries, Unit do |unit|
        user.can_view_unit_entries(unit)
      end
# User

      alias_action :read, :destroy, :to => :crud

      can :crud, User do |other_user|
        user.can_manage_user(other_user)
      end

      can :create, User do |other_user|
        user.can_manage_user(other_user)
      end

      can :update, User do |other_user|
        user.can_manage_user(other_user)
      end

      can :set_superadmin, User if user.is_superadmin?

# UserGroupAssociation
      can :manage, UserGroupAssociation do |uga|
        uga.new_record? || user.can_manage_user(uga.user)
      end
      
# UserUnitAssociation
      can :manage, UserUnitAssociation do |uua|
        user.can_manage_user(uua.user)
      end

    end
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end

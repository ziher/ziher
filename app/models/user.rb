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

protected

  def password_required?
    false
  end

  def confirmation_required?
    false
  end
end

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable, :invitable

  has_and_belongs_to_many :groups
  has_and_belongs_to_many :units

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

protected

  def password_required?
    false
  end

  def confirmation_required?
    false
  end
end

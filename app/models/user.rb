class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  ROLES = %w[admin librarian member].freeze

  validates :role, presence: true, inclusion: { in: ROLES }

  def admin?
    role == "admin"
  end

  def librarian?
    role == "librarian"
  end

  def member?
    role == "member"
  end
end

class BookLoanPolicy < ApplicationPolicy
  # NOTE: Up to Pundit v2.3.1, the inheritance was declared as
  # `Scope < Scope` rather than `Scope < ApplicationPolicy::Scope`.
  # In most cases the behavior will be identical, but if updating existing
  # code, beware of possible changes to the ancestors:
  # https://gist.github.com/Burgestrand/4b4bc22f31c8a95c425fc0e30d7ef1f5

  class Scope < ApplicationPolicy::Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      if user.admin? || user.librarian?
        scope.all
      else
        scope.joins(:member).where(members: { id: user.id })
      end
    end
  end

  def index?
    staff?
  end

  def show?
    staff? || record.member_id == user.id
  end

  def create?
    staff?
  end

  def update?
    staff?
  end

  def destroy?
    admin?
  end

  def return?
    staff?
  end

  def extend?
    staff? || record.member_id == user.id
  end
end

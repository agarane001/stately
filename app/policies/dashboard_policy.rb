class DashboardPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin? || user.librarian?
        scope.all
      else
        scope.where(member_id: user.id)
      end
    end
  end

  def index?
    true  # Allow all authenticated users to view the dashboard
  end
end

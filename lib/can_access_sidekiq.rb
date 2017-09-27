# Used by router to determine whether the current user is allowed to access Sidekiq web admin.
class CanAccessSidekiq
  def self.matches?(request)
    return false unless request.env['rack.session'] && request.env['rack.session']['user_id']
    current_user = User.find request.env['rack.session']['user_id']
    return false unless current_user
    Ability.new(current_user).can? :manage, Sidekiq
  end
end

# An error that is raised when a {User} is signed in and tries to add an OAuth account
# that is already connected with a different user.
class AuthIdentityAlreadyTakenError < StandardError
end

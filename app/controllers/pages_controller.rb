# Used for simple pages that are public and therefore lead to the Sign In page.
class PagesController < ApplicationController
  do_not_require_login
  skip_authorization_check
end

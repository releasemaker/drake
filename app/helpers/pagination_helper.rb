# frozen_string_literal: true

module PaginationHelper
  # The current page number being shown.
  def page
    params[:page] || 1
  end

  # The number of items being shown on the page.
  def per_page
    params[:per_page] || 25
  end
end

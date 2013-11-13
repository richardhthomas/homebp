module ApplicationHelper
  # ultimately I imagine this being defined by reading from a session array (:breadcrumb) which will be multidimensional, the second dimension containing the breadcrumb 'levels'. The level of the user would NOT be a link but the lower levels that lead to the current position would be.
  def breadcrumb
    "My account"
  end
end

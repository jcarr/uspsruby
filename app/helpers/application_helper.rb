module ApplicationHelper
  def render_title
    return @title if defined?(@title)
    "USPS Tracking"
  end
end

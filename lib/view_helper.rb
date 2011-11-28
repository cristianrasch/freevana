module ViewHelper
  def render_template(template)
    Tilt.new("views/#{template}.haml").render
  end
end

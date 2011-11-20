module ViewHelper
  def render_template(template, error=nil)
    if error
      Tilt.new("views/#{template}.haml").render { error }
    else
      Tilt.new("views/#{template}.haml").render
    end
  end
end

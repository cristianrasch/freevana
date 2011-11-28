require File.expand_path('helper', File.dirname(__FILE__))

scope do
  test 'GET on /' do
    visit '/'
    assert has_content?('Freevana')
  end
end

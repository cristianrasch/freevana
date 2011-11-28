require File.expand_path('helper', File.dirname(__FILE__))

scope do
  setup do
    {url: 'http://www.peliplay.com/cat-run/'}
  end
  test 'GET on /peliplay' do |params|
    visit "/peliplay?url=#{params[:url]}"
    assert has_content?('http://www.megaupload.com/?d=BH0KI5Y2&id=2911')
  end
end

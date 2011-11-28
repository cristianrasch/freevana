require 'rack/test'
require 'test/unit'
require File.expand_path('../app', File.dirname(__FILE__))

class CuevanaTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Cuba
  end
  
  def test_get_on_cuevana
    get '/cuevana', url: 'http://www.cuevana.tv/#!/peliculas/4293/melancholia'
    json = JSON(last_response.body.match(/({.+})/).captures.first)
    
    metadata = json['metadata']
    assert metadata
    assert metadata['id']
    assert metadata['type']
    
    sources = json['sources']
    assert sources
    assert sources['720']
    assert sources['720']['2']
    assert sources['720']['2'].first
    assert sources['360']
  end

  def test_post_on_cuevana
    post '/cuevana', :def => '720', :audio => '2', :host => 'wupload', :id => '4293', :type => 'pelicula'

    assert last_response.ok?
    assert_equal 'http://www.wupload.com/file/2569698462/?id=4293', last_response.body
  end
end

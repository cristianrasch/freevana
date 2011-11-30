Dir['./lib/**/*.rb'].each { |rb| require rb }

include ViewHelper

Cuba.use Rack::Static, root: 'public', urls: ['/css', '/images', '/js']

Cuba.define do
  on get do
    on 'cuevana', param('url') do |url|
      res.headers['Content-Type'] = 'application/json'
      sources = CuevanaHelper.new.sources(CGI.unescape(url))
      res.write JSON.generate(sources)
    end
    
    on 'peliplay', param('url') do |url|
      res.write PeliPlayHelper.new.source_url(url)
    end
    
    on true do
      res.write render_template('index')
    end
  end
  
  on post do
    on 'cuevana', param('def'), param('audio'), param('host'), param('id'), param('type') do |definition, audio, host, id, type|
      res.write CuevanaHelper.new.source_url(definition, audio, host, id, type)
    end
  end
end


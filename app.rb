Dir['./lib/**/*.rb'].each { |rb| require rb }

include URLHelper
include ViewHelper

Cuba.use Rack::Static, root: 'public', urls: ['/css', '/images']

Cuba.define do
  on get do
    on '' do
      res.write render_template('index')
    end
    
    on 'index', param('url') do |url|
      u = CGI.unescape(url)
      
      if valid_url?(u)
        res.write megaupload_url(u)
      else
        res.write 'You need to provide a valid URL!'
      end
    end
    
    on true do
      res.write 'You need to provide a URL!'
    end
  end
end


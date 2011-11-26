Dir['./lib/**/*.rb'].each { |rb| require rb }

include URLHelper
include ViewHelper

Cuba.use Rack::Static, root: 'public', urls: ['/css', '/images']

Cuba.define do
  on get do
    on '' do
      res.write render_template('new')
    end
  end
  
  on post do
    on 'new', param('url') do |url|
      if valid_url?(url)
        res.write megaupload_url(url)
      else
        res.write 'You need to provide a valid URL!'
      end
    end
    
    on true do
      res.write 'You need to provide a URL!'
    end
  end
end


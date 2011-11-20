Dir['./lib/**/*.rb'].each { |rb| require rb }

include URLHelper
include ViewHelper

Cuba.use Rack::Static, root: 'public', urls: ['/css']

Cuba.define do
  on get do
    on '' do
      res.write render_template('new')
    end
  end
  
  on post do
    on 'new', param('url') do |url|
      if valid_url?(url)
        mega_url = megaupload_url(url)
        
        if valid_url?(mega_url)
          res.redirect mega_url
        else
          res.write render_template('new', mega_url)
        end
      else
        res.write render_template('new', 'You need to provide a valid URL!')
      end
    end
    
    on true do
      res.write render_template('new', 'You need to provide a URL!')
    end
  end
end


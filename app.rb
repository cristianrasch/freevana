require 'rubygems'
require 'bundler/setup'
require 'nokogiri'
require 'open-uri'
require 'net/http'
require 'uri'
require 'cuba'
require 'haml'
require 'tilt'

Cuba.define do
  on get do
    on '' do
      res.write render_template('new')
    end
    
    on 'styles', extension('css') do |file|
      res['Content-Type'] = 'text/css'
      res.write render_stylesheet(file)
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

def megaupload_url(url)
  doc = Nokogiri::HTML(open(url))
  q_string_div = doc.at_css('#videoi')
  
  if q_string_div
    query_string = q_string_div.text
    id = query_string.match(/\Aid=(\d+)/).captures.first
    doc = Nokogiri::HTML(open("#{iframe_url(url)}?#{query_string}"))
    script = doc.at_css('#sources ul').text
    key = script[/goSource\('(.+)',\s?'megaupload'\)/, 1]

    # curl -d "key=d7d7b724c13637e667ffcc83fce4b8ba" -d "host=megaupload"
    #        -d "vars=id=4290" http://www.cuevana.tv/player/source_get

    uri = URI(source_url(url))
    Net::HTTP.post_form(uri, key: key, host: 'megaupload', vars: "&id=#{id}").body[/http.+/]
  else
    'Streaming site unsupported!'
  end
end

def valid_url?(url)
  url  =~ URI::regexp
end

def iframe_url(url)
  case url
  when /cuevana.tv/ then 'http://www.cuevana.tv/player/source'
  when /peliplay.com/ then 'http://www.peliplay.com/wp-content/plugins/streaming/video.php'
  end
end

def source_url(url)
  case url
  when /cuevana.tv/ then 'http://www.cuevana.tv/player/source_get'
  when /peliplay.com/ then 'http://www.peliplay.com/wp-content/plugins/streaming/get.php'
  end
end

def render_template(template, error=nil)
  if error
    Tilt.new("templates/#{template}.haml").render { error }
  else
    Tilt.new("templates/#{template}.haml").render
  end
end

def render_stylesheet(stylesheet)
  # @@stylesheets_cache ||= Tilt::Cache.new
  # @@stylesheets_cache.fetch(stylesheet) do
    File.open(File.join(File.dirname(__FILE__), 'styles', "#{stylesheet}.css")).read
  # end
end


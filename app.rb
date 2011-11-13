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
      res.write File.open(File.join(File.dirname(__FILE__), 'styles', "#{file}.css")).read
    end
  end
  
  on post do
    on 'new', param('url') do |cuevana_url|
      if cuevana_url  =~ URI::regexp
        res.redirect megaupload_url(cuevana_url)
      else
        res.write render_template('new', 'You need to provide a valid URL!')
      end
    end
    
    on true do
      res.write render_template('new', 'You need to provide a URL!')
    end
  end
end

def megaupload_url(cuevana_url)
  id = cuevana_url.match(/\d+/).to_s
  doc = Nokogiri::HTML(open(cuevana_url))
  query_string = doc.at_css('#videoi').text

  doc = Nokogiri::HTML(open("http://www.cuevana.tv/player/source?#{query_string}"))
  script = doc.at_css('#sources ul').text

  key = script[/goSource\('(.+)','megaupload'\)/, 1]

  # curl -d "key=d7d7b724c13637e667ffcc83fce4b8ba" -d "host=megaupload"
  #        -d "vars=id=4290" http://www.cuevana.tv/player/source_get

  uri = URI('http://www.cuevana.tv/player/source_get')
  Net::HTTP.post_form(uri, key: key, host: 'megaupload', vars: "&id=#{id}").body[/http.+/]
end

def render_template(template, error=nil)
  if error
    Tilt.new("templates/#{template}.haml").render { error }
  else
    Tilt.new("templates/#{template}.haml").render
  end
end
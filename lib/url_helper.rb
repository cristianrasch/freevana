module URLHelper
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
  
  private

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
end

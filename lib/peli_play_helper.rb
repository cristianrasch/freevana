class PeliPlayHelper
  def source_url(url)
    doc = Nokogiri::HTML(open(url))
    q_string_div = doc.at_css('#videoi')
    query_string = q_string_div.text
    id = query_string.match(/\Aid=(\d+)/).captures.first
    
    doc = Nokogiri::HTML(open("http://www.peliplay.com/wp-content/plugins/streaming/video.php?#{query_string}"))
    script = doc.at_css('#sources ul').text
    key = script[/goSource\('(.+)',\s?'megaupload'\)/, 1]
    
    uri = URI('http://www.peliplay.com/wp-content/plugins/streaming/get.php')
    Net::HTTP.post_form(uri, key: key, host: 'megaupload', vars: "&id=#{id}").body[/http.+/]
  end
end

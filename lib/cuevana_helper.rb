class CuevanaHelper
  def source_url(url)
    resource = cuevana_resource(url)
    id = url.match(%r(/(\d+)/)).captures.first
    
    doc = Nokogiri::HTML(open("http://www.cuevana.tv/player/sources?id=#{id}&tipo=#{resource}"))
    script = doc.css('script').detect { |js| js['src'].nil? }.text
    json = script.match(/({.+})/).captures.first
    hash = JSON(json)
    res = hash.keys.first
    audio = hash[res].keys.first
    host = hash[res][audio]
    
    uri = URI('http://www.cuevana.tv/player/source_get')
    url = Net::HTTP.post_form(uri, :def => res, :audio => audio, :host => host, 
                              :id => id, :tipo => resource).body
    url.match(/http.+id=\d+/).to_s
  end
  
  private
  
  def cuevana_resource(url)
    case url
    when /peliculas/ then 'pelicula'
    when /series/ then 'serie'
    end
  end
end

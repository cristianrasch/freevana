class CuevanaHelper
  def sources(url)
    resource = cuevana_resource(url)
    id = url.match(%r(/(\d+)/)).captures.first
    
    doc = Nokogiri::HTML(open("http://www.cuevana.tv/player/sources?id=#{id}&tipo=#{resource}"))
    script = doc.css('script').detect { |js| js['src'].nil? }.text
    json = script.match(/({.+})/).captures.first
    sources = JSON(json)
    {sources: sources, metadata: {id: id, type: resource}}
  end
  
  def source_url(res, audio, host, id, type)
    uri = URI('http://www.cuevana.tv/player/source_get')
    url = Net::HTTP.post_form(uri, :def => res, :audio => audio, :host => host, 
                              :id => id, :tipo => type).body
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

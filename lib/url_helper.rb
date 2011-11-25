module URLHelper
  def megaupload_url(url)
    helper = case url
             when /cuevana.tv/ then CuevanaHelper.new
             when /peliplay.com/ then PeliPlayHelper.new
             end
    helper ? helper.source_url(url) : 'Streaming site unsupported!'
  end
  
  def valid_url?(url)
    url  =~ URI::regexp
  end
end

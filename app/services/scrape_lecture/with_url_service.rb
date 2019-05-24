require 'open-uri'

class ScrapeLecture::WithUrlService < ScrapeLecture::BaseService
  attr_accessor :url

  def initialize(url)
    @url = url
  end

  def execute!
    doc = Nokogiri::HTML(open(@url))
    scrape(doc)
  rescue => e
    failed(e)
  else
    success
  end
end

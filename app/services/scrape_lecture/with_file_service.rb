class ScrapeLecture::WithFileService < ScrapeLecture::BaseService
  attr_accessor :file

  def initialize(file)
    @file = file
    super()
  end

  def execute!
    doc = Nokogiri::HTML(File.open(@file.path))
    scrape(doc)
  rescue => e
    failed(e)
  else
    success
  end
end

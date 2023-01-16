puts "Scraper de LinkedIn" + "\n"

require 'open-uri' # consultar a la plataforma
require 'nokogiri' # formatear, parsear a html
require 'csv' # escribir y leer csv
require 'time'

class Works
    attr_accessor :name, :subtitle, :location, :link 
  
    def initialize(name, subtitle, location, link)
      @name = name
      @subtitle = subtitle
      @location = location
      @link = link
    end
  
    def guardar(name, subtitle, location, link )
        CSV.open('works.csv', 'a') do |csv|
            csv << [name, subtitle, location, link]
        end
    end
end

link_cities = ["https://www.linkedin.com/jobs/search?keywords=computer%2Bscience&location=Berlin%2C%2BBerlin%2C%2BDeutschland&geoId=106967730&trk=public_jobs_jobs-search-bar_search-submit&currentJobId=3422463190&position=4&pageNum=0",
                "https://www.linkedin.com/jobs/search?keywords=Computer%2Bscience&location=Frankfurt%2C+Hessen%2C+Deutschland&geoId=106772406&trk=public_jobs_jobs-search-bar_search-submit&currentJobId=3422463190&position=4&pageNum=0",
                "https://www.linkedin.com/jobs/search?keywords=Computer%2Bscience&location=M%C3%BCnchen%2C+Bayern%2C+Deutschland&geoId=100477049&trk=public_jobs_jobs-search-bar_search-submit&currentJobId=3422463190&position=4&pageNum=0"]


link_cities.each do |link|

    datosHTML = URI.open(link)
    parsed_content = Nokogiri::HTML(datosHTML) # parsea el contenido
    work = parsed_content.css('.jobs-search__results-list').css('.base-card')

    work.each do |post|
        work_name = post.css('.sr-only').inner_text.strip  
        subtitle = post.css('.base-search-card__subtitle').inner_text.strip
        location= post.css('.job-search-card__location').inner_text.strip
        link_trabajo = post.css('.hidden-nested-link').attr('href').inner_text.strip
        puts "Trabajo: " + work_name
        puts "Empresa: " + subtitle
        puts "Localidad: " + location
        puts "Link: " + link_trabajo
        puts "\n"

        works  = Works.new(work_name, subtitle, location, link_trabajo)
        works.guardar(work_name, subtitle, location, link_trabajo)
    end

end





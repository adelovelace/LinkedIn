require 'selenium-webdriver'
require 'open-uri'
require 'nokogiri' # formatear, parsear a html
require 'csv' # escribir y leer csv
require 'time'

class Works
    attr_accessor :name, :location, :time_post, :actual_applications, :description
  
    def initialize(name, location, time_post, actual_applications, description)
      @name = name
      @location = location
      @time_post = time_post
      @actual_applications = actual_applications
      @description = description
    end
    
    def guardar(name, location, time_post, actual_applications, description)
        CSV.open('works.csv', 'a') do |csv|
            csv << [name, location, time_post,actual_applications,description]
        end
    end
end

driver = Selenium::WebDriver.for:firefox

driver.get "https://www.linkedin.com/login/de?fromSignIn=true&session_redirect=https%3A%2F%2Fwww.linkedin.com%2Fjobs&trk=guest_homepage-jobseeker_nav-header-signin"
sleep 5

driver.find_element(:id,"username").send_keys "anmero@fiec.espol.edu.ec"
sleep 5
driver.find_element(:id, "password").send_keys "TsubarashI19902506."
sleep 5

driver.find_element(:class,"btn__primary--large").click
sleep 5


link_cities = ["https://www.linkedin.com/jobs/search?keywords=computer%2Bscience&location=Berlin%2C%2BBerlin%2C%2BDeutschland&geoId=106967730&trk=public_jobs_jobs-search-bar_search-submit&currentJobId=3422463190&position=4&pageNum=0",
                "https://www.linkedin.com/jobs/search?keywords=Computer%2Bscience&location=Frankfurt%2C+Hessen%2C+Deutschland&geoId=106772406&trk=public_jobs_jobs-search-bar_search-submit&currentJobId=3422463190&position=4&pageNum=0",
                "https://www.linkedin.com/jobs/search?keywords=Computer%2Bscience&location=M%C3%BCnchen%2C+Bayern%2C+Deutschland&geoId=100477049&trk=public_jobs_jobs-search-bar_search-submit&currentJobId=3422463190&position=4&pageNum=0"]


link_cities.each do |link|
    
    driver.get link

    wait = Selenium::WebDriver::Wait.new(:timeout => 30)

    jobs_block= driver.find_element(:class, 'scaffold-layout__list-container')
    jobs_list= jobs_block.find_elements(:css, '.jobs-search-results__list-item')

    n = 0
    jobs_list.each do |job|
        
        wait = Selenium::WebDriver::Wait.new(:timeout => 30)
        n +=1 
        driver.execute_script("arguments[0].scrollIntoView();", jobs_list[n-1])
        wait = Selenium::WebDriver::Wait.new(:timeout => 60)
        puts "__________"
        puts n.to_s + " " + job.text
        job.click

        sleep 2
        
        #obtiene toda la descripción del trabajo 
        temp = driver.find_element(:class,'jobs-search__job-details--container')
        # puts temp

        #get the title of the job
        work_name = temp.find_element(:xpath, '/html/body/div[5]/div[3]/div[4]/div/div/main/div/section[2]/div/div[2]/div[1]/div/div[1]/div/div[1]/div[1]/a/h2')
        puts "Titulo del trabajo: " + work_name.text

        sleep 2
        
        #get location of the job
        location = temp.find_element(:xpath, '/html/body/div[5]/div[3]/div[4]/div/div/main/div/section[2]/div/div[2]/div[1]/div/div[1]/div/div[1]/div[1]/div[1]/span[1]')
        puts "Localidad del trabajo: " + location.text

        sleep 2

        #time of the posted 
        time_post = temp.find_element(:xpath,'/html/body/div[5]/div[3]/div[4]/div/div/main/div/section[2]/div/div[2]/div[1]/div/div[1]/div/div[1]/div[1]/div[1]/span[2]/span[1]')
        puts "Tiempo de posteo: " + time_post.text

        sleep 2

        #applications until the extraction
        actual_applications = temp.find_element(:xpath, '/html/body/div[5]/div[3]/div[4]/div/div/main/div/section[2]/div/div[2]/div[1]/div/div[1]/div/div[1]/div[1]/div[1]/span[2]/span[2]')
        puts "Aplicates actuales: " + actual_applications.text

        sleep 2

        #get the job description
        description = temp.find_element(:xpath, '//*[@id="job-details"]')
        puts "Description \n"
        puts description.text

        puts "\n"

        sleep 2

        works  = Works.new(work_name.text, location.text, time_post.text, actual_applications.text, description.text)
        works.guardar(work_name.text, location.text, time_post.text, actual_applications.text, description.text)

        wait = Selenium::WebDriver::Wait.new(:timeout => 60)
    
    end

   
    
end
# Or all of them
driver.manage.delete_all_cookies
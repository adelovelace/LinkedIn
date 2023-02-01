require 'selenium-webdriver'
require 'open-uri'
require 'nokogiri' # formatear, parsear a html
require 'csv' # escribir y leer csv
require 'time'

class Works
    attr_accessor :card_work_info, :job_title, :info_company, :company_name, :location, :working_mode, :time_post, :current_applications, :description
  
    def initialize(card_work_info,job_title,info_company,company_name, location,working_mode, time_post, current_applications, description)
      @card_work_info = card_work_info
      @job_title = job_title
      @info_company = info_company
      @company_name = company_name
      @location = location
      @working_mode = working_mode
      @time_post = time_post
      @current_applications = current_applications
      @description = description
    end
    
    def save_job(card_work_info,job_title,info_company,company_name,location, working_mode,time_post, current_applications, description)
        CSV.open('works.csv', 'a') do |csv|
            csv << [card_work_info,job_title,info_company,company_name,location, working_mode,time_post, current_applications, description]
        end
    end
end

CSV.open('works.csv', 'a') do |csv|
    csv << ["Card Job info","Job Title","Company Info","Company Name","Location", "Working mode","Time post", "Current Applicants", "Job Description"]
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


link_cities = ["https://www.linkedin.com/jobs/search/?currentJobId=3456041982&distance=0&geoId=106967730&keywords=computer%2Bscience&location=Berlin%2C%20Berlin%2C%20Germany&refresh=true",
                "https://www.linkedin.com/jobs/search/?currentJobId=3452194885&geoId=106150090&keywords=computer%2Bscience&location=Frankfurt%20am%20Main%2C%20Hesse%2C%20Germany&refresh=true",
                "https://www.linkedin.com/jobs/search/?currentJobId=3456041982&distance=0&geoId=100477049&keywords=computer%2Bscience&location=Munich%2C%20Bavaria%2C%20Germany&refresh=true"]


link_cities.each do |link|
    
    driver.get link

    wait = Selenium::WebDriver::Wait.new(:timeout => 30)

    jobs_block= driver.find_element(:class, 'scaffold-layout__list-container')
    jobs_list= jobs_block.find_elements(:css, '.jobs-search-results__list-item')

    n = 0
    jobs_list.each do |job|

        begin
        
            wait = Selenium::WebDriver::Wait.new(:timeout => 30)
            n +=1 
            driver.execute_script("arguments[0].scrollIntoView();", jobs_list[n-1])
            wait = Selenium::WebDriver::Wait.new(:timeout => 60)
            card_info = job.text
            puts "_____Card Info_____"
            puts n.to_s + " " + card_info
            puts "__________"
            job.click

            sleep 2
            
            #obtiene toda la descripción del trabajo
            temp = driver.find_element(:class,'jobs-search__job-details--container')

            #get the title of the job
            work_name = temp.find_element(:xpath, '/html/body/div[5]/div[3]/div[4]/div/div/main/div/section[2]/div/div[2]/div[1]/div/div[1]/div/div[1]/div[1]/a/h2')
            puts "Titulo del trabajo: " + work_name.text 
            
            sleep 2
            
            #get location of the job
            info_company = temp.find_element(:xpath, '/html/body/div[5]/div[3]/div[4]/div/div/main/div/section[2]/div/div[2]/div[1]/div/div[1]/div/div[1]/div[1]/div[1]/span[1]')
            puts "Info de empresa : " + info_company.text

            company = temp.find_element(:xpath,'//*[@id="ember133"]')
            puts "Empresa: " + company.text

            location = temp.find_element(:xpath,'/html/body/div[5]/div[3]/div[4]/div/div/main/div/section[2]/div/div[2]/div[1]/div/div[1]/div/div[1]/div[1]/div[1]/span[1]/span[2]')
            puts "Localización: " + location.text

            working_mode = temp.find_element(:xpath, '/html/body/div[5]/div[3]/div[4]/div/div/main/div/section[2]/div/div[2]/div[1]/div/div[1]/div/div[1]/div[1]/div[1]/span[1]/span[3]')
            puts "Modo de trabajo: " + working_mode.text

            sleep 2

            #time of the posted 
            time_post = temp.find_element(:xpath,'/html/body/div[5]/div[3]/div[4]/div/div/main/div/section[2]/div/div[2]/div[1]/div/div[1]/div/div[1]/div[1]/div[1]/span[2]/span[1]')
            puts "Tiempo de posteo: " + time_post.text     

            sleep 2

            #applications until the extraction
            current_applications = temp.find_element(:xpath, '/html/body/div[5]/div[3]/div[4]/div/div/main/div/section[2]/div/div[2]/div[1]/div/div[1]/div/div[1]/div[1]/div[1]/span[2]/span[2]')
            puts "Aplicantes actuales: " + current_applications.text

            sleep 2

            #get the job description
            # description = temp.find_element(:xpath, '/html/body/div[5]/div[3]/div[4]/div/div/main/div/section[2]/div/div[2]/div[1]/div/div[2]/article/div')
            description = temp.find_element(:id, 'job-details')
            puts "Descripción:  \n"
            puts description.text
        
            puts "\n"

            sleep 2

            works  = Works.new(card_info,work_name.text,info_company.text,company.text,location.text,working_mode.text, time_post.text, current_applications.text, description.text)
            works.save_job(card_info,work_name.text,info_company.text,company.text, location.text,working_mode.text, time_post.text, current_applications.text, description.text)

            wait = Selenium::WebDriver::Wait.new(:timeout => 60)
        rescue Exception => e
            puts e 
            puts "Do not found"
        end
    end

   
    
end
# Or all of them
driver.manage.delete_all_cookies
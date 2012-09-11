
##******************************************************************#
## Rubium automates some of a web developers work in firebug and other browser
## developer tools. It will take baseline CSS style information and check
## to see if the styles are currently available on the production site.
## 
## Helpful for large scale sites where multiple stylesheets may have conflict.
## Say for instance, one component developer is styling an OOB style and another
## developer is styling that same OOB style in seperate component code. This utility
## will verify the actual calculated style that takes precendence in a particular
## section of the DOM on a specific page in the web application.
module Rubium
  ##
  #external modules needed
  require 'rubygems'
  require 'optparse'
  require 'headless' #https://github.com/leonid-shevtsov/headless
  require 'selenium-webdriver' #https://github.com/vertis/selenium-webdriver/
  ##
  ##******************************************************************#
  ## Take CSS source code and generate config input parameters for analysis
  class FileScan
    ##
    ##*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def initialize()
    end
    ##
    ##*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ##
    def open(file)
      return File.open(file)
    end
    ##
    ##*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ##
    def search( parent_directory )
      Dir["#{parent_directory}/**/*"].each { |file|
        if file.include? ".css"
          #scan file, pull out 'expected' styles
          open(file).each { |line|
            #delimit the id or class selector line
            if line.include? "." or line.include? "#"
            
            end
          }
        end
      } 
    end
  end
  ##
  ##******************************************************************#
  ## Take user input and build array of actionable tests
  class Utility
    ##
    ##*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ##
    def initialize()
      @ref = Struct.new(:url,:query,:style)
    end
    ##
    ##*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ## Parse command line, examine query and style options
    ## Each option takes a comma delimited input
    ##
    def parse(args)
      actions,urls,queries,styles = [],[],[],[]
      
      OptionParser.new do |opts|
        opts.banner = "Usage: rubium.rb [options]"
  
        opts.on("-u x,y,z", "--[no-]url x,y,z",
              Array, "Comma delimited URL strings for which to navigate to") { |u| urls = u }
              
        opts.on("-q x,y,z", "--[no-]query x,y,z",
              Array, "Comma delimited query strings specifying the DOM node to inspect") { |q| queries = q }
      
        opts.on("-s x,y,z", "--[no-]style x,y,z",
              Array, "Comma delimited strings with the CSS style in inspect") { |s| styles = s }

        opts.on_tail("-v", "--version", "Show version") do
          puts "@1321"
          exit
        end
      
      end.parse!
      
      urls.each do |url|
        queries.each do |query|
          styles.each do |style|
            actions.push( @ref.new(url,query,style) )
          end
        end
      end
      
      return actions
    end
  end
  ##
  ##******************************************************************#
  ## Driver respobile for setting up Selenium WebDriver
  ##  1/ Initialize WD
  ##  2/ Invoke main(), begin logging
  ##  3/ Wait for user input
  ##     a. use external config file listing all css selectors and styles to examine
  ##     b. point to stylesheets directory on local filesystem and use FileScan to build config file
  ##     c. provide command arguments for testing a single style on a single dom node 
  class Driver
    ##*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ## Driver.new 
    ## Set up Headless server
    ## Initialize @driver with WebDriver instance
    def initialize()
    
      headless = Headless.new
      headless.start
      
      @fs = Rubium::FileScan.new
      @utl = Rubium::Utility.new
      @wd = Selenium::WebDriver.for :firefox
      
      begin #main exception handler
        total_time = measure_duration(:main)  
        puts "total time #{total_time}"
      rescue Selenium::WebDriver::Error::UnknownError
        puts "Rubium has encountered an unknown error."
      end
  
      headless.destroy
    
    end
    ##
    ##*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ## Utility timer
    ## Capture duration of a particular method invocation
    def measure_duration(method) #return String
      t0=Time.now; self.send(method); t1=Time.now;
      return "#{(t1-t0)}"
    end
    ##
    ##*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ## Fire method when document ready
    ## and all needed elements are available
    def on_ready( method )
	  count=0
	  begin
	    ready=false
	    begin
	      self.send(method)
	      ready = true
	    rescue Selenium::WebDriver::Error::NoSuchElementError
	      count+=1
	      if count>500
	        ready=true
	      end
	    end  
	  end while not ready
    end
    ##
    ##*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ## Obtain the calculated style on a specifed dom node
    ## @fixme: target web application must support jQuery
    ##
    def get_calculated_style( query, style )
      #begin assemble javascript
      script = "return jQuery('"
      
      #selector query
      script << "#{query}"
      script << "').css('"
      
      #css styles to verify
      script << "#{style}"
      script << "');"
      
      begin
        return @wd.execute_script("#{script}")
	  rescue Selenium::WebDriver::Error::JavascriptError
	    return "Unable to obtain"
	  end
	end
	##
	##*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	##
	def main()
	
	  @utl.parse(ARGV).each do |action|
	  
	    @wd.navigate.to "#{action[:url]}"
	    
	    puts "Getting value for $('#{action[:query]}').css('#{action[:style]}')"
	    current_value = get_calculated_style(action[:query],action[:style])
	    
	    puts "current #{current_value}"
	    
	  end
	  
	end
  end
end

Rubium::Driver.new

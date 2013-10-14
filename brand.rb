#!/usr/bin/env ruby

require 'fileutils'
require 'rbconfig'

def os
    @os ||= (
        host_os = RbConfig::CONFIG['host_os']
        case host_os
        when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
          :windows
        when /darwin|mac os/
          :macosx
        when /linux/
          :linux
        when /solaris|bsd/
          :unix
        else
          raise Error::WebDriverError, "unknown os: #{host_os.inspect}"
        end
    )
end

def colorize(text, color_code)
    # Disable on windows
    if os == :windows
        text
    else
        "\e[#{color_code}m#{text}\e[0m"
    end
end

def green(text)
    colorize(text, 32)
end

def ask(question, options = {})
    defaults = {
        :new_block => false,
        :color => 32
    }
    defaults.merge(options).each do |attr, val|
        instance_variable_set("@#{attr}", val) if defaults.has_key?(attr) && (not val.nil?)
    end if options
    
    print "\n" if @new_block
    
    print colorize(question, @color)
    
    gets.chomp
end

def confirm?(question)
    result = ask(question + " (Y/N) ", :new_block => true)
    result.downcase == "y"
end

# Ask for information
foobar = ask("Replace \"foobar\" in module name with? ")
Foobar = ask("Replace \"Foobar\" in class name with? ")
FOOBAR = ask("Replace \"FOOBAR\" in language constants with? ")
author_name = ask("Module's author name? ")
author_email = ask("Module's author email? ")
author_domain = ask("Module's author domain? ")

puts green("\nPlease review...") # Green text

puts "Module name:\t\tmod_foobar\t-> mod_#{foobar}"
puts "Class name:\t\tmodFoobar\t-> mod#{Foobar}"
puts "Language constants:\tMOD_FOOBAR\t-> MOD_#{FOOBAR}"

if confirm?("Proceed?")
    # Remove existing module
    if Dir.exists?("../mod_#{foobar}")
        if confirm?("mod_#{foobar} already exists, do you want to remove it first?")
            FileUtils.rm_rf "../mod_#{foobar}", :verbose => true
        else
            return # avoid error
        end
    end
    # Copy module structure
    puts "\n" + green("Copying module structures...")
    FileUtils.cp_r "../mod_foobar", "../mod_#{foobar}", {:verbose => true}
    
    # Remove git
    puts "\n" + green("Removing revision controls, script files and README")
    FileUtils.cd "../mod_#{foobar}"
    FileUtils.rm_rf ".git", :verbose => true
    FileUtils.rm "README.md", :verbose => true
    Dir.glob("brand*") { |script| FileUtils.rm script, :verbose => true }
    
    # Rename files
    puts "\n" + green("Renaming files...")
    Dir.glob("*foobar*") do |filename|
        FileUtils.mv filename, filename.sub('foobar', foobar), :force => true, :verbose => true
    end
    
    # Search and replace in files
    puts "\n" + green("Changing module name...")
    `ruby -pi.bak -e "gsub('foobar', '#{foobar}')" *.ini **/*.php *.xml`
    
    puts green("Changing class name...")
    `ruby -pi.bak -e "gsub('Foobar', '#{Foobar}')" *.ini **/*.php *.xml`
    
    puts green("Changing language constants...")
    `ruby -pi.bak -e "gsub('FOOBAR', '#{FOOBAR}')" *.ini **/*.php *.xml`
    
    puts green("Updating author name...")
    `ruby -pi.bak -e "gsub('DZ Team', '#{author_name}')" *.ini **/*.php *.xml`

    puts green("Updating author email...")
    `ruby -pi.bak -e "gsub('dev@dezign.vn', '#{author_email}')" *.ini **/*.php *.xml`

    puts green("Updating author domain...")
    `ruby -pi.bak -e "gsub('dezign.vn', '#{author_domain}')" *.ini **/*.php *.xml`

    # Remove backup files
    puts green("Removing backup files...")
    Dir.glob("*.bak").each {|file| FileUtils.rm file, :verbose => true}

    # Support auto generate more language files
    if confirm?("Do you want to generate additional language files besides en-GB (Y/N)?")
        # XML tags of language files
        xml_tags = Array.new
        xml_tags << '<language tag="en-GB">en-GB.mod_test.sys.ini</language>'
        
        # Additional tags from user
        tags = ask("Specify additional comma-separated language tags: ")
        tags.split(',').each do |tag|
            Dir.glob("en-GB*") do |lang_file|
                FileUtils.cp lang_file, lang_file.sub('en-GB', tag.strip), :verbose => true
            end
            xml_tags << "<language tag=\"#{tag}\">#{tag}.mod_#{foobar}.ini</language>"
            xml_tags << "<language tag=\"#{tag}\">#{tag}.mod_#{foobar}.sys.ini</language>"
        end
        
        # Search for the last en-GB tag then replace with additional tags
        File.write(f = "mod_#{foobar}.xml", File.read(f).sub(xml_tags[0], xml_tags.join("\n        ")))
    end
    
    # Generate new git repository if git is available
    puts green("\nChecking git version...")
    result = system 'git --version'
    if !result.nil?
        if confirm?("Git is available on your system. Do you want to create a new repository now?")
            puts 'git init .'
            `git init .`
        end
    else
        puts green('Git is not available on your system!')
    end
    
    puts green("\nModule mod_#{foobar} has been generated successfully!")
    if confirm?("Open mod_#{foobar} folder now?")
        if os == :windows
            `explorer ..\\mod_#{foobar}`
        elsif os == :macosx
            `open ../mod_#{foobar}` 
        else
            `xdg-open ../mod_#{foobar}`
        end
    end
end
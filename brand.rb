#!/usr/bin/env ruby

require 'fileutils'

def colorize(text, color_code)
  "\e[#{color_code}m#{text}\e[0m"
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

foobar = ask("Replace \"foobar\" with? ")
Foobar = ask("Replace \"Foobar\" with? ")
FOOBAR = ask("Replace \"FOOBAR\" with? ")

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
    `ruby -pi -e "gsub('foobar', '#{foobar}')" *.ini **/*.php *.xml`
    
    puts green("Changing class name...")
    `ruby -pi -e "gsub('Foobar', '#{Foobar}')" *.ini **/*.php *.xml`
    
    puts green("Changing language constants...")
    `ruby -pi -e "gsub('FOOBAR', '#{FOOBAR}')" *.ini **/*.php *.xml`
    
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
    git_version = `git --version`
    if !git_version.nil?
        if confirm?("#{git_version.chomp} is available on your system. Do you want to create a new repository now?")
            puts 'git init .'
            `git init .`
        else
            puts green('Git is not available on your system!')
        end
    end
    
    puts green("\nModule mod_#{foobar} has been generated successfully! Navigate to the parent of this folder to see the new one.")
end
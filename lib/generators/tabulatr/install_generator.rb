puts "a"

class Tabulatr
  puts "b"
  
  module Generators
    puts "c"
    
    class InstallGenerator < Rails::Generators::Base
      puts "d"
      desc "Copy Tabulatr default files"
      source_root File.expand_path('../../../assets/', __FILE__)

      def copy_initializers
        puts "lala1"
#        copy_file 'simple_form.rb', 'config/initializers/simple_form.rb'
      end

      def copy_locale_file
        puts "lala2"
#        copy_file 'en.yml', 'config/locales/simple_form.en.yml'
      end

      def copy_scaffold_template
        puts "lala3"
#        copy_file "_form.html.#{engine}", "lib/templates/#{engine}/scaffold/_form.html.#{engine}"
      end
      
    end
  end
end

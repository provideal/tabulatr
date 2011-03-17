module Tabulatr
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc "Copy Tabulatr default files"
      source_root File.expand_path('../templates', __FILE__)
      class_option :template_engine

      def copy_initializers
        puts "hooray!!!1111elf"
        #copy_file 'simple_form.rb', 'config/initializers/simple_form.rb'
      end
      
    end
  end
end

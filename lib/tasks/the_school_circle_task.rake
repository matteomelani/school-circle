if (Rails.env=='test' || Rails.env=='development')   

  require 'rspec/core/rake_task' 
  require 'cucumber/rake/task'
  
  namespace :tsc do     
    
    ## Tasks defined in the :private namespace are to be use only by other tasks. They must not appear in the 
    ## rake -T command output.
    namespace :private do

      desc '' # intentionally left blank so that the task does not appear in the rake -T output 
      RSpec::Core::RakeTask.new(:run_unit_tests) do |t|
        t.pattern="./**/*_spec.rb"
        t.rspec_opts = ["--format progress"]
      end

      # second parameter is intentionally left blank so that the task does not appear in the rake -T output 
      Cucumber::Rake::Task.new(:run_acceptance_tests, '') do |t|
        t.cucumber_opts = ["--tags ~@selenium" ]
      end

    end

    ## The :test namespace groups all the rake task related to testing.
    ##
    namespace :test do

      desc "Run all the TSC unit tests. TSC unit tests are implemented as specs."
      task :unit do
        puts "\n-------------------------------  RUNNING UNIT TESTS (SPECS) -------------------------------"    
        # Rake::Task["db:test:prepare"].invoke
        ENV['SPEC'] = "./spec/models/ ./spec/lib/"
        Rake::Task["tsc:private:run_unit_tests"].invoke    
      end

      desc "Run all the TSC acceptance tests. TSC acceptance tests are implemented with cucumber and caybara."
      task :acceptance do
        puts "\n-------------------------------  RUNNING ACCEPTANCE TESTS (CUCUMBER) -------------------------------"    
        Rake::Task["tsc:private:run_acceptance_tests"].invoke
      end


    end

  end

end
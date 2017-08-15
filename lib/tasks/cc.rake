# require 'rspec/core/rake_task'
# require 'cucumber/rake/task'
# 
# desc "CruiseControl.rb (CC) main task"
# namespace :cc do
#   task :all do
#     # rebuild the db
#     Rake::Task['db:drop'].invoke
#     Rake::Task['db:create'].invoke
#     Rake::Task['db:migrate'].invoke
#     Rake::Task['db:test:prepare'].invoke
# 
#     # run all the unit tests (rspecs)
#     Rake::Task['cc:specs'].invoke
# 
#     # run all the acceptance tests (cucumber)
#     Rake::Task['cc:features'].invoke
# 
#     # run the deploy task
#     Rake::Task['deploy:all'].invoke
# 
#     #TODO: run acceptance test against deployed build
#   end
# end
#
# 
# desc "Run all the specs (with rcov) and generates a report in html, txt and textmate format."
# namespace :cc do
#   RSpec::Core::RakeTask.new(:specs) do |t|
#     t.pattern = 'spec/models/*'
#     out_dir = ENV['CC_BUILD_ARTIFACTS'] || "./build_artifacts"
#     t.rspec_opts = ["-f html",
#                     "-o #{out_dir}/rspec_rep.html",
#                     "-f d",
#                     "-o #{out_dir}/rspec_rep.txt",
#                     "-f t",
#                     "-o #{out_dir}/rspec_rep.mate"
#                     ]
#     # t.rcov = true
#     #     t.rcov_opts = %w{--rails --exclude osx\/objc,gems\/,spec\/}
#     #     t.rcov_opts << %[-o "#{out_dir}/rspec_rcov"]
#   end
# end
# 
# desc "Run all the features (with rcov) and generates a report in html and txt format."
# namespace :cc do
# Cucumber::Rake::Task.new(:features) do |t|
#     out_dir = ENV['CC_BUILD_ARTIFACTS'] || "./build_artifacts"
#     t.cucumber_opts = ["--format pretty",
#                        "--out=#{out_dir}/features_rep.txt",
#                        "--format html",
#                        "--out=#{out_dir}/features_rep.html"
#                       ]  
#     # t.rcov = true
#     #     t.rcov_opts = %w{--rails --exclude osx\/objc,gems\/,spec\/}
#     #     t.rcov_opts << %[-o "#{out_dir}/features_rcov"]
#   end
# end

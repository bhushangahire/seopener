namespace :seopener do
  desc 'Copy migration files into main app'
  task :setup => :environment do
    dest = "#{RAILS_ROOT}/db/migrate"
    FileUtils.mkdir_p(dest)

    src = Dir.glob(File.dirname(__FILE__) + "/../db/migrate/*.rb")
    puts "Copying migrations to #{dest}"
    FileUtils.cp(src, dest)

    dest = "#{RAILS_ROOT}/public"
    src = Dir.glob(File.dirname(__FILE__) + "/../public/*")
    puts "Copying assets to #{dest}"
    FileUtils.cp_r(src, dest)
  end

  desc 'Run the queries for ALL of the search terms'
  task :query_all => :environment do
    Seo::SearchTerm.ordered.each do |term|
      puts "Querying: #{term.term}"
      sleep 1

      term.query!

      1.upto(4) do
        term.carefully_update_data!
        sleep 0.5
      end

    end
  end


end
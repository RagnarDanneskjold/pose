namespace :pose do

  desc "Creates the Pose tables in the database."
  task :install => :environment do
    Pose::Jobs::Install.new.perform
  end

  desc "Removes the Pose tables from the database."
  task :uninstall => :environment do
    Pose::Jobs::Uninstall.new.perform
  end

  desc "Cleans out unused data from the search index."
  task :vacuum => :environment do
    Pose::Jobs::Vacuum.new.perform
  end

  desc "Removes the search index for all instances of the given classes."
  task :remove, [:class_name] => :environment do |_, args|
    Pose::Jobs::Remove.new(args.class_name).perform
  end

  desc "Recreates the search index for all instances of the given class from scratch."
  task :reindex_all, [:class_name] => [:environment] do |_, args|
    Pose::Jobs::ReindexAll.new(args.class_name).perform
  end
end

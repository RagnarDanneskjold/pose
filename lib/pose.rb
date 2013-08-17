require 'active_record'
require 'pose/query'
require 'pose/search'
require 'pose/static_api'
require 'pose/helpers'
require 'pose/activerecord_base_additions'
require 'pose/model_class_additions'
require 'pose/assignment'
require 'pose/word'
require 'pose/jobs/reindex_all'
require 'pose/jobs/remove'
require 'pose/jobs/vacuum'
require 'pose/jobs/install'
require 'pose/jobs/uninstall'

Dir["tasks/**/*.rake"].each { |ext| load ext } if defined?(Rake)

ActiveRecord::Base.send :extend, Pose::ActiveRecordBaseAdditions
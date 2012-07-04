
namespace :election_data do
  desc "Call the default view for each event to build the cache"
  task :build_cache => [:environment] do
    require 'build_cache'

    # turn off the active record logging
    old_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil
    #build the cache
    BuildCache.run
    # turn active record logging back on
    ActiveRecord::Base.logger = old_logger
  end
end
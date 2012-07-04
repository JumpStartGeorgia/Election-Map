
namespace :election_data do
  desc "Call the default view for each event to build the cache"
  task :build_cache => [:environment] do
    require 'build_cache'

    #build the cache
    BuildCache.run
  end
end

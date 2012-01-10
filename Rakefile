require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "erector_cache"
    gem.summary = %Q{Caching for your Erector}
    gem.description = %Q{Caching for your Erector}
    gem.email = "mmol@grockit.com"
    gem.homepage = "http://github.com/grockit/erector_cache"
    gem.authors = ["Grockit"]
    gem.add_development_dependency "rspec", ">= 1.2.6"
    gem.add_dependency "lawnchair", ">=0.6.8"
    gem.add_dependency "erector", ">=0.8.1"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

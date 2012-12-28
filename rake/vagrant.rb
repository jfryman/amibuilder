require 'vagrant'
require 'fileutils'
require 'yaml'

baseboxes = Dir.glob("definitions/*").map { |f| File.basename(f) if File.directory?(f) }

namespace vagrant do

end

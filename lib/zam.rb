require "rubygems"
require "bundler"
Bundler.require

module Zam
  autoload :Command, 'zam/command'
  autoload :ZamFile, 'zam/zam_file'
  autoload :Connection, 'zam/connection'
end


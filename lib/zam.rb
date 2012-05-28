require "rubygems"
require "bundler"
Bundler.require

module Zam
  autoload :Command, File.join(File.dirname(__FILE__), 'zam/command')
  autoload :ZamFile, File.join(File.dirname(__FILE__), 'zam/zam_file')
  autoload :Connection, File.join(File.dirname(__FILE__), 'zam/connection')
  autoload :Package, File.join(File.dirname(__FILE__), 'zam/package')
end


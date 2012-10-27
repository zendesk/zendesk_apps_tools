require 'pathname'
require 'multi_json'
require 'jshintrb'

module ZendeskAppsTools
  class Package

    attr_reader :root

    def initialize(dir)
      @root = Pathname.new(File.expand_path(dir))
    end

    def files
      @files ||= Dir[ root.join('**/**') ].each_with_object([]) do |f, files|
        relative_file_name = f.sub(/#{root}\/?/, '')
        next unless File.file?(f)
        next if relative_file_name =~ /^tmp\//
        files << AppFile.new(self, relative_file_name)
      end
    end

    def template_files
      @template_files ||= files.select { |f| f =~ /^templates\/.*\.hdbs$/ }
    end

    def translation_files
      @translation_files ||= files.select { |f| f =~ /^translations\// }
    end

    def validate
      Validations::Manifest.call(self) +
        Validations::Source.call(self) +
        Validations::Templates.call(self) +
        Validations::Translations.call(self)
    end

    def name
      manifest["name"] || 'app'
    end

    def author
      {
        :name  => manifest['author']['name'],
        :email => manifest['author']['email']
      }
    end

    def manifest
      @manifest ||= begin
        manifest_file = files.find { |f| f.relative_path == 'manifest.json' }
        begin
          MultiJson.load(manifest_file.read)
        rescue Errno::ENOENT, Errno::EACCES, MultiJson::DecodeError
          {}
        end
      end
    end
  end
end

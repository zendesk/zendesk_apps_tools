require 'pathname'

module ZendeskAppsSupport
  class Package

    attr_reader :root, :files, :template_files, :translation_files

    def initialize(dir)
      @root = Pathname.new(File.expand_path(dir))
      @files = non_tmp_files
      @template_files = files.select { |f| f =~ /^templates\/.*\.hdbs$/ }
      @translation_files = files.select { |f| f =~ /^translations\// }
      freeze
    end

    def validate
      Validations::Manifest.call(self) +
        Validations::Source.call(self) +
        Validations::Templates.call(self) +
        Validations::Translations.call(self)
    end

    private

    def non_tmp_files
      Dir[ root.join('**/**') ].each_with_object([]) do |f, files|
        relative_file_name = f.sub(/#{root}\/?/, '')
        next unless File.file?(f)
        next if relative_file_name =~ /^tmp\//
        files << AppFile.new(self, relative_file_name)
      end
    end
  end
end

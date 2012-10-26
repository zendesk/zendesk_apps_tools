require 'pathname'
require 'multi_json'
require 'jshintrb'

module ZendeskAppsTools
  class Package

    def initialize(dir)
      @dir = Pathname.new(File.expand_path(dir))
    end

    def root
      @dir
    end

    def files
      @files ||= Dir[ @dir.join('**/**') ].each_with_object([]) do |f, files|
        relative_file_name = f.sub(/#{@dir}\/?/, '')
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

    def templates
      @templates ||= begin
        Dir[ @dir.join('templates/*.hdbs') ].inject({}) do |h, file|
          str = File.read(file)
          str.chomp!
          h[File.basename(file, File.extname(file))] = str
          h
        end
      end
    end

    def translations
      @translations ||= begin
        translation_dir = @dir.join('translations')
        default_translations = MultiJson.load(File.read( translation_dir.join("#{default_locale}.json") ))

        Dir[ translation_dir.join('*.json') ].inject({}) do |h, tr|
          locale = File.basename(tr, File.extname(tr))
          locale_translations = if locale == self.default_locale
                                  default_translations
                                else
                                  default_translations.deep_merge(MultiJson.load(File.read(tr)))
                                end

          h[locale] = locale_translations
          h
        end
      end
    end

    def locales
      translations.keys
    end

    def default_locale
      manifest["default_locale"]
    end

    def translation(en)
      translations[en]
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

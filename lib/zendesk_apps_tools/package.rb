require 'pathname'
require 'multi_json'
require 'jshintrb'

class ZendeskAppsTools::Package

  attr_reader :manifest_path, :source_path

  def initialize(dir)
    @dir           = Pathname.new( File.expand_path(dir) )
    @source_path   = @dir.join('app.js')
    @manifest_path = @dir.join('manifest.json')
  end

  def files
    Dir[ @dir.join('**/**') ].select do |f|
      file = f.sub("#{@dir}#{File::SEPARATOR}", '')
      File.file?(f) && file !~ %r[#{@dir.join('tmp')}]
    end
  end

  def relative_file_name(file)
    file.sub %r[^#{@dir}/], ''
  end

  def validate
    ZendeskAppsTools::Validations::Manifest.call(self) +
      ZendeskAppsTools::Validations::Source.call(self)
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

  def assets
    @assets ||= Dir.chdir(@dir) do
      Dir["assets/**/*"]
    end
  end

  def manifest
    @manifest ||= begin
      begin
        MultiJson.load( File.read(manifest_path) )
      rescue Errno::ENOENT, Errno::EACCES, MultiJson::DecodeError
        {}
      end
    end
  end
end

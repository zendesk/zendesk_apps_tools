require 'pathname'

module ZendeskAppsSupport
  class Package

    DEFAULT_SCSS   = File.read(File.expand_path('../default_styles.scss', __FILE__))

    attr_reader :root

    def initialize(dir)
      @root = Pathname.new(File.expand_path(dir))
    end

    def validate
      Validations::Manifest.call(self) +
        Validations::Source.call(self) +
        Validations::Templates.call(self)
    end

    def files
      non_tmp_files
    end

    def template_files
      files.select { |f| f =~ /^templates\/.*\.hdbs$/ }
    end

    def translation_files
      files.select { |f| f =~ /^translations\// }
    end

    def compiled_templates(app_id, url_prefix)
      css_file = File.join(root, "app.css")
      customer_css = File.exist?(css_file) ? File.read(css_file) : ""
      compiled_css = ZendeskAppsSupport::StylesheetCompiler.new(DEFAULT_SCSS + customer_css, app_id, url_prefix).compile

      templates = begin
        Dir["#{root.to_path}/app/templates/*.hdbs"].inject({}) do |h, file|
          str = File.read(file)
          str.chomp!
          h[File.basename(file, File.extname(file))] = str
          h
        end
      end

      templates.tap do |templates|
        templates['layout'] = "<style>\n#{compiled_css}</style>\n#{templates['layout']}"
      end
    end

    private

    def non_tmp_files
      Dir[ root.join('**/**') ].each_with_object([]) do |f, files|
        next unless File.file?(f)
        relative_file_name = f.sub(/#{root}\/?/, '')
        next if relative_file_name =~ /^tmp\//
        files << AppFile.new(self, relative_file_name)
      end
    end
  end
end

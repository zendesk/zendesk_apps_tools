module ZendeskAppsTools

  class AppFile

    attr_reader :relative_path

    def initialize(package, relative_path)
      @relative_path = relative_path
      @full_path = package.root.join(relative_path)
    end

    def exists?
      File.exists? @full_path
    end

    def read
      File.read @full_path
    end

    def =~(regex)
      @relative_path =~ regex
    end

    alias_method :to_s, :relative_path

  end

end
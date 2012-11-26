require "digest/md5"

module ZendeskAppsSupport

    class AppHash

    def initialize(package, tmp_dir)
      @package = package
      @tmp_dir = tmp_dir
    end

    def stale?
      hashfile_path = @tmp_dir.join('.zendesk_app_hash')
      old_hexdigest = read_hexdigest(hashfile_path)
      new_hexdigest = calculate_hexdigest(@package)

      if old_hexdigest != new_hexdigest
        write(new_hexdigest, hashfile_path)
        return true
      end

      false
    end

    private

    def read_hexdigest(path)
      File.exist?(path) ? File.read(path) : nil
    end

    def calculate_hexdigest(package)
      package.files.inject(Digest::MD5.new) do |digest, file|
        digest << file.read
      end.hexdigest
    end

    def write(contents, path)
      File.open(path, 'w') { |f| f << contents }
    end

  end

end

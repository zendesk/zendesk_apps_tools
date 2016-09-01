module ZendeskAppsTools
  module Directory
    def app_dir
      @app_dir ||= Pathname.new(destination_root)
    end

    def tmp_dir
      @tmp_dir ||= Pathname.new(File.join(app_dir, 'tmp')).tap do |dir|
        FileUtils.mkdir_p(dir)
      end
    end

    def prompt_new_app_dir
      prompt = "Enter a directory name to save the new app (will create the dir if it does not exist):\n"
      opts = { valid_regex: /^(.|\w|\/|\\)*$/, default: './' }
      while @app_dir = get_value_from_stdin(prompt, opts)
        if !File.exist?(@app_dir)
          break
        elsif !File.directory?(@app_dir)
          say_error 'Invalid dir, try again:'
        else
          break
        end
      end
    end
  end
end

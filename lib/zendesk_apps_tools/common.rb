require 'faraday'

module ZendeskAppsTools
  module Common
    def api_request(url, request = Faraday.new)
      request.get(url)
    end

    def say_error_and_exit(msg)
      say msg, :red
      exit 1
    end

    def get_value_from_stdin(prompt, opts = {})
      options = {
        valid_regex: opts[:allow_empty] ? /^.*$/ : /\S+/,
        error_msg: 'Invalid, try again:',
        allow_empty: false
      }.merge(opts)

      while input = ask(prompt)
        return '' if input.empty? && options[:allow_empty]
        if input =~ options[:valid_regex]
          break
        else
          say(options[:error_msg], :red)
        end
      end

      input
    end

    def get_password_from_stdin(prompt)
      print "#{prompt} "
      password = STDIN.noecho(&:gets).chomp
      puts
      password
    end
  end
end

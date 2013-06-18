require 'faraday'

module ZendeskAppsTools
  module Common
    def api_call(url, user, password, request = Faraday.new)
      request.basic_auth(user, password)
      request.get(url).body
    end

    def get_value_from_stdin(prompt, valid_regex, error_msg)
      while input = ask(prompt)
        unless input =~ valid_regex
          say(error_msg, :red)
        else
          break
        end
      end

      return input
    end
  end
end

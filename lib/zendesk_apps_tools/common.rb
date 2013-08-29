require 'faraday'

module ZendeskAppsTools
  module Common
    def api_request(url, user, password, request = Faraday.new)
      request.basic_auth(user, password)
      request.get(url)
    end

    def get_value_from_stdin(prompt, opts = {})
      options = {
        :valid_regex => opts[:allow_empty] ? /^\w*$/ : /\S+/,
        :error_msg => 'Invalid, try again:',
        :allow_empty => false
      }.merge(opts)

      while input = ask(prompt)
        return "" if input.empty? && options[:allow_empty]
        unless input =~ options[:valid_regex]
          say(options[:error_msg], :red)
        else
          break
        end
      end

      return input
    end
  end
end

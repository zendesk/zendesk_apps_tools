# frozen_string_literal: true
module ZendeskAppsTools
  module Common
    module ClassMethods
      def shared_options(except: [])
        unless except.include? :path
          method_option :path,
                        type: :string,
                        default: './',
                        aliases: ['-p']
        end
        unless except.include? :clean
          method_option :clean,
                        type: :boolean,
                        default: false
        end
        unless except.include? :unattended
          method_option :unattended,
                        type: :boolean,
                        default: false,
                        desc: 'Experimental: Never prompt for input, expecting all input from the original invocation. Many '\
                              'commands invoked with this option will just crash.'
        end
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    def say_error_and_exit(msg)
      say_error msg
      exit 1
    end

    def say_error(msg)
      say msg, :red
    end

    def get_value_from_stdin(prompt, opts = {})
      error_or_default_if_unattended(prompt, opts) do
        options = {
          valid_regex: opts[:allow_empty] ? /^.*$/ : /\S+/,
          error_msg: 'Invalid, try again:',
          allow_empty: false
        }.merge(opts)

        thor_options = { default: options[:default] }

        while input = ask(prompt, thor_options)
          return '' if options[:allow_empty] && input.empty?
          break if input.to_s =~ options[:valid_regex]
          say_error options[:error_msg]
        end

        input
      end
    end

    def get_password_from_stdin(prompt)
      error_or_default_if_unattended(prompt) do
        password = ask(prompt, echo: false)
        say ''
        password
      end
    end

    def json_or_die(value)
      require 'json'
      JSON.parse(value)
    rescue JSON::ParserError
      say_error_and_exit "\"#{value}\" is an invalid JSON"
    end

    private

    def error_or_default_if_unattended(prompt, opts = {})
      if options[:unattended]
        return opts[:default] if opts.key? :default
        say_error 'Would have prompted for a value interactively, but zat is not listening to keyboard input.'
        say_error_and_exit prompt
      else
        yield
      end
    end
  end
end

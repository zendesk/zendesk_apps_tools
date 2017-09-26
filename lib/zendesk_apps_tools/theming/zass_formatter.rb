# frozen_string_literal: true

require 'sass'
require 'English'

module ZendeskAppsTools
  module Theming
    class ZassFormatter
      COMMAND = /(?<command>lighten|darken)/i
      COLOR = /(?<color>#\h{6}|#\h{3})/
      PERCENTAGE = /(?<percentage>\d{1,3})%/
      COLOR_COMMAND_REGEXP = /#{COMMAND}\s*\(\s*#{COLOR}\s*,\s*#{PERCENTAGE}\s*\)/

      def self.format(raw, variables)
        joined_keys = "(#{variables.keys.join('|')})"

        keys_regex = /(\$#{joined_keys}\b)|(#\{\$#{joined_keys}\})/

        substitution_hash = variables.each_with_object({}) do |(k, v), hash|
          hash["$#{k}"] = v.to_s
          hash["\#{$#{k}}"] = v.to_s
        end

        body = raw.to_s.dup
        body.gsub!(keys_regex, substitution_hash)

        # Color manipulation
        body.gsub!(COLOR_COMMAND_REGEXP) do |whole_match|
          if $LAST_MATCH_INFO[:command] == 'lighten'
            color_adjust($LAST_MATCH_INFO[:color], $LAST_MATCH_INFO[:percentage].to_i, :+) || whole_match
          else
            color_adjust($LAST_MATCH_INFO[:color], $LAST_MATCH_INFO[:percentage].to_i, :-) || whole_match
          end
        end

        body
      end

      def self.color_adjust(rgb, percentage, op)
        color = Sass::Script::Value::Color.from_hex(rgb)

        # Copied from:
        # https://github.com/sass/sass/blob/3.4.21/lib/sass/script/functions.rb#L2671
        new_color = color.with(lightness: color.lightness.public_send(op, percentage))

        # We set the Sass Output to compressed
        new_color.options = { style: :compressed }
        new_color.to_sass
      rescue ArgumentError
        nil
      end
    end
  end
end

module ZendeskAppsTools
  module ValidateHelper

    DEFAULT_ZENDESK_URL = 'http://support.zendesk.com'

    def test_framework_version
      prompt = "Enter a zendesk URL that you'd like to install the app (for example: 'http://abc.zendesk.com', default to '#{DEFAULT_ZENDESK_URL}'):\n"
      zendesk  = get_value_from_stdin(prompt, :valid_regex => /^http:\/\/\w+\.\w+|^$/, :error_msg => 'Invalid url, try again:')
      zendesk  = DEFAULT_ZENDESK_URL if zendesk.empty?
      url      = URI.parse(zendesk)
      response = Net::HTTP.start(url.host, url.port) { |http| http.get('/api/v2/apps/framework_versions.json') }
      version  = JSON.parse(response.body, :symbolize_names => true)

      if ZendeskAppsSupport::AppVersion::CURRENT != version[:current]
        puts 'This tool is using an out of date Zendesk App Framework. Please upgrade!'
        exit 1
      end
    end

  end
end

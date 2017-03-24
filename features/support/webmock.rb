# frozen_string_literal: true
unless defined?(Cucumber)

  require 'webmock'

  WebMock::API.stub_request(:post, 'https://app-account.zendesk.com/api/v2/apps/uploads.json').to_return(body: JSON.dump(id: '123'))
  WebMock::API.stub_request(:post, 'https://app-account.zendesk.com/api/v2/apps.json').with(body: JSON.dump(name: 'John Test App', upload_id: '123')).to_return(body: JSON.dump(job_id: '987'))
  WebMock::API.stub_request(:get, 'https://app-account.zendesk.com/api/v2/apps/job_statuses/987').to_return(body: JSON.dump(status: 'working')).then.to_return(body: JSON.dump(status: 'completed', app_id: '55'))

  WebMock.enable!
  WebMock.disable_net_connect!
end

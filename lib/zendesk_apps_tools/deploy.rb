require 'faraday'
require 'zendesk_apps_tools/common'
require 'zendesk_apps_tools/api_connection'

module ZendeskAppsTools
  module Deploy
    include ZendeskAppsTools::Common
    include ZendeskAppsTools::APIConnection

    def deploy_app(connection_method, url, body)
      body[:upload_id] = upload(options[:path]).to_s
      sleep 2 # Because the DB needs time to replicate

      response = cached_connection.send(connection_method) do |req|
        req.url url
        req.headers[:content_type] = 'application/json'
        req.body = JSON.generate body
      end

      check_status response

    rescue Faraday::Error::ClientError, JSON::ParserError => e
      say_error_and_exit e.message
    end

    def app_exists?(app_id)
      url = "/api/v2/apps/#{app_id}.json"
      response = cached_connection.send(:get) do |req|
        req.url url
      end

      %w(200 201 202).include? response.status.to_s
    end

    def install_app(poll_job, product_name, installation)
      response = cached_connection.post do |req|
        req.url "api/#{product_name}/apps/installations.json"
        req.headers[:content_type] = 'application/json'
        req.body = JSON.generate(installation)
      end
      check_status(response, poll_job)
    end

    def upload(path)
      zipfile_path = options[:zipfile]

      if zipfile_path
        package_path = zipfile_path
      else
        package
        package_path = Dir[File.join path, '/tmp/*.zip'].sort.last
      end

      payload = {
        uploaded_data: Faraday::UploadIO.new(package_path, 'application/zip')
      }

      response = cached_connection(:multipart).post('/api/v2/apps/uploads.json', payload)
      json_or_die(response.body)['id']

    rescue Faraday::Error::ClientError => e
      say_error_and_exit e.message
    end

    def find_app_id
      say_status 'Update', 'app ID is missing, searching...'
      app_name = get_value_from_stdin('Enter the name of the app:')

      all_apps_json = cached_connection.get('/api/apps.json').body

      app =
        unless all_apps_json.empty?
          json_or_die(all_apps_json)['apps'].find { |app| app['name'] == app_name }
        end

      unless app
        say_error_and_exit(
          "App not found. " \
          "Please verify that your credentials, subdomain, and app name are correct."
        )
      end

      cache.save 'app_id' => app['id']
      app['id']

    rescue Faraday::Error::ClientError => e
      say_error_and_exit e.message
    end

    def check_status(response, poll_job = true)
      job_response = json_or_die(response.body)

      say_error_and_exit job_response['error'] if job_response['error']

      if poll_job
        job_id = job_response['job_id'] || job_response['pending_job_id']
        check_job job_id
      end
    end

    def check_job(job_id)
      loop do
        response = cached_connection.get("/api/v2/apps/job_statuses/#{job_id}")
        info     = json_or_die(response.body)
        status   = info['status']

        if %w(completed failed).include? status
          case status
          when 'completed'
            app_id = info['app_id']
            cache.save 'app_id' => app_id if app_id
            say_status @command, 'OK'
          when 'failed'
            say_status @command, info['message'], :red
            exit 1
          end
          break
        end

        say_status 'Status', status
        sleep 3
      end
    rescue Faraday::Error::ClientError => e
      say_error_and_exit e.message
    end

    private

    def cached_connection(encoding = :url_encoded)
      @connection ||= {}
      @connection[encoding] ||= get_connection(encoding)
    end
  end
end

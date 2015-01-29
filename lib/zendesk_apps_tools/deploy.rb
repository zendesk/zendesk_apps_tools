module ZendeskAppsTools
  module Deploy
    def deploy_app(connection_method, url, body)
      body[:upload_id] = upload(options[:path]).to_s

      connection = get_connection

      response = connection.send(connection_method) do |req|
        req.url url
        req.headers[:content_type] = 'application/json'

        req.body = JSON.generate body
      end

      check_status response

    rescue Faraday::Error::ClientError => e
      say_error_and_exit e.message
    end

    def upload(path)
      connection = get_connection :multipart
      zipfile_path  = options[:zipfile]

      if zipfile_path
        package_path = zipfile_path
      else
        package
        package_path = Dir[File.join path, '/tmp/*.zip'].sort.last
      end

      payload = { uploaded_data: Faraday::UploadIO.new(package_path, 'application/zip') }

      response = connection.post('/api/v2/apps/uploads.json', payload)
      JSON.parse(response.body)['id']

    rescue Faraday::Error::ClientError => e
      say_error_and_exit e.message
    rescue JSON::ParserError => e
      say_error_and_exit e.message
    end

    def find_app_id
      say_status 'Update', 'app ID is missing, searching...'
      name = get_value_from_stdin('Enter the name of the app:')

      connection = get_connection

      all_apps = connection.get('/api/v2/apps.json').body

      app_id = JSON.parse(all_apps)['apps'].find { |app| app['name'] == name }['id']

      save_cache 'app_id' => app_id
      app_id
    rescue Faraday::Error::ClientError => e
      say_error_and_exit e.message
    end

    def check_status(response)
      job = response.body
      job_response = JSON.parse(job)
      say_error_and_exit job_response['error'] if job_response['error']

      job_id = job_response['job_id']
      check_job job_id
    end

    def check_job(job_id)
      connection = get_connection

      loop do
        response = connection.get("/api/v2/apps/job_statuses/#{job_id}")
        info     = JSON.parse(response.body)
        status   = info['status']
        message  = info['message']
        app_id   = info['app_id']

        if %w(completed failed).include? status
          case status
          when 'completed'
            save_cache 'app_id' => app_id
            say_status @command, 'OK'
          when 'failed'
            say_status @command, message
          end
          break
        end

        say_status 'Status', status
        sleep 3
      end
    rescue Faraday::Error::ClientError => e
      say_error_and_exit e.message
    end
  end
end

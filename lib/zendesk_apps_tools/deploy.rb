module ZendeskAppsTools
  module Deploy
    def deploy_app(connection_method, url, body)
      body[:upload_id] = upload(options[:path]).to_s
      sleep 2 # Because the DB needs time to replicate
      connection = get_connection

      response = connection.send(connection_method) do |req|
        req.url url
        req.headers[:content_type] = 'application/json'
        req.body = JSON.generate body
      end

      check_status response

    rescue Faraday::Error::ClientError, JSON::ParserError => e
      say_error_and_exit e.message
    end

    def install_app(poll_job, product_name, installation)
      connection = get_connection
      response = connection.post do |req|
        req.url "api/#{product_name}/apps/installations.json"
        req.headers[:content_type] = 'application/json'
        req.body = JSON.generate(installation)
      end
      check_status(response, poll_job)
    end

    def upload(path)
      connection = get_connection :multipart
      zipfile_path = options[:zipfile]

      if zipfile_path
        package_path = zipfile_path
      else
        package
        package_path = Dir[File.join path, '/tmp/*.zip'].sort.last
      end

      payload = { uploaded_data: Faraday::UploadIO.new(package_path, 'application/zip') }

      response = connection.post('/api/v2/apps/uploads.json', payload)
      json_or_die(response.body)['id']

    rescue Faraday::Error::ClientError => e
      say_error_and_exit e.message
    end

    def find_app_id
      say_status 'Update', 'app ID is missing, searching...'
      name = get_value_from_stdin('Enter the name of the app:')

      connection = get_connection

      all_apps = connection.get('/api/apps.json').body

      app_json = all_apps.empty? ? nil : json_or_die(all_apps)['apps'].find { |app| app['name'] == name }
      say_error_and_exit('The app was not found. Please verify your credentials, subdomain, and app name are correct.') unless app_json
      app_id = app_json['id']

      cache.save 'app_id' => app_id
      app_id
    rescue Faraday::Error::ClientError => e
      say_error_and_exit e.message
    end

    def check_status(response, poll_job = true)
      job = response.body
      job_response = json_or_die(job)
      say_error_and_exit job_response['error'] if job_response['error']

      if poll_job
        job_id = job_response['job_id'] || job_response['pending_job_id']
        check_job job_id
      end
    end

    def check_job(job_id)
      connection = get_connection

      loop do
        response = connection.get("/api/v2/apps/job_statuses/#{job_id}")
        info     = json_or_die(response.body)
        status   = info['status']
        message  = info['message']
        app_id   = info['app_id']

        if %w(completed failed).include? status
          case status
          when 'completed'
            cache.save 'app_id' => app_id if app_id
            say_status @command, 'OK'
          when 'failed'
            say_status @command, message, :red
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
  end
end

def prepare_env_hash_for(cmd)
  if cmd.start_with? 'zat create'
    path = File.expand_path('../../support/webmock', __FILE__)
    { 'RUBYOPT' => "-r #{path}" }
  else
    {}
  end
end

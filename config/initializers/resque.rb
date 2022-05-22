config_file = './config/resque.yml'
rails_env = ENV['RAILS_ENV'] || 'development'
resque_config = YAML::load(ERB.new(IO.read(config_file)).result)
Resque.redis = resque_config[rails_env]

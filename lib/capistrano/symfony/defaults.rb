# Symfony environment on local
set :symfony_env_local, "dev"

# Symfony environment
set :symfony_env_prod,  "prod"

set :remote_tmp_dir,    "/tmp"

# Symfony application path
set :app_path,              "app"

# Symfony web path
set :web_path,              "web"

# Symfony log path
set :log_path,              fetch(:app_path) + "/logs"

# Symfony cache path
set :cache_path,            fetch(:app_path) + "/cache"

# Symfony config file path
set :app_config_path,       fetch(:app_path) + "/config"

# Symfony config file (parameters.(ini|yml|etc...)
set :app_config_file,       "parameters.yml"
set :app_config_file_template,       "parameters.yml.dist"
set :use_config_file_template, false

set :app_config_file_path,   fetch(:app_config_path) + "/" + fetch(:app_config_file)
set :app_config_template_path,   fetch(:app_config_path) + "/" + fetch(:app_config_file_template)

# Controllers to clear
set :controllers_to_clear, ["app_*.php"]

# Files that need to remain the same between deploys
set :linked_files,          []

# Dirs that need to remain the same between deploys (shared dirs)
set :linked_dirs,           [fetch(:log_path), fetch(:web_path) + "/uploads"]

# Dirs that need to be writable by the HTTP Server (i.e. cache, log dirs)
set :file_permissions_paths,         [fetch(:log_path), fetch(:cache_path)]

# Name used by the Web Server (i.e. www-data for Apache)
set :webserver_user,        "www-data"

# Method used to set permissions (:chmod, :acl, or :chown)
set :permission_method,     false

# Execute set permissions
set :use_set_permissions,   false

set :composer_install_flags, "--no-dev --no-scripts --verbose --prefer-dist --optimize-autoloader --no-progress"

set :symfony_console_path, fetch(:app_path) + "/console"
set :symfony_console_flags, "--no-debug"

# Use AsseticBundle
set :dump_assetic_assets,   false

# Assets install
set :assets_install,        false
set :assets_symlinks,       false
set :assets_relative,       false
set :assets_install_path,   fetch(:web_path)

# Whether to update `assets_version` in `config.yml`
set :update_assets_version, false

set :normalize_asset_timestamps, true
# Asset folders (that need to be timestamped)
set :asset_children,        [fetch(:web_path) + "/css", fetch(:web_path) + "/images", fetch(:web_path) + "/js"]

fetch(:default_env).merge!(symfony_env: fetch(:symfony_env_prod))

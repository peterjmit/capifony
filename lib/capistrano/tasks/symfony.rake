module Capistrano
  class FileNotFound < StandardError
  end
end

namespace :deploy do
  desc "Create the cache directory"
  task :create_cache_dir do
    on roles :app do
      within release_path do
        if test "[ -d #{symfony_cache_path} ]"
          execute :rm, "-rf", symfony_cache_path
        end
        execute :mkdir, "-pv", fetch(:cache_path)
      end
    end
  end

  desc "Clear non production controllers"
  task :clear_controllers do
    next unless any? :controllers_to_clear
    on roles :app do
      within symfony_web_path do
        execute :rm, "-f", *fetch(:controllers_to_clear)
      end
    end
  end

  task :build_bootstrap do
    on roles :app do
      within release_path do
        execute "./vendor/sensio/distribution-bundle/Sensio/Bundle/DistributionBundle/Resources/bin/build_bootstrap.php"
      end
    end
  end

  namespace :linked_parameters do
    desc "Check if parameters file is linked in shared directory"
    task :check do
      config_file_path = fetch(:app_config_file_path)
      next unless fetch(:linked_files).include?(config_file_path)
      on roles :app do
        # if the file is already in the shared path, we can skip
        if test "[ -f #{shared_path.join(config_file_path)} ]"
          info "Linked parameters file found"
        else
          warn "Linked parameters file is not present"
          # hack, otherwise capistrano errors out for linked files
          # that do not exist
          within shared_path do
            execute :touch, config_file_path
            info "Created empty parameters file: #{shared_path.join(config_file_path)}"
          end
        end
      end
    end

    desc "If using linked parameters and the linked parameters file is empty, copy from the template"
    task :copy_template do
      next unless fetch :use_config_file_template
      config_file_path = fetch(:app_config_file_path)
      next unless fetch(:linked_files).include?(config_file_path)
      on roles :app do
        shared_config_path = shared_path.join(config_file_path)
        template_path = release_path.join(fetch(:app_config_template_path))

        unless test "[ -f #{template_path} ]"
          msg = "Could not find config file template #{template_path}"
          warn msg
          fail Capistrano::FileNotFound, msg
        end

        # only copy template if file is not empty
        unless test "[ -s #{shared_config_path} ]"
          info "Parameters file is empty! Copying parameters file from template"
          execute :cp, template_path, shared_config_path
        end
      end
    end
  end

  # Capistrano will fail without this empty task
  desc "Restart application"
  task :restart do
  end

  task :updating do
    invoke "deploy:create_cache_dir"
    invoke "deploy:set_permissions:acl"
    invoke "deploy:linked_parameters:copy_template"
  end

  task :updated do
    invoke "deploy:build_bootstrap"
    invoke "symfony:cache:warmup"
  end

  before "deploy:starting", "deploy:linked_parameters:check"
  after "deploy:updated", "deploy:clear_controllers"
  after "deploy:updated", "deploy:assets:install"
end

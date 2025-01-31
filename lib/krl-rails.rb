require 'krl-rails/version'
require 'rails'
require 'krl'
require 'krl-rails/register_engine'

module KRL
  module Rails
    class Railtie < ::Rails::Railtie
      config.app_generators.template_engine :krl

      initializer 'krl_rails.configure_template_digestor' do |app|
        KRL::Rails::RegisterEngine.register_engine(app, config)

        ActiveSupport.on_load(:action_view) do
          ActiveSupport.on_load(:after_initialize) do
            begin
              if defined?(CacheDigests::DependencyTracker)
                # 'cache_digests' gem being used (overrides Rails 4 implementation)
                CacheDigests::DependencyTracker.register_tracker :krl, CacheDigests::DependencyTracker::ERBTracker

                if ::Rails.env.development?
                  # recalculate cache digest keys for each request
                  CacheDigests::TemplateDigestor.cache = ActiveSupport::Cache::NullStore.new
                end
              elsif ::Rails.version.to_s >= '4.0'
                # will only apply if Rails 4, which includes 'action_view/dependency_tracker'
                require 'action_view/dependency_tracker'
                ActionView::DependencyTracker.register_tracker :krl, ActionView::DependencyTracker::ERBTracker
              end
            rescue
              # likely this version of Rails doesn't support dependency tracking
            end
          end
        end
      end
    end
  end
end

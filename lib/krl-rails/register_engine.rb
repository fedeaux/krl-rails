module Krl
  module Rails
    module RegisterEngine
      class Transformer
        def self.call(input)
          Krl::Template.new(input[:name]) { input[:data] }.render(nil)
        end
      end

      class << self
        def register_engine(app, config)
          if ::Rails::VERSION::MAJOR == 3
            _register_engine3(app)
          else
            _register_engine(config)
          end
        end

        private

        def _register_engine3(app)
          return unless app.assets
          return unless app.assets.respond_to?(:register_engine)

          app.assets.register_engine('.krl', Krl::Template)
        end

        def _register_engine(config)
          return unless config.respond_to?(:assets)

          config.assets.configure do |env|
            if env.respond_to?(:register_transformer) && Sprockets::VERSION.to_i > 3
              env.register_mime_type 'text/krl', extensions: ['.krl', '.krl.html']#, charset: :html
              env.register_transformer 'text/krl', 'text/html', RegisterEngine::Transformer
            elsif env.respond_to?(:register_engine)
              args = ['.krl', Krl::Template]
              args << { silence_deprecation: true } if Sprockets::VERSION.start_with?('3')
              env.register_engine(*args)
            end
          end
        end
      end
    end
  end
end

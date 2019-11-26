module KRL
  module Rails
    module RegisterEngine
      class Transformer
        def self.call(input)
          KRL::Template.new(input).render
        end
      end

      class << self
        def register_engine(app, config)
          return unless config.respond_to?(:assets)

          config.assets.configure do |env|
            if env.respond_to?(:register_transformer) && Sprockets::VERSION.to_i > 3
              env.register_mime_type 'text/html', extensions: ['.krl']#, charset: :html
              # env.register_transformer 'text/krl', 'text/html', RegisterEngine::Transformer
            elsif env.respond_to?(:register_engine)
              args = ['.krl', KRL::Template]
              args << { silence_deprecation: true } if Sprockets::VERSION.start_with?('3')
              env.register_engine(*args)
            end

            ActionView::Template.register_template_handler(:krl, Transformer)
          end
        end
      end
    end
  end
end

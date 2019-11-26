module KRL
  class Template
    def initialize(input)
      @input = input
      @yaml, @slim = @input.source.split('--KRL--')
    end

    def render
      yaml = YAML.load(@yaml)
      html = Slim::Template.new { @slim }.render(nil, yaml['fields'])

      [
        '@output_buffer = output_buffer || ActiveSupport::SafeBuffer.new',
        "@output_buffer.safe_concat('#{html}'.freeze)",
        '@output_buffer'
      ].join("\n")
    end
  end
end

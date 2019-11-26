module KRL
  class Template
    def initialize(input)
      @contents = Nokogiri::HTML.fragment input.source
      parse
    end

    def parse
      @yaml = @contents.children.select { |child| child.name == 'fields' }.join
      @slim = @contents.children.select { |child| child.name == 'template' }.join

      @parsed_yaml = @yaml.present? && YAML.load(@yaml) || { fields: {} }
      @parsed_html = Slim::Template.new { @slim }.render(nil, @parsed_yaml['fields'])
    end

    def render
      [
        '@output_buffer = output_buffer || ActiveSupport::SafeBuffer.new',
        "@output_buffer.safe_concat('#{@parsed_html}'.freeze)",
        '@output_buffer'
      ].join("\n")
    end
  end
end

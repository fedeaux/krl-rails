module KRL
  class Template
    attr_reader :fields

    def initialize(input)
      @contents = Nokogiri::HTML.fragment input.source
      parse
    end

    def parse
      @raw_yaml = @contents.children.select { |child| child.name == 'fields' }.join
      @raw_slim = @contents.children.select { |child| child.name == 'template' }.join

      @fields = OpenStruct.new(@raw_yaml.present? && YAML.load(@raw_yaml)['fields'] || {})
      @html = Slim::Template.new { @raw_slim }.render(nil, @fields.to_h)
    end

    def render
      [
        '@output_buffer = output_buffer || ActiveSupport::SafeBuffer.new',
        "@output_buffer.safe_concat('#{@html}'.freeze)",
        '@output_buffer'
      ].join("\n")
    end
  end
end

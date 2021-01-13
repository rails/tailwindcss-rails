require "tailwindcss/purger"

class Tailwindcss::Compressor
  def self.instance
    @instance ||= new
  end

  def self.call(input)
    instance.call(input)
  end

  def initialize(options = {})
    @options = { paths_with_css_class_names: [ "app/views/**/*.*", "app/helpers/**/*.rb" ] }.merge(options).freeze
  end

  def call(input)
    { data: Tailwindcss::Purger.new(**@options).purge(input[:data]) }
  end
end

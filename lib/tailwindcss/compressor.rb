require "tailwindcss/purger"

class Tailwindcss::Compressor
  def self.instance
    @instance ||= new
  end

  def self.call(input)
    instance.call(input)
  end

  def initialize(options = {})
    @options = { files_with_class_names: Rails.root.glob("app/views/**/*.*") + Rails.root.glob("app/helpers/**/*.rb") }.merge(options).freeze
  end

  def call(input)
    { data: Tailwindcss::Purger.purge(input[:data], keeping_class_names_from_files: @options[:files_with_class_names]) }
  end
end

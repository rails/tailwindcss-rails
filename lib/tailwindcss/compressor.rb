require "tailwindcss/purger"

class Tailwindcss::Compressor
  def self.instance
    @instance ||= new
  end

  def self.call(input)
    instance.call(input)
  end

  def initialize(options = {})
    @options = {
      files_with_class_names: Tailwindcss::Purger.default_files_with_class_names,
      only_purge: %w[ tailwind ]
    }.merge(options).freeze
  end

  def call(input)
    if input[:name].in?(@options[:only_purge])
      { data: Tailwindcss::Purger.purge(input[:data], keeping_class_names_from_files: @options[:files_with_class_names]) }
    else
      input[:data]
    end
  end
end

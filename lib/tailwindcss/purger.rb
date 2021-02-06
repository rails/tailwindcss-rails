class Tailwindcss::Purger
  CLASS_NAME_PATTERN       = /([:A-Za-z0-9_-]+[\.\\\/:A-Za-z0-9_-]*)/
  OPENING_SELECTOR_PATTERN = /\..*\{/
  CLOSING_SELECTOR_PATTERN = /\s*\}/
  NEWLINE = "\n"

  attr_reader :keep_these_class_names

  class << self
    def purge(input, keeping_class_names_from_files:)
      new(extract_class_names_from(keeping_class_names_from_files)).purge(input)
    end

    def extract_class_names(string)
      string.scan(CLASS_NAME_PATTERN).flatten.uniq.sort
    end

    def extract_class_names_from(files)
      Array(files).flat_map { |file| extract_class_names(file.read) }.uniq.sort
    end
  end

  def initialize(keep_these_class_names)
    @keep_these_class_names = keep_these_class_names
  end

  def purge(input)
    inside_kept_selector = inside_ignored_selector = false
    output = []

    input.split(NEWLINE).each do |line|
      case
      when inside_kept_selector
        output << line
        inside_kept_selector = false if line =~ CLOSING_SELECTOR_PATTERN
      when inside_ignored_selector
        inside_ignored_selector = false if line =~ CLOSING_SELECTOR_PATTERN
      when line =~ OPENING_SELECTOR_PATTERN
        if keep_these_class_names.include? class_name_in(line)
          output << line
          inside_kept_selector = true
        else
          inside_ignored_selector = true
        end
      else
        output << line
      end
    end

    separated_without_empty_lines(output)
  end

  private
    def class_name_in(line)
      CLASS_NAME_PATTERN.match(line)[1]
        .remove("\\")
        .remove(/:(focus|hover)(-within)?/)
        .remove("::placeholder").remove("::-moz-placeholder").remove(":-ms-input-placeholder")
    end

    def separated_without_empty_lines(output)
      output.reject { |line| line.strip.empty? }.join(NEWLINE)
    end
end

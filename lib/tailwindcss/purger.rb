class Tailwindcss::Purger
  CLASS_NAME_PATTERN       = /([:A-Za-z0-9_-]+)/
  OPENING_SELECTOR_PATTERN = /\..*\{/
  CLOSING_SELECTOR_PATTERN = /\s*\}/

  attr_reader :paths_with_css_class_names

  def initialize(paths_with_css_class_names:)
    @paths_with_css_class_names = paths_with_css_class_names
  end

  def purge(input)
    inside_valid_selector = inside_invalid_selector = false
    output = []

    input.split("\n").each do |line|
      case
      when inside_valid_selector
        output << line
        inside_valid_selector = false if line =~ CLOSING_SELECTOR_PATTERN
      when inside_invalid_selector
        inside_invalid_selector = false if line =~ CLOSING_SELECTOR_PATTERN
      else
        if line =~ OPENING_SELECTOR_PATTERN
          line.remove("\u001A") =~ CLASS_NAME_PATTERN

          if potential_css_class_names.include?($1)
            output << line
            inside_valid_selector = true
          else
            inside_invalid_selector = true
          end
        else
          output << line
        end
      end
    end

    output.reject { |line| line == "\n" }.join
  end

  def potential_css_class_names
    @potential_css_class_names ||= find_potential_css_class_names_in(paths_with_css_class_names)
  end

  private
    def find_potential_css_class_names_in(path_patterns)
      files_in(path_patterns).flat_map { |file| extract_potential_css_class_names_from(file) }.flatten.uniq.sort
    end

    def files_in(path_patterns)
      path_patterns.flat_map { |path_pattern| Rails.root.glob(path_pattern) }
    end

    def extract_potential_css_class_names_from(file)
      file.read.scan(CLASS_NAME_PATTERN)
    end
end

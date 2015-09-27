require 'which_works'

module RSpec::PageRegression

  RSpec::Matchers.define :match_expectation do |expectation_path|

    match do |page|
      @responsive_filepaths = FilePaths.responsive_file_paths(RSpec.current_example, expectation_path)
      @filepaths = @responsive_filepaths.first
      Renderer.render_responsive(page, @responsive_filepaths)
      @comparisons = @responsive_filepaths.map{ |filepaths| ImageComparison.new(filepaths) }
      @comparisons.each { |comparison| return false unless comparison.result == :match }
    end

    failure_message do |page|
      msg = ''
      @comparisons.each do |comparison|
        next if comparison.result == :match
        msg +=  case comparison.result
                  when :missing_expected then "\nMissing expectation image #{comparison.filepaths.expected_image}"
                  when :missing_test then "Missing test image #{comparison.filepaths.test_image}"
                  when :size_mismatch then "Test image size #{comparison.test_size.join('x')} does not match expectation #{comparison.expected_size.join('x')}"
                  when :difference then 'Test image does not match expected image'
                end

        msg += "\n    $ #{viewer} #{comparison.filepaths.all.select(&:exist?).join(' ')}"

        case comparison.result
        when :missing_expected
          msg += "\nCreate it via:\n    $ mkdir -p #{comparison.filepaths.expected_image.dirname} && cp #{comparison.filepaths.test_image} #{comparison.filepaths.expected_image}\n\n"
        end
      end

      msg
    end

    failure_message_when_negated do |page|
      'Test image expected to not match expectation image'
    end

    def viewer
      File.basename(Which.which('open', 'feh', 'display', array: true).first || 'viewer')
    end
  end
end

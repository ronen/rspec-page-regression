require 'active_support/core_ext/string/inflections'

module RSpec::PageRegression
  class FilePaths
    attr_reader :expected_image
    attr_reader :test_image
    attr_reader :difference_image
    attr_reader :page_size

    def initialize(example, page_size, expected_path = nil)
      expected_path = Pathname.new(expected_path) if expected_path

      descriptions = description_ancestry(example.metadata[:example_group])
      descriptions.push example.description unless example.description.parameterize('_') =~ %r{
        ^
        (then_+)?
        ( (expect_+) (page_+) (to_+) (not_+)? | (page_+) (should_+)? )
        match_expectation
        (_#{Regexp.escape(expected_path.to_s)})?
          $
      }xi
      canonical_path = descriptions.map{|s| s.parameterize('_')}.inject(Pathname.new(""), &:+)

      app_root = Pathname.new(example.metadata[:file_path]).realpath.each_filename.take_while{|c| c != "spec"}.inject(Pathname.new("/"), &:+)
      expected_root = app_root + "spec" + "expectation"
      test_root = app_root + "tmp" + "spec" + "expectation"
      cwd = Pathname.getwd

      @page_size = page_size
      @expected_image = expected_path || (expected_root + canonical_path + file_name('expected')).relative_path_from(cwd)
      @test_image = (test_root + canonical_path + file_name('test')).relative_path_from cwd
      @difference_image = (test_root + canonical_path + file_name('difference')).relative_path_from cwd
    end

    def all
      [test_image, expected_image, difference_image]
    end

    def self.responsive_file_paths(example, expected_path = nil)
      RSpec::PageRegression.page_size.map do |page_size|
        new(example, page_size, expected_path)
      end
    end


    private

    def file_name(prefix)
      "#{prefix}-#{@page_size.join('x')}.png"
    end

    def description_ancestry(metadata)
      return [] if metadata.nil?
      description_ancestry(metadata[:parent_example_group]) << metadata[:description].parameterize("_")
    end
  end
end

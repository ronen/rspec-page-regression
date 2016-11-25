module Helpers

  def test_path(page_size = nil)
    getpath(TestDir, file_name('test', page_size))
  end

  def expected_path(page_size = nil)
    getpath(SpecDir, file_name('expected', page_size))
  end

  def difference_path(page_size = nil)
    getpath(TestDir, file_name('difference', page_size))
  end

  def getpath(root, base)
    (root + "expectation" + example_path(RSpec.current_example) + "#{base}.png").relative_path_from Pathname.getwd
  end

  def example_path(example)
    group_path(example.metadata[:example_group]) + example.description.parameterize("_")
  end

  def group_path(metadata)
    return Pathname.new("") if metadata.nil?
    group_path(metadata[:parent_example_group]) + metadata[:description].parameterize("_")
  end

  def file_name(prefix, page_size = nil)
    page_size ||= RSpec::PageRegression.page_size.first
    "#{prefix}-#{page_size.join('x')}"
  end

end

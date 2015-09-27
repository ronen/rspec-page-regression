module Helpers

  def test_path
    getpath(TestDir, file_name('test'))
  end

  def expected_path
    getpath(SpecDir, file_name('expected'))
  end

  def difference_path
    getpath(TestDir, file_name('difference'))
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

  def file_name(prefix)
    "#{prefix}-#{RSpec::PageRegression.page_size.first.join('x')}"
  end

end

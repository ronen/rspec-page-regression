module RSpec::PageRegression
  module Renderer

    def self.render(page, filepaths)
      test_image_path = filepaths.test_image
      test_image_path.dirname.mkpath unless test_image_path.dirname.exist?
      # Capybara doesn't implement resize in API
      unless page.driver.respond_to? :resize
        page.driver.browser.manage.window.resize_to *filepaths.page_size
      else
        page.driver.resize *filepaths.page_size
      end
      page.driver.save_screenshot test_image_path, full: true
    end

    def self.render_responsive(page, responsive_filepaths)
      responsive_filepaths.each { |fp| render(page, fp) }
    end
  end
end

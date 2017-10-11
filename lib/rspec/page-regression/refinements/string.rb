module RSpec::PageRegression
  module Refinements
    module String
      refine ::String do
        def parameterize(sep)
          downcased = self.downcase
          downcased.gsub!(/[^a-z0-9\-_]+/, sep)
          downcased
        end
      end
    end
  end
end

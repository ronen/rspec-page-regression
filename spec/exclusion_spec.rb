require 'spec_helper'

describe RSpec::PageRegression::Exclusion do
  it "excludes a whole row" do
    exc = RSpec::PageRegression::Exclusion.new [0, 1, -1, 10]
    expect(exc).to_not be_row 0
    expect(exc).to be_row 1
    expect(exc).to be_row 5
    expect(exc).to be_row 10
    expect(exc).to_not be_row 11
  end

  it "excludes to the bottom" do
    exc = RSpec::PageRegression::Exclusion.new [0, 10, -1, -1]
    expect(exc).to_not be_row 9
    expect(exc).to be_row 10
    expect(exc).to be_row 999
  end

  it "contains points" do
    exc = RSpec::PageRegression::Exclusion.new [1, 2, 3, 4]
    expect(exc).to_not be_point 0, 2
    expect(exc).to be_point 1, 2
    expect(exc).to be_point 1, 3
    expect(exc).to be_point 2, 4
    expect(exc).to be_point 3, 4
  end
end

module Fixtures

  def response_fixture(name)
    File.read(File.expand_path("../../fixtures/#{name}.json", __FILE__))
  end

end

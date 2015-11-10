require 'webmock'

RSpec.configure do |config|
  config.around(:each, webmock: false) do |example|
    WebMock.disable!
    example.run
    WebMock.enable!
  end
end

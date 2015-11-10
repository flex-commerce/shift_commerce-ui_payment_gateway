require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = File.expand_path("../fixtures/vcr_cassettes", __dir__)
  config.hook_into :webmock
  config.configure_rspec_metadata!
end
RSpec.configure do |config|
  config.around(:each, type: :feature) do |example|
    old_value = false
    VCR.configure do |config|
      old_value = config.allow_http_connections_when_no_cassette?
      config.allow_http_connections_when_no_cassette = true
    end
    example.run
    VCR.configure do |config|
      config.allow_http_connections_when_no_cassette = old_value
    end

  end
  config.around(:each, vcr: false) do |example|
    was_turned_on = VCR.turned_on?
    VCR.turn_off!
    example.run
    VCR.turn_on! if was_turned_on
  end
end

require "climate_control"
RSpec.configure do |config|
  config.around(:each, :env_vars => lambda { |v| !!v }) do |example|
    ClimateControl.modify example.metadata[:env_vars] do
      example.run
    end
  end

end
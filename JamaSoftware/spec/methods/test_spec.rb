# frozen_string_literal: true

RSpec.describe 'methods/test', :vcr do

  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_default_file }

  subject(:result) { connector.methods.test(arg_1, arg_2) }

  pending 'add some examples'
end

# frozen_string_literal: true

RSpec.describe 'actions/get_users', :vcr do

  # Spec describes the most commons blocks of an action. Remove describes that you don't need.
  # Learn more: https://docs.workato.com/developing-connectors/sdk/cli/reference/rspec-commands.html

  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }
  let(:settings) { Workato::Connector::Sdk::Settings.from_default_file }

  let(:action) { connector.actions.get_users }

  describe 'execute' do
    subject(:output) { action.execute(settings, input, extended_input_schema, extended_output_schema, continue) }

    pending 'add some examples'
  end

  describe 'sample_output' do
    subject(:sample_output) { action.sample_output(settings, input) }

    pending 'add some examples'
  end

  describe 'input_fields' do
    subject(:input_fields) { action.input_fields(settings, config_fields) }

    pending 'add some examples'
  end

  describe 'output_fields' do
    subject(:output_fields) { action.output_fields(settings, config_fields) }

    pending 'add some examples'
  end
end

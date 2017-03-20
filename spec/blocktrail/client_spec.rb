require 'spec_helper'

describe Blocktrail::Client do
  subject { described_class.new(ENV['API_KEY'], ENV['API_SECRET'], api_version = 'v1', testnet = true, debug = true) }

  it 'setup and returns api client' do
    expect(subject.api_key).not_to be nil
    expect(subject.api_secret).not_to be nil
    expect(subject.default_params).to eq api_key: subject.api_key
    expect(subject.testnet).to be_truthy
    expect(subject.debug).to be_truthy
  end
end

require 'spec_helper'
require 'zendesk_apps_tools/bump'
require 'zendesk_apps_tools/manifest_handler'

describe ZendeskAppsTools::Bump do
  VERSION_PARTS = ZendeskAppsTools::ManifestHandler::VERSION_PARTS

  subject { ZendeskAppsTools::Bump.new }

  def version
    subject.instance_variable_get(:@manifest).fetch('version')
  end

  before do
    allow(subject).to receive(:load_manifest)
    allow(subject).to receive(:write_manifest)
  end

  it 'works with imcomplete semver version' do
    subject.instance_variable_set(:@manifest, { 'version' => '1.0' })

    VERSION_PARTS.each do |part|
      expect { subject.send(part) }.not_to raise_error
    end
  end

  describe '#major' do
    before do
      subject.instance_variable_set(:@manifest, { 'version' => '1.2.3' })
      subject.major
    end

    it 'bumps major version, and cleans up minor and patch version' do
      expect(version).to eq('2.0.0')
    end
  end

  describe '#minor' do
    before do
      subject.instance_variable_set(:@manifest, { 'version' => '1.2.3' })
      subject.minor
    end

    it 'bumps minor version, and cleans up patch version' do
      expect(version).to eq('1.3.0')
    end
  end

  describe '#patch' do
    before do
      subject.instance_variable_set(:@manifest, { 'version' => '1.2.3' })
      subject.patch
    end

    it 'bumps patch version' do
      expect(version).to eq('1.2.4')
    end
  end
end

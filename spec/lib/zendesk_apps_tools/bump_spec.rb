require 'spec_helper'
require 'zendesk_apps_tools/bump'

describe ZendeskAppsTools::Bump do
  VERSION_PARTS = ZendeskAppsTools::ManifestHandler::VERSION_PARTS

  subject { ZendeskAppsTools::Bump.new }

  def version
    subject.instance_variable_get(:@manifest).fetch('version')
  end

  before do
    allow(subject).to receive(:load_manifest)
    allow(subject).to receive(:write_manifest)
    subject.instance_variable_set(:@manifest, { 'version' => '1.2.3' })
  end

  describe '#major' do
    before { subject.major }

    it 'bumps major version, and resets minor and patch version' do
      expect(version).to eq('2.0.0')
    end
  end

  describe '#minor' do
    before { subject.minor }

    it 'bumps minor version, and resets patch version' do
      expect(version).to eq('1.3.0')
    end
  end

  describe '#patch' do
    before { subject.patch }

    it 'bumps patch version' do
      expect(version).to eq('1.2.4')
    end
  end

  context 'when version is not complete semver' do
    before do
      subject.instance_variable_set(:@manifest, { 'version' => '1.0' })
    end

    it 'works with incomplete semver version' do
      VERSION_PARTS.each do |part|
        expect { subject.send(part) }.not_to raise_error
      end
    end

    it 'corrects the version to semver' do
      subject.patch
      expect(version).to eq('1.0.1')
    end

    it 'corrects the version to semver' do
      subject.minor
      expect(version).to eq('1.1.0')
    end

    it 'corrects the version to semver' do
      subject.major
      expect(version).to eq('2.0.0')
    end
  end
end

# frozen_string_literal: true
require 'spec_helper'
require 'zendesk_apps_tools/cache'
require 'tmpdir'
require 'fileutils'

describe ZendeskAppsTools::Cache do
  context 'with a local cache file' do
    let(:tmpdir)   { Dir.mktmpdir }
    let(:cache)    { ZendeskAppsTools::Cache.new(path: tmpdir) }
    let(:zat_file) { File.join(tmpdir, '.zat') }

    before do
      content = JSON.dump(subdomain: 'under-the-domain', username: 'Roger@something.com', app_id: 12)
      File.write(zat_file, content, mode: 'w')
    end

    after do
      FileUtils.rm_r tmpdir
    end

    describe '#fetch' do
      it 'reads data from the cache' do
        expect(cache.fetch('username')).to eq 'Roger@something.com'
      end

      context 'with a global cache' do
        before do
          fake_home = File.join(tmpdir, 'fake_home')
          FileUtils.mkdir_p(fake_home)
          allow(Dir).to receive(:home).and_return(fake_home)
          global_content = JSON.dump(global_subdomain: { password: 'hunter2' }, default: { subdomain: 'default-domain', password: 'hunter3' })
          File.write(File.join(fake_home, '.zat'), global_content, mode: 'w')
        end

        it 'falls back to global cache' do
          expect(cache.fetch('password', 'global_subdomain')).to eq 'hunter2'
        end

        it 'falls back to global cache default' do
          expect(cache.fetch('password')).to eq 'hunter3'
        end
      end
    end

    describe '#save' do
      it 'works' do
        cache.save(other_key: 'value')
        expect(JSON.parse(File.read(zat_file))['other_key']).to eq 'value'
      end
    end

    describe '#clear' do
      it 'does nothing by default' do
        cache.clear
        expect(File.exist?(zat_file)).to be_truthy
      end

      it 'works' do
        cache = ZendeskAppsTools::Cache.new(path: tmpdir, clean: true)
        cache.clear
        expect(File.exist?(zat_file)).to be_falsey
      end
    end
  end
end

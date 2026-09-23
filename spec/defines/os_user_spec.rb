# frozen_string_literal: true

require 'spec_helper'

describe 'victorialogs::install::os_user' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:title) { 'example' }
      let(:params) { {} }

      context 'with default params' do
        it { is_expected.to contain_group('example').with_ensure('present').with_system(true) }

        it do
          is_expected.to contain_user('example')
            .with_ensure('present')
            .with_comment('Example user')
            .with_system(true)
            .with_gid('example')
            .with_shell('/usr/sbin/nologin')
            .with_home('/var/lib/example')
            .with_managehome(false)
            .that_comes_before(nil)
        end

        it do
          is_expected.to contain_file('/var/lib/example')
            .with_ensure('directory')
            .with_mode('0750')
            .with_owner('example')
            .with_group('example')
            .without_recurse
            .without_force
        end
      end

      context 'with manage_group=false' do
        let(:params) { super().merge(manage_group: false) }

        it { is_expected.not_to contain_group('example') }
      end

      context 'with group set' do
        let(:params) { super().merge(group: 'foo') }

        it { is_expected.to contain_group('foo') }
        it { is_expected.to contain_user('example').with_gid('foo') }
        it { is_expected.to contain_file('/var/lib/example').with_group('foo') }
      end

      context 'with manage_user=false' do
        let(:params) { super().merge(manage_user: false) }

        it { is_expected.not_to contain_user('example') }
      end

      context 'with user set' do
        let(:params) { super().merge(user: 'foo') }

        it { is_expected.to contain_group('foo') }
        it { is_expected.to contain_user('foo').with_home('/var/lib/foo').with_comment('Foo user') }
        it { is_expected.to contain_file('/var/lib/foo').with_owner('foo').with_group('foo') }
      end

      context 'with shell set' do
        let(:params) { super().merge(shell: '/bin/bash') }

        it { is_expected.to contain_user('example').with_shell('/bin/bash') }
      end

      context 'with homedir set' do
        let(:params) { super().merge(homedir: '/srv/example') }

        it { is_expected.to contain_user('example').with_home('/srv/example') }
        it { is_expected.to contain_file('/srv/example') }
      end

      context 'with homedir attributes set' do
        let(:params) { super().merge(homedir_mode: '0751', homedir_owner: 'foo', homedir_group: 'bar') }

        it { is_expected.to contain_file('/var/lib/example').with_mode('0751').with_owner('foo').with_group('bar') }
      end

      context 'with manage_homedir=false' do
        let(:params) { super().merge(manage_homedir: false) }

        it { is_expected.not_to contain_file('/var/lib/example') }
      end

      context 'with ensure=>absent' do
        let(:params) { super().merge(ensure: 'absent') }

        it { is_expected.to contain_group('example').with_ensure('absent') }

        it do
          is_expected.to contain_user('example')
            .with_ensure('absent')
            .that_comes_before('Group[example]')
        end

        it do
          is_expected.to contain_file('/var/lib/example')
            .with_ensure('absent')
            .with_recurse(true)
            .with_force(true)
        end
      end
    end
  end
end

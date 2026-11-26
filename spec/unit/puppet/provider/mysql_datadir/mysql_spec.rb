# frozen_string_literal: true

require 'spec_helper'

describe Puppet::Type.type(:mysql_datadir).provider(:mysql) do
  let(:provider) { resource.provider }
  let(:resource_params) do
    {
      ensure: :present,
      datadir: '/var/lib/mysql',
      basedir: '/usr',
      user: 'mysql',
      log_error: '/var/tmp/mysqld_initialize.log',
      provider: described_class.name,
    }
  end
  let(:resource) { Puppet::Type.type(:mysql_datadir).new(resource_params) }
  let(:expected_exec_options) do
    {
      uid: 'mysql',
      gid: 27,
      cwd: '/',
      custom_environment: { 'HOME' => '/var/lib/mysql', 'USER' => 'mysql' },
      failonfail: true,
      combine: true,
    }
  end

  before :each do
    allow(Facter).to receive(:value).with(:root_home).and_return('/root')
    allow(Puppet::Util).to receive(:which).with('mysqld').and_return('/usr/sbin/mysqld')
    allow(Puppet::Util).to receive(:which).with('mariadbd').and_return(nil)
    allow(Etc).to receive(:getpwnam).with('mysql').and_return(
      instance_double(Etc::Passwd, name: 'mysql', uid: 27, gid: 27, dir: '/var/lib/mysql'),
    )
    allow(File).to receive(:directory?).and_call_original
    allow(File).to receive(:directory?).with('/var/lib/mysql').and_return(true)
    allow(File).to receive(:stat).and_call_original
    allow(File).to receive(:stat).with('/var/lib/mysql').and_return(instance_double(File::Stat, uid: 27))
    allow(provider).to receive(:set_selinux_default_context)
  end

  describe 'create' do
    context 'with MySQL >= 5.7.6' do
      before :each do
        allow(provider).to receive_messages(mysqld_version: '8.0.36', exists?: true)
        allow(provider).to receive(:newer_than).with('mysql' => '5.7.6', 'percona' => '5.7.6').and_return(true)
      end

      it 'initializes the datadir as the configured user with mysqld and without --user' do
        expect(provider).to receive(:execute).with(
          [
            '/usr/sbin/mysqld',
            '--basedir=/usr',
            '--datadir=/var/lib/mysql',
            '--log-error=/var/tmp/mysqld_initialize.log',
            '--initialize-insecure',
          ],
          expected_exec_options,
        )

        expect(provider.create).to be(true)
      end

      it 'falls back to mariadbd when mysqld is unavailable' do
        allow(Puppet::Util).to receive(:which).with('mysqld').and_return(nil)
        allow(Puppet::Util).to receive(:which).with('mariadbd').and_return('/usr/libexec/mariadbd')

        expect(provider).to receive(:execute).with(
          [
            '/usr/libexec/mariadbd',
            '--basedir=/usr',
            '--datadir=/var/lib/mysql',
            '--log-error=/var/tmp/mysqld_initialize.log',
            '--initialize-insecure',
          ],
          expected_exec_options,
        )

        expect(provider.create).to be(true)
      end

      it 'raises Puppet::MissingCommand when no mysqld binary can be resolved' do
        allow(Puppet::Util).to receive(:which).with('mysqld').and_return(nil)
        allow(Puppet::Util).to receive(:which).with('mariadbd').and_return(nil)

        expect { provider.create }.to raise_error(Puppet::MissingCommand, %r{Command mysqld is missing})
      end
    end

    context 'with MariaDB or MySQL < 5.7.6' do
      before :each do
        allow(provider).to receive_messages(mysqld_version: '10.5.22', exists?: true)
        allow(provider).to receive(:newer_than).with('mysql' => '5.7.6', 'percona' => '5.7.6').and_return(false)
        allow(provider).to receive(:command).with(:mysql_install_db).and_return('/usr/bin/mysql_install_db')
      end

      it 'initializes the datadir as the configured user with mysql_install_db and without --user' do
        expect(provider).to receive(:execute).with(
          [
            '/usr/bin/mysql_install_db',
            '--basedir=/usr',
            '--datadir=/var/lib/mysql',
          ],
          expected_exec_options,
        )

        expect(provider.create).to be(true)
      end

      it 'raises Puppet::MissingCommand when mysql_install_db is missing' do
        allow(provider).to receive(:command).with(:mysql_install_db).and_return(nil)

        expect { provider.create }.to raise_error(Puppet::MissingCommand, %r{Command mysql_install_db is missing})
      end
    end

    context 'when preparing the datadir directory' do
      before :each do
        allow(provider).to receive_messages(mysqld_version: '10.5.22', exists?: true)
        allow(provider).to receive(:newer_than).with('mysql' => '5.7.6', 'percona' => '5.7.6').and_return(false)
        allow(provider).to receive(:command).with(:mysql_install_db).and_return('/usr/bin/mysql_install_db')
      end

      it 'creates, chowns, and restores SELinux context before execution when datadir is missing' do
        allow(File).to receive(:directory?).with('/var/lib/mysql').and_return(false)

        expect(FileUtils).to receive(:mkdir_p).with('/var/lib/mysql', mode: 0o750).ordered
        expect(FileUtils).to receive(:chown).with(27, 27, '/var/lib/mysql').ordered
        expect(provider).to receive(:set_selinux_default_context).with('/var/lib/mysql', :directory).ordered
        expect(provider).to receive(:execute).with(anything, expected_exec_options).ordered

        provider.create
      end

      it 'chowns and restores SELinux context without mkdir_p when an existing datadir is owned by root' do
        root_stat = instance_double(File::Stat, uid: 0)
        allow(File).to receive(:stat).with('/var/lib/mysql').and_return(root_stat)

        expect(FileUtils).not_to receive(:mkdir_p)
        expect(FileUtils).to receive(:chown).with(27, 27, '/var/lib/mysql').ordered
        expect(provider).to receive(:set_selinux_default_context).with('/var/lib/mysql', :directory).ordered
        expect(provider).to receive(:execute).with(anything, expected_exec_options).ordered

        provider.create
      end

      it 'leaves ownership and SELinux context untouched when datadir already belongs to the user' do
        expect(FileUtils).not_to receive(:mkdir_p)
        expect(FileUtils).not_to receive(:chown)
        expect(provider).not_to receive(:set_selinux_default_context)
        expect(provider).to receive(:execute).with(anything, expected_exec_options)

        provider.create
      end
    end

    context 'with custom user and defaults_extra_file' do
      let(:resource_params) do
        super().merge(user: 'mysqld_custom', defaults_extra_file: '/etc/my.cnf.d/server.cnf')
      end
      let(:expected_exec_options) do
        {
          uid: 'mysqld_custom',
          gid: 302,
          cwd: '/',
          custom_environment: { 'HOME' => '/srv/mysql', 'USER' => 'mysqld_custom' },
          failonfail: true,
          combine: true,
        }
      end

      before :each do
        allow(Etc).to receive(:getpwnam).with('mysqld_custom').and_return(
          instance_double(Etc::Passwd, name: 'mysqld_custom', uid: 301, gid: 302, dir: '/srv/mysql'),
        )
        allow(File).to receive(:stat).with('/var/lib/mysql').and_return(instance_double(File::Stat, uid: 301))
        allow(provider).to receive_messages(mysqld_version: '8.0.36', exists?: true)
        allow(provider).to receive(:newer_than).with('mysql' => '5.7.6', 'percona' => '5.7.6').and_return(true)
        allow(File).to receive(:exist?).and_call_original
      end

      it 'passes defaults-extra-file and runs under the custom user uid/gid/env' do
        allow(File).to receive(:exist?).with('/etc/my.cnf.d/server.cnf').and_return(true)

        expect(provider).to receive(:execute).with(
          [
            '/usr/sbin/mysqld',
            '--defaults-extra-file=/etc/my.cnf.d/server.cnf',
            '--basedir=/usr',
            '--datadir=/var/lib/mysql',
            '--log-error=/var/tmp/mysqld_initialize.log',
            '--initialize-insecure',
          ],
          expected_exec_options,
        )

        expect(provider.create).to be(true)
      end

      it 'raises ArgumentError when defaults_extra_file does not exist' do
        allow(File).to receive(:exist?).with('/etc/my.cnf.d/server.cnf').and_return(false)

        expect(provider).not_to receive(:execute)
        expect { provider.create }.to raise_error(ArgumentError, %r{Defaults-extra-file /etc/my.cnf.d/server.cnf is missing})
      end
    end
  end

  describe 'destroy' do
    it 'raises ArgumentError since the datadir cannot be removed' do
      expect { provider.destroy }.to raise_error(ArgumentError, %r{Resource.*can not be removed})
    end
  end

  describe 'exists?' do
    it 'returns true when the mysql subdirectory contains entries' do
      allow(File).to receive(:directory?).with('/var/lib/mysql/mysql').and_return(true)
      allow(Dir).to receive(:entries).with('/var/lib/mysql/mysql').and_return(['.', '..', 'user.frm'])

      expect(provider).to be_exists
    end

    it 'returns false when the mysql subdirectory does not exist' do
      allow(File).to receive(:directory?).with('/var/lib/mysql/mysql').and_return(false)

      expect(provider).not_to be_exists
    end

    it 'returns false when the mysql subdirectory is empty' do
      allow(File).to receive(:directory?).with('/var/lib/mysql/mysql').and_return(true)
      allow(Dir).to receive(:entries).with('/var/lib/mysql/mysql').and_return(['.', '..'])

      expect(provider).not_to be_exists
    end
  end
end

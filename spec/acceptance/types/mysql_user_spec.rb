# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'mysql_user' do
  describe 'setup' do
    pp_one = <<-MANIFEST
        $ed25519_opts = versioncmp($facts['mysql_version'], '10.1.21') >= 0 ? {
          true  => {
            restart => true,
            override_options => { 'mysqld' => { 'plugin_load_add' => 'auth_ed25519' } },
          },
          false => {}
        }
        class { 'mysql::server': * => $ed25519_opts }
    MANIFEST
    it 'works with no errors' do
      apply_manifest(pp_one, catch_failures: true)
    end
  end

  context 'using ashp@localhost' do
    describe 'adding user' do
      pp_two = <<-MANIFEST
          mysql_user { 'ashp@localhost':
            password_hash => '*F9A8E96790775D196D12F53BCC88B8048FF62ED5',
          }
      MANIFEST
      it 'works without errors' do
        apply_manifest(pp_two, catch_failures: true)
      end

      it 'finds the user #stdout' do
        run_shell("mysql -NBe \"select '1' from mysql.user where CONCAT(user, '@', host) = 'ashp@localhost'\"") do |r|
          expect(r.stdout).to match(%r{^1$})
          expect(r.stderr).to be_empty
        end
      end

      it 'has no SSL options #stdout' do
        run_shell("mysql -NBe \"select SSL_TYPE from mysql.user where CONCAT(user, '@', host) = 'ashp@localhost'\"") do |r|
          expect(r.stdout).to match(%r{^\s*$})
          expect(r.stderr).to be_empty
        end
      end
    end

    describe 'changing authentication plugin', if: (Gem::Version.new(mysql_version) > Gem::Version.new('5.5.0') && os[:release] !~ %r{^16\.04}) do
      it 'works without errors', if: (os[:family] != 'sles' && os[:release].to_i == 15) do
        pp = <<-EOS
          mysql_user { 'ashp@localhost':
            plugin => 'auth_socket',
          }
        EOS

        idempotent_apply(pp)
      end

      it 'has the correct plugin', if: (os[:family] != 'sles' && os[:release].to_i == 15) do
        run_shell("mysql -NBe \"select plugin from mysql.user where CONCAT(user, '@', host) = 'ashp@localhost'\"") do |r|
          expect(r.stdout.rstrip).to eq('auth_socket')
          expect(r.stderr).to be_empty
        end
      end

      it 'does not have a password', if: (os[:family] != 'sles' && os[:release].to_i == 15) do
        table = if Gem::Version.new(mysql_version) > Gem::Version.new('5.7.0')
                  'authentication_string'
                else
                  'password'
                end
        run_shell("mysql -NBe \"select #{table} from mysql.user where CONCAT(user, '@', host) = 'ashp@localhost'\"") do |r|
          expect(r.stdout.rstrip).to be_empty
          expect(r.stderr).to be_empty
        end
      end
    end

    describe 'using ed25519 authentication plugin', if: Gem::Version.new(mysql_version) > Gem::Version.new('10.1.21') do
      it 'works without errors' do
        pp = <<-EOS
          mysql_user { 'ashp@localhost':
            plugin        => 'ed25519',
            password_hash => 'z0pjExBYbzbupUByZRrQvC6kRCcE8n/tC7kUdUD11fU',
          }
        EOS

        idempotent_apply(pp)
      end

      it 'has the correct plugin' do
        run_shell("mysql -NBe \"select plugin from mysql.user where CONCAT(user, '@', host) = 'ashp@localhost'\"") do |r|
          expect(r.stdout.rstrip).to eq('ed25519')
          expect(r.stderr).to be_empty
        end
      end
    end
    # rubocop:enable RSpec/ExampleLength, RSpec/MultipleExpectations
  end

  context 'using ashp-dash@localhost' do
    describe 'adding user' do
      pp_three = <<-MANIFEST
          mysql_user { 'ashp-dash@localhost':
            password_hash => '*F9A8E96790775D196D12F53BCC88B8048FF62ED5',
          }
      MANIFEST
      it 'works without errors' do
        apply_manifest(pp_three, catch_failures: true)
      end

      it 'finds the user #stdout' do
        run_shell("mysql -NBe \"select '1' from mysql.user where CONCAT(user, '@', host) = 'ashp-dash@localhost'\"") do |r|
          expect(r.stdout).to match(%r{^1$})
          expect(r.stderr).to be_empty
        end
      end
    end
  end

  context 'using ashp@LocalHost' do
    describe 'adding user' do
      pp_four = <<-MANIFEST
          mysql_user { 'ashp@LocalHost':
            password_hash => '*F9A8E96790775D196D12F53BCC88B8048FF62ED5',
          }
      MANIFEST
      it 'works without errors' do
        apply_manifest(pp_four, catch_failures: true)
      end

      it 'finds the user #stdout' do
        run_shell("mysql -NBe \"select '1' from mysql.user where CONCAT(user, '@', host) = 'ashp@localhost'\"") do |r|
          expect(r.stdout).to match(%r{^1$})
          expect(r.stderr).to be_empty
        end
      end
    end
  end
  context 'using resource should throw no errors' do
    describe 'find users' do
      it do
        result = run_shell('puppet resource mysql_user')
        expect(result.stdout).not_to match(%r{Error:})
        expect(result.stdout).not_to match(%r{must be properly quoted, invalid character:})
      end
    end
  end
  context 'using user-w-ssl@localhost with SSL' do
    describe 'adding user' do
      pp_five = <<-MANIFEST
          mysql_user { 'user-w-ssl@localhost':
            password_hash => '*F9A8E96790775D196D12F53BCC88B8048FF62ED5',
            tls_options   => ['SSL'],
          }
      MANIFEST
      it 'works without errors' do
        apply_manifest(pp_five, catch_failures: true)
      end

      it 'finds the user #stdout' do
        run_shell("mysql -NBe \"select '1' from mysql.user where CONCAT(user, '@', host) = 'user-w-ssl@localhost'\"") do |r|
          expect(r.stdout).to match(%r{^1$})
          expect(r.stderr).to be_empty
        end
      end

      it 'shows correct ssl_type #stdout' do
        run_shell("mysql -NBe \"select SSL_TYPE from mysql.user where CONCAT(user, '@', host) = 'user-w-ssl@localhost'\"") do |r|
          expect(r.stdout).to match(%r{^ANY$})
          expect(r.stderr).to be_empty
        end
      end
    end
  end
  context 'using user-w-x509@localhost with X509' do
    describe 'adding user' do
      pp_six = <<-MANIFEST
          mysql_user { 'user-w-x509@localhost':
            password_hash => '*F9A8E96790775D196D12F53BCC88B8048FF62ED5',
            tls_options   => ['X509'],
          }
      MANIFEST
      it 'works without errors' do
        apply_manifest(pp_six, catch_failures: true)
      end

      it 'finds the user #stdout' do
        run_shell("mysql -NBe \"select '1' from mysql.user where CONCAT(user, '@', host) = 'user-w-x509@localhost'\"") do |r|
          expect(r.stdout).to match(%r{^1$})
          expect(r.stderr).to be_empty
        end
      end

      it 'shows correct ssl_type #stdout' do
        run_shell("mysql -NBe \"select SSL_TYPE from mysql.user where CONCAT(user, '@', host) = 'user-w-x509@localhost'\"") do |r|
          expect(r.stdout).to match(%r{^X509$})
          expect(r.stderr).to be_empty
        end
      end
    end
  end
  context 'using user-w-subject@localhost with ISSUER and SUBJECT' do
    describe 'adding user' do
      it 'works without errors' do
        pp = <<-MANIFEST
        mysql_user { 'user-w-subject@localhost':
          tls_options   => [
            "SUBJECT '/OU=MySQL Users/CN=username'",
            "ISSUER '/CN=Certificate Authority'",
            "CIPHER 'EDH-RSA-DES-CBC3-SHA'",
          ],
        }
        MANIFEST
        idempotent_apply(pp)
      end

      it 'finds the user #stdout' do
        run_shell("mysql -NBe \"select '1' from mysql.user where CONCAT(user, '@', host) = 'user-w-subject@localhost'\"") do |r|
          expect(r.stdout).to match(%r{^1$})
          expect(r.stderr).to be_empty
        end
      end

      it 'shows correct ssl_type #stdout' do
        run_shell("mysql -NBe \"select SSL_TYPE from mysql.user where CONCAT(user, '@', host) = 'user-w-subject@localhost'\"") do |r|
          expect(r.stdout).to match(%r{^SPECIFIED$})
          expect(r.stderr).to be_empty
        end
      end

      it 'shows correct x509_issuer #stdout' do
        run_shell("mysql -NBe \"select X509_ISSUER from mysql.user where CONCAT(user, '@', host) = 'user-w-subject@localhost'\"") do |r|
          expect(r.stdout).to match(%r{^/CN=Certificate Authority$})
          expect(r.stderr).to be_empty
        end
      end

      it 'shows correct x509_subject #stdout' do
        run_shell("mysql -NBe \"select X509_SUBJECT from mysql.user where CONCAT(user, '@', host) = 'user-w-subject@localhost'\"") do |r|
          expect(r.stdout).to match(%r{^/OU=MySQL Users/CN=username$})
          expect(r.stderr).to be_empty
        end
      end

      it 'shows correct ssl_cipher #stdout' do
        run_shell("mysql -NBe \"select SSL_CIPHER from mysql.user where CONCAT(user, '@', host) = 'user-w-subject@localhost'\"") do |r|
          expect(r.stdout).to match(%r{^EDH-RSA-DES-CBC3-SHA$})
          expect(r.stderr).to be_empty
        end
      end
    end
  end
end

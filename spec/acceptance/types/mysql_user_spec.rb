require 'spec_helper_acceptance'
require_relative '../mysql_helper.rb'

describe 'mysql_user' do
  describe 'setup' do
    pp_one = <<-MANIFEST
        class { 'mysql::server': }
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
        shell("mysql -NBe \"select '1' from mysql.user where CONCAT(user, '@', host) = 'ashp@localhost'\"") do |r|
          expect(r.stdout).to match(%r{^1$})
        end
      end
      it 'finds the user #stderr' do
        shell("mysql -NBe \"select '1' from mysql.user where CONCAT(user, '@', host) = 'ashp@localhost'\"") do |r|
          expect(r.stderr).to be_empty
        end
      end

      it 'has no SSL options #stdout' do
        shell("mysql -NBe \"select SSL_TYPE from mysql.user where CONCAT(user, '@', host) = 'ashp@localhost'\"") do |r|
          expect(r.stdout).to match(%r{^\s*$})
        end
      end
      it 'has no SSL options #stderr' do
        shell("mysql -NBe \"select SSL_TYPE from mysql.user where CONCAT(user, '@', host) = 'ashp@localhost'\"") do |r|
          expect(r.stderr).to be_empty
        end
      end
    end

    pre_run
    describe 'changing authentication plugin', if: version_is_greater_than('5.5.0') do
      it 'works without errors' do
        pp = <<-EOS
          mysql_user { 'ashp@localhost':
            plugin => 'auth_socket',
          }
        EOS

        apply_manifest(pp, catch_failures: true)
      end

      it 'has the correct plugin' do
        shell("mysql -NBe \"select plugin from mysql.user where CONCAT(user, '@', host) = 'ashp@localhost'\"") do |r|
          expect(r.stdout.rstrip).to eq('auth_socket')
          expect(r.stderr).to be_empty
        end
      end

      it 'does not have a password' do
        pre_run
        table = if version_is_greater_than('5.7.0')
                  'authentication_string'
                else
                  'password'
                end
        shell("mysql -NBe \"select #{table} from mysql.user where CONCAT(user, '@', host) = 'ashp@localhost'\"") do |r|
          expect(r.stdout.rstrip).to be_empty
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
        shell("mysql -NBe \"select '1' from mysql.user where CONCAT(user, '@', host) = 'ashp-dash@localhost'\"") do |r|
          expect(r.stdout).to match(%r{^1$})
        end
      end
      it 'finds the user #stderr' do
        shell("mysql -NBe \"select '1' from mysql.user where CONCAT(user, '@', host) = 'ashp-dash@localhost'\"") do |r|
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
        shell("mysql -NBe \"select '1' from mysql.user where CONCAT(user, '@', host) = 'ashp@localhost'\"") do |r|
          expect(r.stdout).to match(%r{^1$})
        end
      end
      it 'finds the user #stderr' do
        shell("mysql -NBe \"select '1' from mysql.user where CONCAT(user, '@', host) = 'ashp@localhost'\"") do |r|
          expect(r.stderr).to be_empty
        end
      end
    end
  end
  context 'using resource should throw no errors' do
    describe 'find users' do
      it do
        on default, puppet('resource mysql_user'), catch_failures: true do |r|
          expect(r.stdout).not_to match(%r{Error:})
        end
      end
      it do
        on default, puppet('resource mysql_user'), catch_failures: true do |r|
          expect(r.stdout).not_to match(%r{must be properly quoted, invalid character:})
        end
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
        shell("mysql -NBe \"select '1' from mysql.user where CONCAT(user, '@', host) = 'user-w-ssl@localhost'\"") do |r|
          expect(r.stdout).to match(%r{^1$})
        end
      end
      it 'finds the user #stderr' do
        shell("mysql -NBe \"select '1' from mysql.user where CONCAT(user, '@', host) = 'user-w-ssl@localhost'\"") do |r|
          expect(r.stderr).to be_empty
        end
      end

      it 'shows correct ssl_type #stdout' do
        shell("mysql -NBe \"select SSL_TYPE from mysql.user where CONCAT(user, '@', host) = 'user-w-ssl@localhost'\"") do |r|
          expect(r.stdout).to match(%r{^ANY$})
        end
      end
      it 'shows correct ssl_type #stderr' do
        shell("mysql -NBe \"select SSL_TYPE from mysql.user where CONCAT(user, '@', host) = 'user-w-ssl@localhost'\"") do |r|
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
        shell("mysql -NBe \"select '1' from mysql.user where CONCAT(user, '@', host) = 'user-w-x509@localhost'\"") do |r|
          expect(r.stdout).to match(%r{^1$})
        end
      end
      it 'finds the user #stderr' do
        shell("mysql -NBe \"select '1' from mysql.user where CONCAT(user, '@', host) = 'user-w-x509@localhost'\"") do |r|
          expect(r.stderr).to be_empty
        end
      end

      it 'shows correct ssl_type #stdout' do
        shell("mysql -NBe \"select SSL_TYPE from mysql.user where CONCAT(user, '@', host) = 'user-w-x509@localhost'\"") do |r|
          expect(r.stdout).to match(%r{^X509$})
        end
      end
      it 'shows correct ssl_type #stderr' do
        shell("mysql -NBe \"select SSL_TYPE from mysql.user where CONCAT(user, '@', host) = 'user-w-x509@localhost'\"") do |r|
          expect(r.stderr).to be_empty
        end
      end
    end
  end
  context 'using example jeffrey@localhost from MySQL 5.7 Reference manual' do
    describe 'adding user' do
      ## What it currently emits:
      #  GRANT USAGE ON *.* TO 'jeffrey'@'localhost'
      #    REQUIRE X509
      #    AND SUBJECT /C=SE/ST=Stockholm/L=Stockholm/O=MySQL demo client certificate/CN=client/emailAddress=client@example.com
      #    AND ISSUER /C=SE/ST=Stockholm/L=Stockholm/O=MySQL/CN=CA/emailAddress=ca@example.com
      # returned 1: ERROR 1064 (42000) at line 1: You have an error in your SQL syntax;
      # check the manual that corresponds to your MySQL server version for the right syntax to use near
      # 'AND SUBJECT /C=FI/ST=Somewhere/L=City/ O=Some Company/CN=Peter Parker/emailAddre' at line 1
      #
      ## What it should emit:
      #  GRANT USAGE ON *.* TO 'jeffrey'@'localhost'
      #    REQUIRE SUBJECT '/C=SE/ST=Stockholm/L=Stockholm/O=MySQL demo client certificate/CN=client/emailAddress=client@example.com'
      #    AND ISSUER '/C=SE/ST=Stockholm/L=Stockholm/O=MySQL/CN=CA/emailAddress=ca@example.com'
      #
      pp_six = <<-MANIFEST
        mysql_user { 'jeffrey@localhost':
          password_hash => '*F9A8E96790775D196D12F53BCC88B8048FF62ED5',
          tls_options   => [
            'X509',
            'SUBJECT /C=SE/ST=Stockholm/L=Stockholm/O=MySQL demo client certificate/CN=client/emailAddress=client@example.com',
            'ISSUER /C=SE/ST=Stockholm/L=Stockholm/O=MySQL/CN=CA/emailAddress=ca@example.com',
          ],
        }
      MANIFEST
      it 'works without errors' do
        apply_manifest(pp_six, catch_failures: true)
      end

      it 'finds the user #stdout' do
        shell("mysql -NBe \"select '1' from mysql.user where CONCAT(user, '@', host) = 'jeffrey@localhost'\"") do |r|
          expect(r.stdout).to match(%r{^1$})
        end
      end
      it 'finds the user #stderr' do
        shell("mysql -NBe \"select '1' from mysql.user where CONCAT(user, '@', host) = 'jeffrey@localhost'\"") do |r|
          expect(r.stderr).to be_empty
        end
      end
      it 'shows correct ssl_type #stdout' do
        shell("mysql -NBe \"select SSL_TYPE from mysql.user where CONCAT(user, '@', host) = 'jeffrey@localhost'\"") do |r|
          expect(r.stdout).to match(%r{^SPECIFIED})
        end
      end
      it 'shows correct ssl_type #stderr' do
        shell("mysql -NBe \"select SSL_TYPE from mysql.user where CONCAT(user, '@', host) = 'jeffrey@localhost'\"") do |r|
          expect(r.stderr).to be_empty
        end
      end
      it 'shows correct x509_subject #stdout' do
        shell("mysql -NBe \"select X509_SUBJECT from mysql.user where CONCAT(user, '@', host) = 'jeffrey@localhost'\"") do |r|
          expect(r.stdout).to match(%r{^/C=SE/ST=Stockholm/L=Stockholm/O=MySQL demo client certificate/CN=client/emailAddress=client@example.com})
        end
      end
      it 'shows correct x509_subject #stderr' do
        shell("mysql -NBe \"select X509_SUBJECT from mysql.user where CONCAT(user, '@', host) = 'jeffrey@localhost'\"") do |r|
          expect(r.stderr).to be_empty
        end
      end
      it 'shows correct x509_issuer #stdout' do
        shell("mysql -NBe \"select X509_ISSUER from mysql.user where CONCAT(user, '@', host) = 'jeffrey@localhost'\"") do |r|
          expect(r.stdout).to match(%r{^/C=SE/ST=Stockholm/L=Stockholm/O=MySQL/CN=CA/emailAddress=ca@example.com})
        end
      end
      it 'shows correct x509_issuer #stderr' do
        shell("mysql -NBe \"select X509_ISSUER from mysql.user where CONCAT(user, '@', host) = 'jeffrey@localhost'\"") do |r|
          expect(r.stderr).to be_empty
        end
      end
    end
  end
  context 'using example someone@localhost from MariaDB documentation' do
    describe 'adding user' do
      pp_six = <<-MANIFEST
        mysql_user { 'someone@localhost':
          tls_options   => [
            'SUBJECT /CN=www.mydom.com/O=My Dom, Inc./C=US/ST=Oregon/L=Portland',
            'ISSUER /C=FI/ST=Somewhere/L=City/ O=Some Company/CN=Peter Parker/emailAddress=p.parker@marvel.com',
          ],
        }
      MANIFEST
      ## What it currently emits:
      # GRANT USAGE ON *.* TO 'someone'@'localhost'
      #   REQUIRE SUBJECT /CN=www.mydom.com/O=My Dom, Inc./C=US/ST=Oregon/L=Portland
      #   AND ISSUER /C=FI/ST=Somewhere/L=City/ O=Some Company/CN=Peter Parker/emailAddress=p.parker@marvel.com
      #
      ## What it should emit:
      # GRANT USAGE ON *.* TO 'someone'@'localhost'
      #   REQUIRE SUBJECT '/CN=www.mydom.com/O=My Dom, Inc./C=US/ST=Oregon/L=Portland'
      #   AND ISSUER '/C=FI/ST=Somewhere/L=City/ O=Some Company/CN=Peter Parker/emailAddress=p.parker@marvel.com'
      #
      it 'works without errors' do
        apply_manifest(pp_six, catch_failures: true)
      end

      it 'finds the user #stdout' do
        shell("mysql -NBe \"select '1' from mysql.user where CONCAT(user, '@', host) = 'someone@localhost'\"") do |r|
          expect(r.stdout).to match(%r{^1$})
        end
      end
      it 'finds the user #stderr' do
        shell("mysql -NBe \"select '1' from mysql.user where CONCAT(user, '@', host) = 'someone@localhost'\"") do |r|
          expect(r.stderr).to be_empty
        end
      end
      it 'shows correct ssl_type #stdout' do
        shell("mysql -NBe \"select SSL_TYPE from mysql.user where CONCAT(user, '@', host) = 'someone@localhost'\"") do |r|
          expect(r.stdout).to match(%r{^SPECIFIED})
        end
      end
      it 'shows correct ssl_type #stderr' do
        shell("mysql -NBe \"select SSL_TYPE from mysql.user where CONCAT(user, '@', host) = 'someone@localhost'\"") do |r|
          expect(r.stderr).to be_empty
        end
      end
      it 'shows correct x509_subject #stdout' do
        shell("mysql -NBe \"select X509_SUBJECT from mysql.user where CONCAT(user, '@', host) = 'someone@localhost'\"") do |r|
          expect(r.stdout).to match(%r{^/CN=www.mydom.com/O=My Dom, Inc./C=US/ST=Oregon/L=Portland})
        end
      end
      it 'shows correct x509_subject #stderr' do
        shell("mysql -NBe \"select X509_SUBJECT from mysql.user where CONCAT(user, '@', host) = 'someone@localhost'\"") do |r|
          expect(r.stderr).to be_empty
        end
      end
      it 'shows correct x509_issuer #stdout' do
        shell("mysql -NBe \"select X509_ISSUER from mysql.user where CONCAT(user, '@', host) = 'someone@localhost'\"") do |r|
          expect(r.stdout).to match(%r{^/C=FI/ST=Somewhere/L=City/ O=Some Company/CN=Peter Parker/emailAddress=p.parker@marvel.com})
        end
      end
      it 'shows correct x509_issuer #stderr' do
        shell("mysql -NBe \"select X509_ISSUER from mysql.user where CONCAT(user, '@', host) = 'someone@localhost'\"") do |r|
          expect(r.stderr).to be_empty
        end
      end
    end
  end
end

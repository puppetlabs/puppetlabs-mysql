require 'spec_helper_acceptance'
require_relative '../mysql_helper.rb'

describe 'mysql_database' do
  describe 'setup' do
    it 'works with no errors' do
      pp = <<-EOS
        class { 'mysql::server': }
      EOS

      apply_manifest(pp, catch_failures: true)
    end
  end

  describe 'creating database' do
    let(:pp) do
      <<-EOS
        mysql_database { 'spec_db':
          ensure => present,
        }
      EOS
    end

    it 'works without errors' do
      apply_manifest(pp, catch_failures: true)
    end

    it 'finds the database' do
      shell("mysql -NBe \"SHOW DATABASES LIKE 'spec_db'\"") do |r|
        check_script_output(result: r, match: '^spec_db$')
      end
    end
  end

  describe 'charset and collate' do
    let(:pp) do
      <<-EOS
        mysql_database { 'spec_latin1':
          charset => 'latin1',
          collate => 'latin1_swedish_ci',
        }
        mysql_database { 'spec_utf8':
          charset => 'utf8',
          collate => 'utf8_general_ci',
        }
      EOS
    end

    it 'creates two db of different types idempotently' do
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'finds latin1 db' do
      shell("mysql -NBe \"SHOW VARIABLES LIKE '%_database'\" spec_latin1") do |r|
        expect(r.stderr).to be_empty
        check_script_output(result: r, match: '^character_set_database\tlatin1\ncollation_database\tlatin1_swedish_ci$')
      end
    end

    it 'finds utf8 db' do
      shell("mysql -NBe \"SHOW VARIABLES LIKE '%_database'\" spec_utf8") do |r|
        expect(r.stderr).to be_empty
        check_script_output(result: r, match: '^character_set_database\tutf8\ncollation_database\tutf8_general_ci$')
      end
    end
  end
end

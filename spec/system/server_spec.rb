describe 'mysql::server class' do
  before :all do
    pp = <<-EOS
      class { 'mysql': package_ensure => absent, }
      class { 'mysql::server': package_ensure => absent, }
    EOS
    puppet_apply(pp)
  end
  describe 'running puppet code' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOS
        class { 'mysql': }
        class { 'mysql::server': }
      EOS

      # Run it twice and test for idempotency
      puppet_apply(pp) do |r|
        r.exit_code.should_not == 1
        r.refresh
        r.exit_code.should be_zero
      end
    end
  end

  describe package('mysql-server') do
    it { should be_installed }
  end

  describe service('mysqld') do
    it { should be_running }
    it { should be_enabled }
  end
end

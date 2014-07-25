describe 'mysql::client' do
  fail ArgumentError, "Puppet facts missing" if Dir["spec/fixtures/modules/puppet_facts/PE3.3/*"].empty?
  Dir["spec/fixtures/modules/puppet_facts/PE3.3/*"].each do |facts|
    platform_name = facts.gsub(/\.facts/, '')
    describe "on #{platform_name}" do
      hash = {}
      File.read(facts).each_line do |line|
        key, value = line.split(' => ')
        hash[key.to_sym] = value.chomp unless value.nil?
      end
      let(:facts) { hash }

      context 'with defaults' do
        it { should_not contain_class('mysql::bindings') }
        it { should contain_package('mysql_client') }
      end

      context 'with bindings enabled' do
        let(:params) {{ :bindings_enable => true }}

        it { should contain_class('mysql::bindings') }
        it { should contain_package('mysql_client') }
      end
    end
  end

end

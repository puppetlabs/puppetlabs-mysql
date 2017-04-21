require 'spec_helper'

describe Facter::Util::Fact do
  before do
    Facter.clear
    Facter.stubs(:value).with(:kernel).returns('SunOS')
    Facter.stubs(:value).with('os').returns(
      {"name"=>"Solaris", "family"=>"Solaris", "release"=>{"major"=>"12",
      "minor"=>"0", "full"=>"12.0"}}
     )
    # Stubbed osfamily fails without stubbed 'os'
    Facter.stubs(:value).with(:osfamily).returns('Solaris')

    # Stub facts we don't use that are now invoked somewhere
    [:ec2_metadata, :hardwareisa, :processors ].each do |fact|
      Facter.stubs(:value).with(fact)
    end
  end
  context 'solaris' do
    before do
      Facter::Util::Resolution.stubs(:exec).
        with('pkg mediator -H mysql').
        returns('mysql        local     5.7     system')
    end
    context 'with mediator' do
      context 'major_dot_minor' do
        it {
          expect(Facter.fact(:mysql_solaris).value['major_dot_minor']).to eq('5.7')
        }
      end
      context 'basedir' do
        it {
          expect(Facter.fact(:mysql_solaris).value['basedir']).to eq('/usr/mysql/5.7')
        }
      end
      context 'major_minor' do
        it {
          expect(Facter.fact(:mysql_solaris).value['major_minor']).to eq('57')
        }
      end
    end
    context 'without mediator' do
      before do
        Facter::Util::Resolution.stubs(:exec).
          with('pkg mediator -H mysql').
          returns(nil)
      end
      context 'major_dot_minor' do
        it {
          expect(Facter.fact(:mysql_solaris).value['major_dot_minor']).to eq('5.5')
        }
      end
      context 'basedir' do
        it {
          expect(Facter.fact(:mysql_solaris).value['basedir']).to eq('/usr/mysql/5.5')
        }
      end
      context 'major_minor' do
        it {
          expect(Facter.fact(:mysql_solaris).value['major_minor']).to eq('55')
        }
      end
    end
  end
end

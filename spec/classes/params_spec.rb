require 'spec_helper'
describe 'sslmgmt::params' do

  context 'with defaults' do
    it { is_expected.to contain_class('sslmgmt::params') }
  end
end

# vim: ts=2 sw=2 sts=2 et :

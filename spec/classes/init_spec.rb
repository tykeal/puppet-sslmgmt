require 'spec_helper'

describe 'sslmgmt', :type => :class do
  context 'with defaults for all parameters' do
    it { is_expected.to contain_class('sslmgmt') }
  end
end

# vim: sw=2 ts=2 sts=2 et :

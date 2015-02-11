require 'spec_helper'

describe 'sslmgmt::cert', :type => :define do
  let(:title) { 'test_certificate' }

  context 'no params set' do
    it 'should fail if no pkistore configured' do
      expect { subject }.to raise_error(Puppet::Error,
                                        /Must pass pkistore/)
    end
  end

  context 'with default params set' do
    let(:params) {
      {
        'pkistore' => 'default'
      }
    }

    it 'should report error on bad pkistore' do
      params.merge!({'pkistore' => 'badvalue'})
      expect { subject }.to raise_error(Puppet::Error,
                                        /pkistore must be either custom or a value from params/)
    end

    it 'should report error on bad ensure' do
      params.merge!({'ensure' => 'badvalue'})
      expect { subject }.to raise_error(Puppet::Error,
                                        /ensure must be one of true, false, 'present', or 'absent'/)
    end
  end

  context 'with custom pkistore' do
    let(:params) {
      {
        'pkistore' => 'custom'
      }
    }

    it 'should fail when customstore is not defined or a hash' do
      expect { subject }.to raise_error(Puppet::Error,
                                        /is not a Hash/)
    end
  end
end

# vim: sw=2 ts=2 sts=2 et :

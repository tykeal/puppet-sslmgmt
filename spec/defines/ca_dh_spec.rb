require 'spec_helper'

describe 'sslmgmt::ca_dh', :type => :define do
  let(:title) { 'testca' }
  let(:params) {
    {
      'pkistore' => 'default'
    }
  }

  context 'no params set' do
    let(:params) {{}}

    it 'should fail if no pkistore configured' do
      expect { should compile }.to raise_error(RSpec::Expectations::ExpectationNotMetError,
              /Must pass pkistore/)
    end
  end

  context 'with default params set' do
    it 'should report error on bad pkistore' do
      params.merge!({'pkistore' => 'badvalue'})
      expect { should compile }.to raise_error(RSpec::Expectations::ExpectationNotMetError,
              /pkistore must be either custom or a value from params/)
    end

    it 'should report error on bad ensure' do
      params.merge!({'ensure' => 'badvalue'})
      expect { should compile }.to raise_error(RSpec::Expectations::ExpectationNotMetError,
              /ensure must be one of 'present', or 'absent'/)
    end

    it { is_expected.to contain_file(
      '/etc/pki/tls/certs/testca.pem').with(
      'ensure'  => 'file',
      'mode'    => '0644',
      'owner'   => 'root',
      'group'   => 'root',
      'content' => "This is a test\ncacert\n",
    ) }
  end

  context 'with custom pkistore' do
    let(:params) {
      {
        'pkistore'        => 'custom',
        'customstore'     => {
          'certfilename'  => '/random/filepath/customfile.pem',
          'keyfilename'   => '/random/filepath/customkey.pem',
          'owner'         => 'randomowner',
          'group'         => 'randomgroup',
        },
      }
    }

    it 'should fail when customstore is not defined or a hash' do
      params.merge!({'customstore' => ''})
      expect { should compile }.to raise_error(RSpec::Expectations::ExpectationNotMetError,
              /is not a Hash/)
    end

    it { is_expected.to contain_file(
        '/random/filepath/customfile.pem').with(
          'owner'   => 'randomowner',
          'mode'    => '0644',
          'group'   => 'randomgroup',
          'content' => "This is a test\ncacert\n",
    ) }
  end

  context 'missing title in sslmgmt::ca hiera' do
    let(:title) { 'bad_certificate' }

    it 'should fail because of missing ca certificate' do
      expect { should compile }.to raise_error(RSpec::Expectations::ExpectationNotMetError,
              /please ensure that bad_certificate exists in hiera sslmgmt::ca/)
    end
  end
end

# vim: sw=2 ts=2 sts=2 et :

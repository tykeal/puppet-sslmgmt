require 'spec_helper'

describe 'sslmgmt::cert', :type => :define do
  let(:title) { 'test_certificate' }
  let(:params) {
    {
      'pkistore' => 'default'
    }
  }

  context 'no params set' do
    let(:params) {{}}

    it 'should fail if no pkistore configured' do
#      expect { should compile }.to raise_error(Puppet::Error,
#                                        /Must pass pkistore/)
      expect { should compile }
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

    it 'should report error on bad installkey' do
      params.merge!({'installkey' => 'badvalue'})
      expect { should compile }.to raise_error(RSpec::Expectations::ExpectationNotMetError,
              /"badvalue" is not a boolean/)
    end

    it 'should report error on bad onefile' do
      params.merge!({'onefile' => 'badvalue'})
      expect { should compile }.to raise_error(RSpec::Expectations::ExpectationNotMetError,
              /"badvalue" is not a boolean/)
    end

    it { is_expected.to contain_file(
          '/etc/pki/tls/certs/test_certificate.pem').with(
          'ensure'  => 'file',
          'mode'    => '0644',
          'owner'   => 'root',
          'group'   => 'root',
          'content' => "This is a test cert for\ntestcert\n",
    ) }

    it { is_expected.to contain_file(
          '/etc/pki/tls/private/test_certificate.pem').with(
          'ensure'  => 'file',
          'mode'    => '0600',
          'owner'   => 'root',
          'group'   => 'root',
          'content' => "This is the key for\ntestcert\n",
    ) }

    it 'should have a combined key and certificate file if onefile is set' do
      params.merge!({'onefile' => true})
      is_expected.to contain_file(
          '/etc/pki/tls/private/test_certificate.pem').with(
          'mode'    => '0600',
          'owner'   => 'root',
          'group'   => 'root',
          'content' => "This is the key for\ntestcert\nThis is a test cert for\ntestcert\n"
        )
    end

    it 'should not write a key if installkey is false' do
      params.merge!({'installkey' => false})
      is_expected.not_to contain_file(
          '/etc/pki/tls/private/test_certificate.pem')
    end
  end

  context 'with a chain set' do
    let(:params) {
      {
        'chain'     => 'testca',
        'pkistore'  => 'default'
      }
    }

    it { is_expected.to contain_file(
          '/etc/pki/tls/certs/test_certificate-testca.pem').with(
          'mode'    => '0644',
          'owner'   => 'root',
          'group'   => 'root',
          'content' => "This is a test cert for\ntestcert\nThis is a test\ncacert\n",
    ) }

    it 'should fail when requested chain does not exist' do
      params.merge!({'chain' => 'badchain'})
      expect { should compile }.to raise_error(RSpec::Expectations::ExpectationNotMetError,
              /please ensure that badchain exists in hiera sslmgmt::ca/)
    end
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
          'content' => "This is a test cert for\ntestcert\n",
    ) }

    it { is_expected.to contain_file(
        '/random/filepath/customkey.pem').with(
          'owner'   => 'randomowner',
          'mode'    => '0600',
          'group'   => 'randomgroup',
          'content' => "This is the key for\ntestcert\n",
    ) }
  end

  context 'missing title in sslmgmt::certs hiera' do
    let(:title) { 'bad_certificate' }

    it 'should fail because of missing certificate' do
      expect { should compile }.to raise_error(RSpec::Expectations::ExpectationNotMetError,
        /please ensure that bad_certificate exists in hiera sslmgmt::certs/)
    end
  end

  context 'hash missing cert' do
    let(:title) { 'missing_cert' }

    it 'should fail because the hash does not have a cert value in sslmgt::certs' do
      expect { should compile }.to raise_error(RSpec::Expectations::ExpectationNotMetError,
              /certificate missing_cert does not have a 'cert' value/)
    end
  end

  context 'hash missing key' do
    let(:title) { 'missing_key' }

    it 'should fail because the has does not have a key value in sslmgt::certs' do
      expect { should compile }.to raise_error(RSpec::Expectations::ExpectationNotMetError,
              /certificate missing_key does not have a 'key' value/)
    end
  end

  context 'non-hash cert' do
    let(:title) { 'test_no_hash' }

    it 'should fail because of not having a hash in sslmgmt::certs' do
      expect { should compile }.to raise_error(RSpec::Expectations::ExpectationNotMetError,
              /is not a Hash/)
    end
  end
end

# vim: sw=2 ts=2 sts=2 et :

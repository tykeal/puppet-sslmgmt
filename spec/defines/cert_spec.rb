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
      expect { subject }.to raise_error(Puppet::Error,
                                        /Must pass pkistore/)
    end
  end

  context 'with default params set' do
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

    it { is_expected.to contain_file(
          '/etc/pki/tls/certs/test_certificate.pem').with(
          'mode'    => '0644',
          'owner'   => 'root',
          'group'   => 'root',
          'content' => "This is a test cert for\ntestcert\n",
    ) }
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
      expect { subject }.to raise_error(Puppet::Error,
              /please ensure that badchain exists in hiera sslmgmt::ca/)
    end
  end

  context 'with custom pkistore' do
    let(:params) {
      {
        'pkistore'    => 'custom',
        'customstore' => {
          'filename'  => '/random/filepath/customfile.pem',
          'owner'     => 'randomowner',
        },
      }
    }

    it 'should fail when customstore is not defined or a hash' do
      params.merge!({'customstore' => ''})
      expect { subject }.to raise_error(Puppet::Error, /is not a Hash/)
    end

    it { is_expected.to contain_file(
        '/random/filepath/customfile.pem').with(
          'owner'   => 'randomowner',
          'mode'    => '0644',
          'group'   => 'root',
          'content' => "This is a test cert for\ntestcert\n",
    ) }
  end

  context 'missing title in sslmgmt::certs hiera' do
    let(:title) { 'bad_certificate' }

    it 'should fail because of missing certificate' do
      expect { subject }.to raise_error(Puppet::Error,
        /please ensure that bad_certificate exists in hiera sslmgmt::certs/)
    end
  end

  context 'hash missing cert' do
    let(:title) { 'missing_cert' }

    it 'should fail because the hash does not have a cert value in sslmgt::certs' do
      expect { subject }.to raise_error(Puppet::Error,
              /certificate missing_cert does not have a 'cert' value/)
    end
  end

  context 'non-hash cert' do
    let(:title) { 'test_no_hash' }

    it 'should fail because of not having a hash in sslmgmt::certs' do
      expect { subject }.to raise_error(Puppet::Error, /is not a Hash/)
    end
  end
end

# vim: sw=2 ts=2 sts=2 et :

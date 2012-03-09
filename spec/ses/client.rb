require File.expand_path('../../helper', __FILE__)

describe 'SES::Client' do
  after do
    SES::Client::OPTIONS[:access_key] = nil
    SES::Client::OPTIONS[:secret_key] = nil
  end

  it 'Verify the access and secret keys' do
    should.raise SES::Error do
      SES::Client.verify_keys
    end

    SES::Client::OPTIONS[:access_key] = 'access'

    should.raise SES::Error do
      SES::Client.verify_keys
    end

    SES::Client::OPTIONS[:secret_key] = 'secret'

    should.not.raise SES::Error do
      SES::Client.verify_keys
    end
  end

  it 'Generate a signature for a given time' do
    SES::Client::OPTIONS[:access_key] = 'access'
    SES::Client::OPTIONS[:secret_key] = 'secret'

    time = Time.new.strftime('%a, %d %b %Y %H:%M:%S GMT')
    hash = OpenSSL::HMAC.digest(
      OpenSSL::Digest::Digest.new('sha256'),
      'secret',
      time
    )

    hash = Base64.encode64(hash).chomp
    got  = SES::Client.signature(time)

    got.should == "AWS3-HTTPS AWSAccessKey=access, Signature=#{hash}, " \
      "Algorithm=HmacSHA256"
  end
end

require File.expand_path('../../helper', __FILE__)

describe 'SES::Email' do
  extend WebMock::API

  after do
    SES::Email::OPTIONS[:sender]      = nil
    SES::Email::OPTIONS[:sender_name] = nil
  end

  it 'Create a new instance of SES::Email and set the various parameters' do
    email = SES::Email.new(
      :from    => 'user@example.com',
      :name    => 'User',
      :to      => 'user1@example.com',
      :subject => 'Example',
      :body    => 'This is the body',
      :html    => true
    )

    email.from.should    == 'user@example.com'
    email.name.should    == 'User'
    email.to.should      == 'user1@example.com'
    email.subject.should == 'Example'
    email.body.should    == 'This is the body'
    email.html.should    == true
  end

  it 'Use the default sender and sender name if these are not manually given' do
    SES::Email::OPTIONS[:sender]      = 'user@example.com'
    SES::Email::OPTIONS[:sender_name] = 'User'

    email = SES::Email.new(
      :to      => 'user1@example.com',
      :subject => 'Example',
      :body    => 'This is the body',
      :html    => true
    )

    email.from.should    == 'user@example.com'
    email.name.should    == 'User'
    email.to.should      == 'user1@example.com'
    email.subject.should == 'Example'
    email.body.should    == 'This is the body'
    email.html.should    == true
  end

  it 'Raise when no sender Email is specified' do
    should.raise SES::ValidationError do
      SES::Email.new.deliver
    end

    should.raise SES::ValidationError do
      SES::Email.new(:from => 'foo@bar.com').deliver
    end

    # :to can only be an array or a string.
    should.raise SES::ValidationError do
      SES::Email.new(:from => 'foo@bar.com', :to => 10).deliver
    end
  end

  it 'Send a valid Email' do
    SES::Client::OPTIONS[:access_key] = 'access'
    SES::Client::OPTIONS[:secret_key] = 'secret'

    email = SES::Email.new(
      :from    => 'user@example.com',
      :name    => 'User',
      :to      => 'user1@example.com',
      :subject => 'Example',
      :body    => 'This is the body',
      :html    => true
    )

    message_id    = '00000131d51d2292-159ad6eb-077c-46e6-ad09-ae7c05925ed4-000000'
    response_body = <<-XML.strip
<SendEmailResponse xmlns="http://ses.amazonaws.com/doc/2010-12-01/">
  <SendEmailResult>
    <MessageId>#{message_id}</MessageId>
  </SendEmailResult>
  <ResponseMetadata>
    <RequestId>d5964849-c866-11e0-9beb-01a62d68c57f</RequestId>
  </ResponseMetadata>
</SendEmailResponse>
    XML

    stub_request(:post, 'https://email.us-east-1.amazonaws.com') \
      .to_return(:status => 200, :body => response_body)

    email.deliver.should == message_id
  end

  it 'Send an invalid Email' do
    SES::Client::OPTIONS[:access_key] = 'access'
    SES::Client::OPTIONS[:secret_key] = 'secret'

    email = SES::Email.new(
      :from    => 'user@example.com',
      :name    => 'User',
      :to      => 'user1@example.com',
      :subject => 'Example',
      :body    => 'This is the body',
      :html    => true
    )

    response_body = <<-XML.strip
<ErrorResponse xmlns="http://ses.amazonaws.com/doc/2010-12-01/">
  <Error>
    <Message>Something went wrong</Message>
  </Error>
</ErrorResponse>
    XML

    stub_request(:post, 'https://email.us-east-1.amazonaws.com') \
      .to_return(:status => 400, :body => response_body)

    should.raise SES::Error do
      email.deliver
    end

    begin
      email.deliver
    rescue => e
      e.message.should == 'Failed to send the Email: Something went wrong'
    end
  end
end

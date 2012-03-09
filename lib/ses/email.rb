module SES
  ##
  # Class used for creating and sending Emails.
  #
  # In order to create a new Email you call {SES::Email.new} and provide a hash
  # containing parameters such as the sender's Email, subject, etc:
  #
  #     mail = SES::Email.new(
  #       :from    => 'user@example.com',
  #       :to      => 'anotheruser@example.com',
  #       :subject => 'Testing',
  #       :body    => 'This is the Email body.'
  #     )
  #
  # Once the mail object has been created you can send it by calling
  # {SES::Email#deliver}:
  #
  #     mail.deliver
  #
  # Upon success the return value is set to the message ID of the newly created
  # Email, upon any failure an instance of {SES::Error} is raised so be sure to
  # properly wrap calls to {SES::Email#deliver} in a begin/rescue block:
  #
  #     begin
  #       mail.deliver
  #     rescue SES::Error => e
  #       # Do something with the error.
  #     end
  #
  # ## Default Sender Details
  #
  # To make it easier to send Emails you can set the default sender Email and
  # name in the hash {SES::Email::OPTIONS}. These options can be set as
  # following:
  #
  #     SES::Email::OPTIONS[:sender]      = 'user@example.com'
  #     SES::Email::OPTIONS[:sender_name] = 'User'
  #
  # Once set these values will be used whenever there are no custom values
  # specified for the sender Email/name.
  #
  # @since 24-01-2012
  #
  class Email
    # Hash containing various configuration options.
    OPTIONS = {
      # The default sender Email to use.
      :sender => '',

      # The default name of the sender.
      :sender_name => ''
    }

    # The Email address of the sender.
    attr_accessor :from

    # The full name of the sender.
    attr_accessor :name

    # A list of addresses to send the Email to. If a string is given the Email
    # is only sent to that particular address, if an array is given the Email
    # will be sent to all the specified addresses.
    attr_accessor :to

    # String containing the subject of the Email.
    attr_accessor :subject

    # String containing the body of the Email.
    attr_accessor :body

    # When set to true the Email will be sent as an HTML email. Set to
    # ``false`` by default.
    attr_accessor :html

    # The character set to use for the subject and body. The character set is
    # set to UTF-8 by default.
    attr_accessor :charset

    ##
    # Creates a new instance of the class and sets the specified attributes
    # such as the sender's Email and subject.
    #
    # @example
    #  email = SES::Email.new(
    #    :from    => 'user@example.com',
    #    :name    => 'Example User',
    #    :to      => 'another_user@example.com',
    #    :subject => 'Testing',
    #    :body    => 'This is a test Email.'
    #  )
    #
    # @since 24-01-2012
    # @param [Hash] options A hash containing the attributes to set. See the
    #  corresponding getters/setters for their descriptions.
    # @option options [String] :from The Email of the sender.
    # @option options [String] :name The name of the sender.
    # @option options [String|Array] :to A string containing a single Email
    #  address to send the Email to or an array of multiple Email addresses.
    # @option options [String] :subject The subject of the Email.
    # @option options [String] :body The body of the Email.
    # @option options [String] :html When set to ``true`` the Email will be
    #  sent as an HTML Email.
    # @option options [String] :charset The character set to use for the Email,
    #  set to UTF-8 by default.
    #
    def initialize(options = {})
      @from    = options[:from] || OPTIONS[:sender]
      @name    = options[:name] || OPTIONS[:sender_name]
      @to      = options[:to]
      @subject = options[:subject]
      @body    = options[:body]
      @html    = options[:html]    || false
      @charset = options[:charset] || 'UTF-8'
    end

    ##
    # Sends the Email and returns the message ID.
    #
    # @example
    #  email = SES::Email.new(...)
    #  id    = email.deliver
    #
    #  puts id # => "0000013511a87590-......."
    #
    # @since  24-01-2012
    # @return [String]
    # @raise  [SES::Error] Raised whenever the Email could not be
    #  sent.
    #
    def deliver
      validate

      if @name.nil?
        from = @from
      else
        from = "#{@name} <#{@from}>"
      end

      options = {
        :Action                    => 'SendEmail',
        :Source                    => from,
        :'Message.Subject.Data'    => @subject,
        :'Message.Subject.Charset' => @charset
      }

      if @html == true
        options[:'Message.Body.Html.Data']    = @body
        options[:'Message.Body.Html.Charset'] = @charset
      else
        options[:'Message.Body.Text.Data']    = @body
        options[:'Message.Body.Text.Charset'] = @charset
      end

      if @to.is_a?(Array)
        num = 1

        @to.each do |value, index|
          if !value.nil? and !value.empty?
            options[:"Destination.toAddresses.member.#{num}"] = value

            num += 1
          end
        end
      else
        options[:'Destination.ToAddresses.member.1'] = @to
      end

      response = SES::Client.signed_post('/', options)
      parsed   = response.parsed_response

      # Bummer, something went wrong.
      if response.code != 200 and parsed.key?('ErrorResponse')
        message = parsed['ErrorResponse']['Error']['Message']

        raise(SES::Error, "Failed to send the Email: #{message}")

      # Everything is fine, get the mail ID.
      elsif response.code == 200 and parsed.key?('SendEmailResponse')
        return parsed['SendEmailResponse']['SendEmailResult']['MessageId']

      else
        raise(
          SES::Error,
          "Failed to extract the message ID, raw response: #{response.body}"
        )
      end
    end

    ##
    # Validates the attributes (such as the name and subject) and raises an
    # error if they're invalid.
    #
    # @since 24-01-2012
    # @raise [SES::ValidationError] raised whenever one of the set
    #  attributes is invalid.
    #
    def validate
      if @from.nil? or @from.empty?
        raise(
          SES::ValidationError,
          'You have to specify the from address'
        )
      end

      if !@to.is_a?(Array) and !@to.is_a?(String)
        raise(
          SES::ValidationError,
          "Expected an instance of Array or String for the to address but " \
            "got #{@to.class} instead"
        )
      end
    end
  end # Email
end # SES

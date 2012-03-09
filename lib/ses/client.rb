require 'httparty'
require 'openssl'
require 'base64'

module SES
  ##
  # Client for sending HTTP requests to the Amazon SES API using HTTParty.
  #
  # In order to be able to send Emails you'll have to specify an access key and
  # a secret key. These keys can be set as following:
  #
  #     SES::Client::OPTIONS[:access_key] = '...'
  #     SES::Client::OPTIONS[:secret_key] = '...'
  #
  # Once set you can start sending Emails using {SES::Email}.
  #
  # @since 24-01-2012
  #
  module Client
    include HTTParty

    format   :xml
    base_uri 'https://email.us-east-1.amazonaws.com'

    # Hash containing the configuration options required for each HTTP
    # request.
    OPTIONS = {
      # Your AWS access key.
      :access_key => nil,

      # Your AWS secret key.
      :secret_key => nil,

      # The version of the SES API.
      :version => '2010-12-01'
    }

    class << self
      ##
      # Executes a signed POST request.
      #
      # @example
      #  response = SES::Client.signed_post(
      #    :Action => 'SendEmail',
      #    :source => 'foo@bar.com',
      #    ...
      #  )
      #
      #  puts response.parsed_response
      #
      # @since 24-01-2012
      # @param [String] uri The URI relative to the base URL to send the request
      #  to.
      # @param [Hash] body A hash containing the various keys and values that
      #  have to used as POST fields.
      # @return [Mixed]
      #
      def signed_post(uri = '/', body = {})
        verify_keys

        time     = Time.now
        url_time = time.strftime('%Y-%m-%dT%H:%M:%S.000Z')
        sig_time = time.gmtime.strftime('%a, %d %b %Y %H:%M:%S GMT')

        body[:Timestamp]      = url_time
        body[:Version]        = OPTIONS[:version]
        body[:AWSAccessKeyId] = OPTIONS[:access_key]

        data = {
          :headers => {
            'X-Amzn-Authorization' => signature(sig_time),
            'Date'                 => sig_time
          },
          :body => body
        }

        return post(uri, data)
      end

      ##
      # Checks if the AWS access and secret key are set and raises an error if
      # this isn't the case.
      #
      # @since 24-01-2012
      # @raise [SES::Error] raised whenever one of the keys was
      #  missing.
      #
      def verify_keys
        [:access_key, :secret_key].each do |k|
          if OPTIONS[k].nil? or OPTIONS[k].empty?
            raise(
              SES::Error,
              "You have to specify a non empty value for the #{k} option" \
                " in SES::Client::OPTIONS"
            )
          end
        end
      end

      ##
      # Generates a signature to use for a single HTTP request.
      #
      # @since 24-01-2012
      # @param [String] time The signature time as a string in the format
      #  ``%a, %d %b %Y %H:%M:%S GMT``.
      # @return [String]
      #
      def signature(time)
        hash = OpenSSL::HMAC.digest(
          OpenSSL::Digest::Digest.new('sha256'),
          OPTIONS[:secret_key],
          time
        )

        hash = Base64.encode64(hash).chomp

        return "AWS3-HTTPS AWSAccessKey=#{OPTIONS[:access_key]}, " \
          "Signature=#{hash}, Algorithm=HmacSHA256"
      end
    end # class << self
  end # Client
end # SES

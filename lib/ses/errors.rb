module SES
  ##
  # Generic error class for the Amazon SES package.
  #
  # @since 24-01-2012
  #
  class Error < ::StandardError; end

  ##
  # Error class used by {SES::Email#validate}.
  #
  # @since 24-01-2012
  #
  class ValidationError < ::StandardError; end
end # SES

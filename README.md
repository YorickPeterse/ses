# SES

SES is a very simple and easy to use Gem for sending Emails using the Amazon SES
API. While there are already quite a few Gems out there for using this API most
of them had a dependency on the rather bloated "Mail" library. This particular
Gem aims to be as small as possible, comes with only HTTParty as a dependency
and doesn't do anything else besides sending Emails. The latter is a feature.

## Installation

    $ gem install ses

## Sending Emails

Load the gem:

    require 'ses'

Configure your access and secret keys:

    SES::Client::OPTIONS[:access_key] = 'example'
    SES::Client::OPTIONS[:secret_key] = 'example'

Create a new instance of ``SES::Email``:

    email = SES::Email.new(
      :from    => 'user@example.com',
      :to      => 'somebody@example.com',
      :subject => 'Testing',
      :body    => 'This is an example Email'
    )

And send it:

    email.deliver

## License

The code in this repository is licensed under the MIT license. A copy of this
license can be found in the file "LICENSE".

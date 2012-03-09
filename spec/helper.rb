require File.expand_path('../../lib/ses', __FILE__)
require 'bacon'
require 'webmock'

Bacon.extend(Bacon::TapOutput)
Bacon.summary_on_exit

WebMock.enable!

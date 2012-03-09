require File.expand_path('../lib/ses/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'ses'
  s.version     = SES::VERSION
  s.date        = '2012-03-09'
  s.authors     = ['Yorick Peterse']
  s.email       = 'yorickpeterse@gmail.com'
  s.summary     = 'A small and easy to use Gem for Amazon SES.'
  s.homepage    = 'https://github.com/yorickpeterse/ses'
  s.description = s.summary
  s.files       = `git ls-files`.split("\n").sort
  s.has_rdoc    = 'yard'

  s.add_dependency 'httparty', ['>= 0.8.1']

  s.add_development_dependency 'rake' , ['>= 0.9.2']
  s.add_development_dependency 'yard' , ['>= 0.7.2']
  s.add_development_dependency 'bacon', ['>= 1.1.0']
  s.add_development_dependency 'rdiscount', ['>= 1.6.8']
end

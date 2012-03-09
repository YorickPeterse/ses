namespace :build do
  desc 'Builds a new Gem'
  task :gem do
    gemspec = Gem::Specification.load(
      File.expand_path('../../ses.gemspec', __FILE__)
    )

    root = File.expand_path('../../', __FILE__)
    name = "#{gemspec.name}-#{gemspec.version.version}.gem"
    path = File.join(root, name)
    pkg  = File.join(root, 'pkg', name)

    # Build and install the gem
    sh('gem', 'build', File.join(root, 'ses.gemspec'))
    sh('mv' , path, pkg)
    sh('gem', 'install', pkg)
  end
end

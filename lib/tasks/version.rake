# http://semver.org/
# http://stackoverflow.com/a/11787127
task :version do
  desc "Updates VERSION. Use MAJOR_VERSION, MINOR_VERSION, PATCH_VERSION, BUILD_VERSION to override defaults"

  version_file = "#{Rails.root}/config/initializers/version.rb"
  major = ENV["MAJOR_VERSION"] || 2
  minor = ENV["MINOR_VERSION"] || 0
  patch = ENV["PATCH_VERSION"] || 0
  build = ENV["BUILD_VERSION"] || `git describe --always`
  version_string = "VERSION = #{[major.to_s, minor.to_s, patch.to_s, build.strip]}\n"
  File.open(version_file, "w") {|f| f.print(version_string)}
  $stderr.print(version_string)
end

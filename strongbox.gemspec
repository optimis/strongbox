Gem::Specification.new do |s|
  s.name        = "strongbox"
  s.version     = "0.4.0"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Spike Ilacqua", "Clark Snowdall", "Ehren Murdick"]
  s.email       = ["csnowdall@optimis.com", "ehren.murdick@gmail.com"]
  s.homepage    = "http://github.com/optimis/strongbox"
  s.summary     = ""
  s.description = ""
 
  s.required_rubygems_version = ">= 1.3.5"
 
 
  s.files        = Dir.glob("{bin,lib}/**/*") + %w(LICENSE README.md ROADMAP.md CHANGELOG.md)
  s.executables  = ['bundle']
  s.require_path = 'lib'
end


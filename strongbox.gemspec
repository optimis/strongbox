Gem::Specification.new do |s|
  s.name        = "strongbox"
  s.version     = "0.4.2"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Spike Ilacqua", "Clark Snowdall", "Ehren Murdick"]
  s.email       = ["csnowdall@optimis.com", "ehren.murdick@gmail.com"]
  s.homepage    = "http://github.com/optimis/strongbox"
  s.summary     = "Encryption extension for rails"
  s.description = "Asymetric encryption for AR columns, including remote decryption services"

  s.add_dependency "rest-client", ">=1.5.0"
  s.add_dependency "paperclip",   ">=2.3.3"
 
  s.required_rubygems_version = ">= 1.3.5"
 
 
  s.files        = Dir.glob("{bin,lib,test,rails}/**/*") + %w(README.textile LICENSE Rakefile)
  s.require_path = 'lib'
end


# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "server"
  spec.version       = "1.0"
  spec.authors       = ["Praveen Rudraraju"]
  spec.summary       = %q{Short Summary}
  spec.description   = %q{Longer Description}
  spec.homepage      = "http://domain.com/"
  spec.license       = "MIT"

  spec.files         = Dir["{lib}/**/*.rb"]
  spec.executables   = ['server','stop_server']
  spec.require_paths = ['lib'] 
end

lib = File.expand_path('../server', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'routes'
require 'daemonized_server'
require 'application_server'


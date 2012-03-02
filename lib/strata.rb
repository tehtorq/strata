require "strata/version"
require "active_support/core_ext/string"
require "yaml"

module Strata
  CONFIG_DIR = File.expand_path(File.dirname(__FILE__)) + "/config"
end

require 'strata/helpers'

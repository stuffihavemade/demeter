require "rubygems"
require "spec"
require "benchmark"
require "active_record"

# Load library
$LOAD_PATH.unshift File.dirname(__FILE__) + "/../lib"
require "demeter"

# Establish connection with in memory SQLite 3 database
ActiveRecord::Base.establish_connection :adapter => "sqlite3", :database => ":memory:"

# Load database schema
load File.dirname(__FILE__) + "/schema.rb"

# Load resources
require File.dirname(__FILE__) + "/resources/classes"
require File.dirname(__FILE__) + "/resources/models"

# Create an alias for lambda
alias :doing :lambda

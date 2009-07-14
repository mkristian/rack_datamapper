require 'pathname'
require 'extlib/pathname'
require 'dm-core'

require Pathname(__FILE__).dirname / 'rack_datamapper' / 'version'
require Pathname(__FILE__).dirname / 'rack_datamapper' / 'identity_maps'
require Pathname(__FILE__).dirname / 'rack_datamapper' / 'restful_transactions'
require Pathname(__FILE__).dirname / 'rack_datamapper' / 'transaction_boundaries'
require Pathname(__FILE__).dirname / 'rack_datamapper' / 'session' / 'datamapper'

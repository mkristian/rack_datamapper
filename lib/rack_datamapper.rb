require 'dm-core'

base = File.join(File.dirname(__FILE__),'rack_datamapper')
require File.join(base, 'version')
require File.join(base, 'identity_maps')
require File.join(base, 'restful_transactions')
require File.join(base, 'transaction_boundaries')
require File.join(base, 'session', 'datamapper')

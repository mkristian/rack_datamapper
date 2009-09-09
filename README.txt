= rack_datamapper

* http://github.com/mkristian/rack_datamapper

* http://rack-datamapper.rubyforge.org

== DESCRIPTION:

this collection of plugins helps to add datamapper functionality to Rack. there is a IdentityMaps plugin which wrappes the request and with it all database actions are using that identity map. the transaction related plugin TransactionBoundaries and RestfulTransactions wrappes the request into a transaction. for using datamapper to store session data there is the DatamapperStore.

=== DataMapper::Session::Abstract::Store

this is actual store class which can be wrapped to be used in a specific environement, i.e. Rack::Session::Datamapper. this store can the same options as the session store from rack, see

* http://rack.rubyforge.org/doc/Rack/Session/Pool.html

* http://rack.rubyforge.org/doc/Rack/Session/Abstract/ID.html

there are two more options

* :session_class - (optional) must be a DataMapper::Resource with session_id, data properties.

* :cache - Boolean (default: false) if set to true the store will first try to retrieve the session from a memory cache otherwise fallback to the session_class resource. in case the platform is java (jruby) the cache uses SoftReferences which clears the cache on severe memory shortage, but it needs java 1.5 or higher for this.

== Rack Middleware

all these middleware take the name of the datamapper repository (which you configure via DataMapper.setup(:name, ....) as second constructor argument (default is :default)

=== DataMapper::RestfulTransactions

wrappers the request inside an transaction for POST,PUT,DELETE methods

=== DataMapper::TransactionBoundaries

wrappers the all request inside an transaction

=== DataMapper::IdentityMaps

wrappers the all request inside an identity scope


== LICENSE:

(The MIT License)

Copyright (c) 2009 Kristian Meier

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

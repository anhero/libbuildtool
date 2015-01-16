Contributor's guide
===================

Quick notes
-----------

 | |
--------------------------|----------------------------------------|
Programming language      | **[Ruby](https://www.ruby-lang.org/)** |
Documentation generation  | **[YARD](http://yardoc.org/)**         |
Unit tests                | **[RSpec](http://rspec.info/)**        |

Dependencies
------------

### Runtime dependencies

Currently, there are no runtime dependencies outside of the 1.9.1 stdlib of Ruby.
Unless necessary, we will try to make libbuildtool run properly with only the use
of the Ruby stdlib.


### Development dependencies

The rules are not as strict for development. The current dependencies are for
documentation generation (YARD) and for unit testing (RSpec).

Packaging notes
---------------

This project is not packaged as a ruby gem and does not currently intend to be
packaged as such since it is not oriented towards Ruby development and it does
not make use of gem dependencies. We are not against a contribution that would
make it packageable as a gem, as long as the current usage still works.

Testing
-------

This is currently a sore spot with libbuildtool; we have a pretty poor coverage
and the current unit testing suite does not work on the targeted lower Ruby
version with the tests as they are.


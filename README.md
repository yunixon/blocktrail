BlockTrail Ruby SDK
=====================
This is the BlockTrail Ruby SDK. This SDK contains methods for easily interacting with the BlockTrail API.

[![Gem Version](https://badge.fury.io/rb/blocktrail.png)](https://badge.fury.io/rb/blocktrail)

IMPORTANT! FLOATS ARE EVIL!!
----------------------------
As is best practice with financial data, The API returns all values as an integer, the Bitcoin value in Satoshi's.

The BlockTrail SDK has some easy to use functions to do this for you, we recommend using these
and we also **strongly** recommend doing all Bitcoin calculation and storing of data in integers
and only convert to/from Bitcoin float values for displaying it to the user.

Installation
------------
Add this line to your application's Gemfile:

```ruby
gem 'blocktrail'
```

Or install it yourself as:

```
$ gem install blocktrail
```

Usage
-----

To use the BlockTrail API, you need your API_KEY as well as a API_SECRET. The gem reads both values from the environment variables. Alternatively you can specify the values by configuring the `Blocktrail::Client` like this:

Please visit our official documentation at https://www.blocktrail.com/api/docs/ for the usage.

Support and Feedback
--------------------

If you find a bug, please submit the issue in Github directly.
[BlockTrail-Ruby-SDK Issues](https://github.com/yunixon/blocktrail/issues)

License
-------
The BlockTrail Ruby SDK is released under the terms of the MIT license. See LICENCE.md for more information or see http://opensource.org/licenses/MIT.

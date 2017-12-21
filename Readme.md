# Feralchimp

[![Build Status](https://travis-ci.org/envygeeks/feralchimp.png?branch=master)](https://travis-ci.org/envygeeks/feralchimp) [![Coverage Status](https://coveralls.io/repos/envygeeks/feralchimp/badge.png?branch=master)](https://coveralls.io/r/envygeeks/feralchimp) [![Code Climate](https://codeclimate.com/github/envygeeks/feralchimp.png)](https://codeclimate.com/github/envygeeks/feralchimp) [![Dependency Status](https://gemnasium.com/envygeeks/feralchimp.png)](https://gemnasium.com/envygeeks/feralchimp)

Feralchimp is a Ruby based API wrapper for the MailChimp API v2.0.

## Installation:
```sh
gem install feralchimp
```

```ruby
gem "feralchimp"
```

## Options:
* Feralchimp.api_key = Mailchimp key w/ region part.
* *You can also optionally set ENV["MAILCHIMP_API_KEY"] too*
* Feralchimp.timeout = *Defaults:* 5

There is one setter called `exportar` (Spanish for export) that is a public but private API method so that the class can communicate with the instance when a user chains using `export`.  This variable is always reset back to false each time `#call` is called. While it won't hurt anything if you play with it (such as setting it to true,) just be warned it's internal and it's state is always reset even if it's already false and setting it to any value but false or nil will just result in you hitting the Export API.

## Normal API Usage:

```ruby
Feralchimp.api_key = api_key
Feralchimp.new.lists #=> {}
Feralchimp.lists #=> {}

Feralchimp.new(:api_key => api_key).lists # => {}
```

Using the class creates a new instance each run but you also have the option to create your own persistant instance so you can control key state.  When creating a new instance you can send an optional api key which will be set for that instance only.

## Export API Usage:

```ruby
Feralchimp.new.export.list(:id => list_id) #=> [{}]
Feralchimp.export.list(:id => list_id) #=> [{}]

Feralchimp.new(:api_key => api_key).export.list(:id => list_id)
```

According to the Mailchimp spec it will send a plain text list of JSON arrays delimited by `\n`, with the first JSON array being the header (AKA the hash keys) keeping in line with this we actually parse this list for you, in that we take the first JSON array and zip it into an array, like so:

```ruby
# What Mailchimp gives us:
# ["header1", "header2"]
# ["array1_v1", "array1_v2"]
# ["array2_v1", "array2_v2"]

# What we give you:

[
  {"header1" => "array1_v1", "header2" => "array1_v2" }
  {"header1" => "array2_v1", "header2" => "array2_v2" }
]
```

This means that to work with the Export API you need do nothing more special than you already do because we handle all the hard work, if you can call it hard work considering it required very little extra code.

## API Payloads

```ruby
Feralchimp.new.list_members(:id => list_id)
Feralchimp.list_members(:id => list_id)
Feralchimp.new(:api_key => api_key).list_members(:id => list_id)
```

Feralchimp accepts a hash based payload.  This payload is not tracked by us and all we do is transform it and post it so if you would like to know more about what payloads you might need to send to Mailchimp please visit the [Mailchimp API docs](http://apidocs.mailchimp.com/api/2.0/).

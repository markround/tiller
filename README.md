# What is it?

Tiller is a tool that generates configuration files. It takes a set of templates, fills them in with values from a variety of sources (such as environment variables, Consul, YAML files, JSON from a webservice...), installs them in a specified location and then optionally spawns a child process.

You might find this particularly useful if you're using Docker, as you can ship a set of configuration files for different environments inside one container, and/or easily build "parameterized containers" which users can then configure at runtime. 

However, its use is not just limited to Docker; you may also find it useful as a sort of "proxy" that can provide values to application configuration files from a data source that the application does not natively support. 

It's available as a [Ruby Gem](https://rubygems.org/gems/tiller), so installation should be a simple `gem install tiller`.

[![Gem Version](https://badge.fury.io/rb/tiller.svg)](http://badge.fury.io/rb/tiller)
[![Build Status](https://travis-ci.org/markround/tiller.svg?branch=develop)](https://travis-ci.org/markround/tiller)
![](https://img.shields.io/gem/dt/tiller.svg)
 [![Join the chat at https://gitter.im/markround/tiller](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/markround/tiller)
[![Documentation Status](https://img.shields.io/badge/docs-latest-brightgreen.svg?style=flat)](http://tiller.readthedocs.io/en/latest/)


# Documentation
The main documentation has been updated and a searchable, easy to read version is now hosted on [readthedocs.io](http://tiller.readthedocs.io/). You can also read the raw markdown files by browsing the [docs](docs/) directory in this repository.

You may like to read the [Quickstart](http://tiller.readthedocs.io/en/latest/quickstart/) guide if you want a very quick overview.

There is also a [Gitter chatroom](https://gitter.im/markround/tiller) for you to ask any questions, suggest new features and talk to other users.

# Status

OK, real talk here. This project has more-or-less stalled. I hesitate to say "abandoned" because I still care about it, but I have to be honest with anyone who might be looking at using it. The thing is, my life has had a number of (positive!) changes recently such as becoming a Dad, which have led to my free project time being greatly reduced. 

Also, due to job changes and the changing technology landscape I now find myself involved in, I haven't actually used Tiller for several years. On top of that, I have realised that there are several fundamental issues with Tiller that I should tackle: Things like a re-write in Golang to avoid having to drag in a full Ruby/Gem environment for the runtime, and I also now believe that the top-level construct should be the file, and not the template that generates it. This would mean, for example, that having multiple files generated from the same template would be a very simple operation. The problem with all that is again lack of time, and the fact that I _really_ hate Go as a programming language.

So where does this leave the project ? Well, it _does_ work and has been battle-tested over many years. Some of the extra plugins such as Consul have badly stagnated however, and no longer work with current versions of libraries/APIs. If it works for you, then great! If you're looking for updates and a fancy Tiller 2.0 then I'm afraid you're going to be kept waiting. I'm not going to say "never" because I do still have a lot of love for this project; it was the first real open-source project I made that attracted a bunch of users, contributions and a small community around it which I'll always be thankful for. 

But I guess it's best for everyone if you consider it "done" and what you see is what you get. If anyone is interested in forking it and producing a "Tiller - The Next Generation" then by all means give me a shout and I'll update things with links and pointers to your project but I won't be transferring ownership/RubyGems.org ownership etc. in the interests of security.

Thanks again for everything, and stay safe out there.

-Mark Dastmalchi-Round, August 2020
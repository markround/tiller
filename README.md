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

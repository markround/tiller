require 'tiller/templatesource'
require 'tiller/datasource'

def loader(type,sources)
  case type.to_s
    when 'Tiller::DataSource'
      source_path = 'tiller/data'
    when 'Tiller::TemplateSource'
      source_path = 'tiller/template'
    else
      raise "Unsupported by loader : #{type}"
  end

  # This looks a little counter-intuitive, but it's for a reason.
  # We load things this way so that we get an array that contains all the
  # classes loaded, *in the order specified in common.yaml*
  # This is very important, as it means we can specify the defaults DataSource
  # first, for example and then let later DataSources override values from it.
  # Otherwise, iterating through the available classes results in them being
  # returned in no particular useful order.

  classes = []
  sources.each do |s|
    require File.join(source_path,"#{s}.rb")
    classes |= type.subclasses
  end

  classes
end


def helper_loader(helpers)
  source_path = 'tiller/helper'
  loaded = []

  helpers.each do |h|
    require File.join(source_path,"#{h}.rb")
    loaded.push(h)
  end

  loaded
end
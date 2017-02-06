module Tiller
  def self.render(template, options={})

    # This is used for rendering content in dynamic configuration files
    if options.has_key?(:direct_render)
      content = template
      ns = OpenStruct.new(Tiller::tiller)
      return ERB.new(content, nil, '-').result(ns.instance_eval { binding })
    end

    if Tiller::templates.key?(template)
      content = Tiller::templates[template]
      ns = OpenStruct.new(Tiller::tiller)
      ERB.new(content, nil, '-').result(ns.instance_eval { binding })
    else
      Tiller::log.warn("Warning : Requested render of non-existant template #{template}")
      ""
    end
  end
end
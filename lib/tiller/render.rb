module Tiller
  def self.render(template, options={})

    # This is only ever used when we parse top-level values for ERb syntax, we pass in each
    # datasource's global_values as a distinct namespace
    if options.has_key?(:namespace)
      b = binding
      ns =  options[:namespace]
      ns.each { |k, v| b.local_variable_set(k, v) }
      return ERB.new(template, nil, trim_mode: '-').result(ns.instance_eval { b })
    end

    ns = OpenStruct.new(Tiller::tiller)

    # This is used for rendering content in dynamic configuration files
    if options.has_key?(:direct_render)
      content = template
      return ERB.new(content, nil, trim_mode: '-').result(ns.instance_eval { binding })
    end

    if Tiller::templates.key?(template)
      content = Tiller::templates[template]
      ERB.new(content, nil, trim_mode: '-').result(ns.instance_eval { binding })
    else
      Tiller::log.warn("Warning : Requested render of non-existent template #{template}")
      ""
    end
  end

end

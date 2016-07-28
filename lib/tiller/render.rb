module Tiller
  def self.render(template)
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
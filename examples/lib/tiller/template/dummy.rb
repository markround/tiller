# This is another quick example of how to create a template source.
class DummyTemplateSource < Tiller::TemplateSource
  # Just provide a single dummy template
  def templates
    ['dummy.erb']
  end

  # And return some sample ERB content.
  # Note that as you have the environment name in the @config hash, you can
  # always return different templates for different environments.
  def template(_template_name)
    "This is a dummy template! <%= dummy %> \n "\
    'Here is a global value <%= dummy_global %>'
  end
end

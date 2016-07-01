class FileTemplateSource < Tiller::TemplateSource
  def initialize(config)
    super
    @template_dir = File.join(@config[:tiller_base], 'templates/')
  end

  # Simply return a list of all the templates in the $tiller_base/templates
  # directory with the preceeding directory path stripped off
  def templates
    Dir.glob(File.join(@template_dir, '**', '*.erb')).each do |t|
      t.sub!(@template_dir, '')
    end
  end

  # Just open and return the file
  def template(template_name)
    open(File.join(@template_dir, template_name)).read
  end
end

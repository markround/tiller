require 'crack'

# This datasource reads an XML file (xml_file_path), parses it using the crack gem and then
# Makes it available to templates as a named structure (xml_file_var).

class XmlFileDataSource < Tiller::DataSource

  def global_values
    parse_xml(@config)
  end

  def values(template)
    parse_xml(@config['environments'][@config[:environment]][template])
  end

  def parse_xml(config_hash)
    if config_hash.has_key?('xml_file_path') && config_hash.has_key?('xml_file_var')
      path = config_hash['xml_file_path']
      var = config_hash['xml_file_var']
      @log.info('Opening XML file : ' + path)
      begin
        xml = Crack::XML.parse(File.open(path))
      rescue Exception => e
        abort "Error : Could not parse XML file #{path}\n#{e}"
      end
      struct = {}
      struct[var] = xml
      @log.debug("Created XML structure : #{struct}")
      struct
    else
      {}
    end
  end

end

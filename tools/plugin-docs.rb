#!/usr/bin/env ruby

PLUGIN_DIRS=[ "lib/tiller/data" , "lib/tiller/template" ]
DOCS_DIR="docs/plugins"

if ! File.directory? PLUGIN_DIRS[0]
  die("Could not find plugin directories - please run this from the root of the repo.")
end

plugin_list = ""

PLUGIN_DIRS.each do |dir|
  puts "Generating plugin documentation from #{dir}"
  Dir.glob(File.join(Dir.pwd, dir,"*.rb")).each do |plugin|
    require plugin
    if defined? plugin_meta
      puts "Found plugin metadata for #{plugin}"
      metadata = plugin_meta
      raise "Missing metadata ID" unless metadata.has_key?(:id)

      if metadata.has_key?(:documentation_link)
        puts "Plugin points elsewhere for documentation, skipping..."
        next
      end

      doc_path = File.join(DOCS_DIR,"#{File.basename(plugin, ".rb")}.md")
      puts "Wrote #{doc_path}"
      File.write(doc_path, metadata[:documentation])

      if metadata.has_key?(:description) && metadata.has_key?(:title)
        puts "Description found for #{plugin}"
        plugin_list << " * [#{metadata[:title]}](#{doc_path}) : #{metadata[:description]}\n"
      end

      undef plugin_meta
    end

  end
end

puts "Writing README.md"
readme = File.read("docs/src/README.src.md")
readme.sub!("__PLUGIN_LIST__" , plugin_list)
File.write("README.md", readme)

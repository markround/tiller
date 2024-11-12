require 'zip'

When(/^I have unzipped the archive "(.+)"$/) do |archive|
  dirname = File.dirname(archive)
  Zip::File.open(archive) do |zip_file|
    zip_file.each do |entry|
      dest = File.join(dirname, entry.name)
      puts "Extracting #{entry.name} to #{dest}"
      if File.exist?(dest)
        puts "File exists, skipping..."
      else
        entry.extract(dest)
      end
    end
  end
end

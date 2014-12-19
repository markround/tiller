# This is needed so we can enumerate all the loaded plugins later
class Class
  def subclasses
    ObjectSpace.each_object(Class).select { |c| c < self }
  end
end

# Warn if values are being merged
def warn_merge(key, old, new, type, source)
  puts "Warning, merging duplicate #{type} values."
  puts "#{key} => '#{old}' being replaced by : '#{new}' from #{source}"
  new
end
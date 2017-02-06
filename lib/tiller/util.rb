class ::Hash

  def tiller_merge!(second)
    if Tiller::config['deep_merge']
      self.deep_merge!(second)
    else
      self.merge!(second){ |key , v1 , v2| yield key, v1, v2 if block_given? }
    end
  end


  def deep_merge!(second)
    merger = proc { |_key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : [:undefined, nil, :nil].include?(v2) ? v1 : v2 }
    self.merge!(second, &merger)
  end

  # https://gist.github.com/sepastian/8688143
  def deep_traverse(&block)
    stack = self.map{ |k,v| [ [k], v ] }
    while not stack.empty?
      key, value = stack.pop
      yield(key, value)
      if value.is_a? Hash
        value.each{ |k,v| stack.push [ key.dup << k, v ] }
      end
    end
  end

end

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

# Pass signals on to child process
def signal(sig, pid, options={})
  puts "Caught signal #{sig}, passing to PID #{pid}" if options[:verbose]
  begin
    Process.kill(sig, pid)
  rescue Errno::ESRCH
    false
  end
end

# Fork and launch a process.
def launch(cmd)
  # If an array, then we use a different form of spawn() which
  # avoids a subshell. See https://github.com/markround/tiller/issues/8
  if cmd.is_a?(Array)
    final='cmd[0]'
    # Build up the list of arguments when using the array form of spawn()
    if cmd.size > 1
      (1..cmd.size-1).each {|c| final="#{final} , cmd[#{c}]" }
    end
    pid=eval "spawn(#{final})"
  else
    pid=spawn(cmd)
  end

  pid
end
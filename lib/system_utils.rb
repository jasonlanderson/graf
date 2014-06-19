class SystemUtils
  def self.get_process_size()
    pid, size = `ps ax -o pid,rss | grep -E "^[[:space:]]*#{$$}"`.strip.split.map(&:to_i)
    return size
  end
end
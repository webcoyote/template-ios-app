# Compatibility patch for Ruby 3.2+
# Ruby 3.2 removed File.exists? in favor of File.exist?
class File
  class << self
    alias_method :exists?, :exist? unless method_defined?(:exists?)
  end
end

class Dir
  class << self
    alias_method :exists?, :exist? unless method_defined?(:exists?)
  end
end

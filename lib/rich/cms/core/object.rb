class Object
  class << self
    def attr_cmsable(*attrs)
      attr_cmsables.concat(attrs).uniq!
    end

    def attr_cmsables
      @attr_cmsables ||= []
    end
  end
end
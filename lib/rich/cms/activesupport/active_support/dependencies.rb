module ActiveSupport
  module Dependencies

    extend self

    unless respond_to? :autoload_paths
      alias_method :autoload_paths     , :load_paths
      alias_method :autoload_once_paths, :load_once_paths
    end

  end
end
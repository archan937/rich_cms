module ActiveSupport
  module Dependencies

    extend self

    if Rails::VERSION::MAJOR < 3
      alias_method :autoload_paths     , :load_paths
      alias_method :autoload_once_paths, :load_once_paths
    end

  end
end
Dir[File.expand_path("../content/*.rb", __FILE__)].each do |file|
  require file
end

module Rich
  module Cms
    module Content

      def self.included(base)
        base.send :include, Base
        base.send :include, Identification
        base.send :include, Storage
        base.send :include, Rendering
      end

      mattr_accessor :classes

    extend self

      @@classes = []

      def add_class(klass)
        return if @@classes.include?(klass)
        (@@classes << klass).sort!{|a, b| a.name <=> b.name}
      end

      def fetch(*args)
        options = args.extract_options!.symbolize_keys!
        raise ArgumentError, "CSS selector and identifier required" if options.nil?

        selector = args.first || options.delete(:selector)
        raise ArgumentError, "Missing CSS selector for class identification" if selector.nil?

        klass = @@classes.detect{|x| x.css_selector == selector.downcase}
        raise ArgumentError, "Could not found matching CMS content class for #{selector.inspect}" if klass.nil?

        klass.find options
      end

    end
  end
end
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

      def fetch(css_selector, identifier)
        klass = @@classes.detect{|x| x.css_selector == css_selector.downcase}
        raise ArgumentError, "Could not found matching CMS content class for #{selector.inspect} in #{@@classes.collect(&:css_selector).inspect}" if klass.nil?

        klass.find_or_initialize identifier
      end

      def javascript_hash
        "{#{@@classes.collect{|klass| klass.to_javascript_hash}.join ", "}}".html_safe
      end

    end
  end
end
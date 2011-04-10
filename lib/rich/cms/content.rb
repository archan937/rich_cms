Dir[File.expand_path("../content/*.rb", __FILE__)].each do |file|
  require file
end

module Rich
  module Cms
    module Content

      class SelectorNotMatchedError < StandardError; end

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
        raise NotImplementedError, "You cannot fetch Rich-CMS content without having defined at least one Rich-CMS content class" if @@classes.empty?

        klass = @@classes.detect{|x| x.css_selector == css_selector.downcase}
        raise SelectorNotMatchedError, "Could not found matching CMS content class for #{css_selector.inspect} in #{@@classes.collect(&:css_selector).inspect}" if klass.nil?

        klass.find_or_initialize identifier
      end

      def javascript_hash
        pairs = @@classes.sort do |a, b|
                            a.css_selector <=> b.css_selector
                          end.
                          collect do |klass|
                           "#{klass.css_selector.inspect}: #{klass.to_javascript_hash}"
                          end
        "{#{pairs.join ", "}}".html_safe
      end

    end
  end
end
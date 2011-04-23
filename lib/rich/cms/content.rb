Dir[File.expand_path("../content/*.rb", __FILE__)].each do |file|
  require file
end

module Rich
  module Cms
    module Content

      class CssClassNotMatchedError < StandardError; end

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

      def check_in_memory_storage
        @@classes.each do |klass|
          warn "[WARNING] #{klass.name} is using #{klass.content_store.class.name} (in memory) as storage engine".yellow if klass.content_store.is_a?(Hash)
        end
      end

      def fetch(css_class, identifier)
        raise NotImplementedError, "You cannot fetch Rich-CMS content without having defined at least one Rich-CMS content class" if @@classes.empty?

        klass = @@classes.detect{|x| x.css_class == css_class.downcase}
        raise CssClassNotMatchedError, "Could not find matching Rich-CMS content class for #{css_class.inspect} in #{@@classes.collect(&:css_class).inspect}" if klass.nil?

        klass.find_or_initialize identifier
      end

      def javascript_hash
        pairs = @@classes.sort do |a, b|
                            a.css_class <=> b.css_class
                          end.
                          collect do |klass|
                           "#{klass.css_class.inspect}: #{klass.to_javascript_hash}"
                          end
        "{#{pairs.join ", "}}".html_safe
      end

    end
  end
end
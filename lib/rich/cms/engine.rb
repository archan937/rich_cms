
module Rich
  module Cms
    module Engine
      
      class RichCmsError < StandardError
      end
      
      extend self
      
      attr_reader :authentication
  
      def init
        @authentication   = AuthenticationSpecs.new
        @editable_content = {}
        
        ApplicationController.send :include, ::Rich::Cms::Controller
        ActionView::Base     .send :include, ::Rich::Cms::Helper
        
        ::Jzip::Plugin.add_template_location({File.join(File.dirname(__FILE__), "..", "..", "..", "assets", "jzip") => RAILS_ROOT + "/public/javascripts"})
        ::Sass::Plugin.add_template_location( File.join(File.dirname(__FILE__), "..", "..", "..", "assets", "sass"),   RAILS_ROOT + "/public/stylesheets" )
      end
      
      def authenticate(logic, specs)
        @authentication = AuthenticationSpecs.new(logic, specs)
      end
      
      def register(*args)
        (editables = args.first.is_a?(Hash) ? args.first : Hash[*args]).each do |selector, specs|
          if @editable_content.keys.include?(selector)
            raise RichCmsError, "Already registered editable content identified with #{selector.inspect}"
          else
            @editable_content[selector] = specs
          end
        end
      end
      
      def editable_content
        @editable_content.inject({}) do |h, (key, value)|
          h[key] = {:key => :key, :value => :value}.merge(value)
          h
        end
      end
      
      def editable_content_javascript_hash
        "{#{editable_content.collect{|key, value| "#{key.to_s.inspect}: {#{value.reject{|k, v| [:class].include?(k)}.collect{|k, v| "#{k.to_s}: 'data-#{v.to_s}'"}.join(", ")}}"}.join(", ")}}"
      end
      
      def to_content_tag(reference)
        selector, key = reference.to_a.first
        Cms::EditableContent.new(:__selector__ => selector, editable_content[selector][:key] => key).to_tag
      end
      
    private
    
      AuthenticationSpecs = Struct.new(:logic, :specs)
      
    end
  end
end

Rich::Cms::Engine.init

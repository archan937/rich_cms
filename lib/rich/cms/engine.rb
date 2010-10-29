module Rich
  module Cms
    module Engine

      class RichCmsError < StandardError
      end

      extend self

      attr_reader :authentication, :editable_content

      def init
        @authentication   = AuthenticationSpecs.new
        @editable_content = {}

        %w(controllers).each do |dir|
          path = File.join File.dirname(__FILE__), "..", "..", "app", dir
          $LOAD_PATH << path
          ActiveSupport::Dependencies.autoload_paths << path
          ActiveSupport::Dependencies.autoload_once_paths.delete path
        end

        ::Jzip::Engine.add_template_location({File.join(File.dirname(__FILE__), "..", "..", "assets", "jzip") => File.join(RAILS_ROOT, "public", "javascripts")})
        ::Sass::Plugin.add_template_location( File.join(File.dirname(__FILE__), "..", "..", "assets", "sass"),   File.join(RAILS_ROOT, "public", "stylesheets") )

        copy_assets
      end

      def copy_assets
        return if RAILS_ENV == "test"

        source_dir = File.join File.dirname(__FILE__), "..", "..", "assets", "images", "."
        target_dir = File.join RAILS_ROOT, "public", "images", "rich", "cms"

        FileUtils.rm_r    target_dir if File.exists? target_dir
        FileUtils.mkdir_p target_dir
        FileUtils.cp_r    source_dir, target_dir
      end

      def current_controller=(current_controller)
        @current_controller  = current_controller
        @can_render_metadata = nil
      end

      def authenticate(logic, specs)
        @authentication = AuthenticationSpecs.new(logic, specs)
      end

      def register(*args)
        (editables = args.first.is_a?(Hash) ? args.first : Hash[*args]).each do |selector, specs|
          if @editable_content.keys.include?(selector)
            raise RichCmsError, "Already registered editable content identified with #{selector.inspect}"
          else
            @editable_content[selector] = Cms::Content::Group.build(selector, specs)
          end
        end
      end

      def to_content_tag(selector, identifiers, options = {})
        editable_content[selector].fetch(identifiers).to_tag options
      end

      def editable_content_javascript_hash
        "{#{@editable_content.collect{|k, v| v.to_javascript_hash}.join ", "}}"
      end

      def can_render_metadata?
        if @can_render_metadata.nil?
          @can_render_metadata = case authentication.logic
                                 when :authlogic
                                   @current_controller.try :current_rich_cms_admin
                                 when nil
                                   true
                                 end
        else
          @can_render_metadata
        end
      end

    private

      AuthenticationSpecs = Struct.new(:logic, :specs)

    end
  end
end

Rich::Cms::Engine.init

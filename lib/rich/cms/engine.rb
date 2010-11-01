module Rich
  module Cms
    class Engine < Rails::Engine

      cattr_reader :authentication, :editable_content

      def self.init
        @@authentication   = AuthenticationSpecs.new
        @@editable_content = {}

        %w(controllers).each do |dir|
          path = File.join File.dirname(__FILE__), "..", "..", "app", dir
          $LOAD_PATH << path
          ActiveSupport::Dependencies.autoload_paths << path
          ActiveSupport::Dependencies.autoload_once_paths.delete path
        end

        config.after_initialize do
          ::Jzip::Engine.add_template_location({File.expand_path("../../../../assets/jzip", __FILE__) => File.join(Rails.root, 'public', 'javascripts')})
          ::Sass::Plugin.add_template_location(File.expand_path("../../../../assets/sass", __FILE__), File.join(Rails.root, 'public', 'stylesheets'))

          # disable for now
          # copy_assets
        end
      end

      def self.copy_assets
        return if Rails.env == "test"

        source_dir = File.join File.dirname(__FILE__), "..", "..", "assets", "images", "."
        target_dir = File.join Rails.root, "public", "images", "rich", "cms"

        FileUtils.rm_r    target_dir if File.exists? target_dir
        FileUtils.mkdir_p target_dir
        FileUtils.cp_r    source_dir, target_dir
      end

      def self.current_controller=(current_controller)
        @@current_controller  = current_controller
        @@can_render_metadata = nil
      end

      def self.authenticate(logic, specs)
        @@authentication = AuthenticationSpecs.new(logic, specs)
      end

      def self.register(*args)
        (editables = args.first.is_a?(Hash) ? args.first : Hash[*args]).each do |selector, specs|
          if @@editable_content.keys.include?(selector)
            raise RichCmsError, "Already registered editable content identified with #{selector.inspect}"
          else
            @@editable_content[selector] = Cms::Content::Group.build(selector, specs)
          end
        end
      end

      def self.to_content_tag(selector, identifiers, options = {})
        editable_content[selector].fetch(identifiers).to_tag options
      end

      def self.editable_content_javascript_hash
        "{#{@@editable_content.collect{|k, v| v.to_javascript_hash}.join ", "}}".html_safe
      end

      def self.can_render_metadata?
        if @@can_render_metadata.nil?
          @@can_render_metadata = case authentication.logic
                                 when :authlogic
                                   @@current_controller.try :current_rich_cms_admin
                                 when nil
                                   true
                                 end
        else
          @@can_render_metadata
        end
      end

      private

      AuthenticationSpecs = Struct.new(:logic, :specs)

    end
    # class Rich::Cms::Engine < Rails::Engine

    class RichCmsError < StandardError
    end

  end
end

Rich::Cms::Engine.init


module Rich
  module Cms
    class Engine < Rails::Engine

      class << self

        def init
          Rich::Support.after_initialize do
            copy_assets
            require_models
          end
        end

      private

        def copy_assets
          %w(images javascripts stylesheets).each do |dir|
            source_dir = File.join File.expand_path("../../../../assets/public/#{dir}", __FILE__)
            target_dir = File.join Rails.root, "public/#{dir}"

            Dir["#{source_dir}/**/*.*"].each do |source|
              target = source.gsub source_dir, target_dir
              unless File.exists? target
                FileUtils.mkdir_p File.dirname(target)
                FileUtils.cp source, target
              end
            end
          end
        end

        def require_models
          Dir["#{Rails.root}/app/models/**{,/*/**}/*.rb"].each do |file|
            require file
          end unless Rails.configuration.cache_classes
        end

      end

    end
  end
end

Rich::Cms::Engine.init
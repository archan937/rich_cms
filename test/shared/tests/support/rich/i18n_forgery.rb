I18n.locale = I18n.default_locale = :nl

module I18n
  extend self
  def self.t(key)
    {:nl => {:world => "wereld"}}[locale.to_sym][key.to_sym]
  end
end

# The following will be implemented in Rich-i18n soon

module Rich
  module I18nForgery
    module Content

      def self.included(base)
        base.send :include, Rich::Cms::Content
        base.extend ClassMethods
        base.class_eval do
          identifiers :locale, :key
        end
      end

      module ClassMethods

      protected

        def identity_hash_for(identifier)
          super correct_identifier(identifier)
        end

      private

        def correct_identifier(identifier)
          [String, Symbol].include?(identifier.class) && identifier.to_s.split(delimiter).size == 1 ?
            [I18n.locale, identifier].join(delimiter) :
            identifier
        end

      end

    end
  end
end

class Translation
  include Rich::I18nForgery::Content
  storage :memory
end
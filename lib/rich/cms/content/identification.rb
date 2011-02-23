module Rich
  module Cms
    module Content
      module Identification

        DELIMITER = ":"

        def self.included(base)
          base.extend ClassMethods
          base.class_eval do
            @identifiers = nil
          end
        end

        module ClassMethods
          def identifiers(*vars)
            if vars.empty?
              prepare_identifiers
              @identifiers
            else
              set_identifiers *vars
            end
          end

          def delimiter
            DELIMITER
          end

        protected

          def identity_hash_for(identifier)
            validate_identifier! identifier

            if identifier.is_a?(Hash)
              identifier
            else
              values = identifier.to_s.split delimiter
              Hash[*identifiers.zip(values).flatten]
            end
          end

          def validate_identifier!(identifier)
            case identifier.class.name
            when "Hash"
              identifier.symbolize_keys!.assert_valid_keys *identifiers
              unless (missing_keys = (identifiers - identifier.reject{|k, v| v.blank?}.keys)).empty?
                raise ArgumentError, "Missing key(s): #{missing_keys.collect(&:inspect).join ", "}"
              end
            when "String", "Symbol"
              if identifier.to_s.blank?
                raise ArgumentError, "Passed blank identifier"
              end
              unless identifier.to_s.split(delimiter).reject(&:blank?).size == identifiers.size
                raise ArgumentError, "Passed identifier #{identifier.inspect} does not match #{identifiers.inspect}"
              end
            else
              raise ArgumentError, "Passed invalid identifier #{identifier.inspect}"
            end
          end

        private

          def prepare_identifiers
            set_identifiers(:key) if @identifiers.blank?
          end

          def set_identifiers(*vars)
            (@identifiers = vars.collect(&:to_sym).sort{|a, b| a.to_s <=> b.to_s}).each do |attribute|
              self.attr_accessor attribute
            end
          end
        end

      end
    end
  end
end
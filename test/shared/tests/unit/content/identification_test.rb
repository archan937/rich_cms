require File.expand_path("../../../test_helper.rb", __FILE__)

module Content
  class IdentificationTest < ActiveSupport::TestCase

    context "A Rich-CMS content class" do
      context "as default content" do
        setup do
          class Content
            include Rich::Cms::Content
            storage :memory
          end
        end

        should "be able to derive the identity hash" do
          assert_equal({:key => "header"}, Content.send(:identity_hash_for, "header"))
          assert_equal({:key => "header"}, Content.send(:identity_hash_for, {:key  => "header"}))
          assert_equal({:key => "header"}, Content.send(:identity_hash_for, {"key" => "header"}))
        end

        should "raise an error when passed an invalid identifier for key determination" do
          assert_raise ArgumentError do Content.send :identity_hash_for, " "                               end
          assert_raise ArgumentError do Content.send :identity_hash_for, :" "                              end
          assert_raise ArgumentError do Content.send :identity_hash_for, {}                                end
          assert_raise ArgumentError do Content.send :identity_hash_for, {:key => nil}                     end
          assert_raise ArgumentError do Content.send :identity_hash_for, {:foo => "bar"}                   end
          assert_raise ArgumentError do Content.send :identity_hash_for, {:key => "header", :foo => "bar"} end
          assert_raise ArgumentError do Content.send :identity_hash_for, 19820801                          end
        end
      end

      context "as Rich-CMS content with an identifier (used for combined keys)" do
        setup do
          class Content
            include Rich::Cms::Content
            storage     :memory
            identifiers :locale, :key
          end
          @delimiter = Content.delimiter
        end

        should "be able to derive the key" do
          store_key = "nl#{@delimiter}header"
          assert_equal({:key => "header", :locale => "nl"}, Content.send(:identity_hash_for, store_key))
          assert_equal({:key => "header", :locale => :nl }, Content.send(:identity_hash_for, {:key  => "header", :locale  => :nl}))
          assert_equal({:key => "header", :locale => :nl }, Content.send(:identity_hash_for, {"key" => "header", "locale" => :nl}))
        end

        should "raise an error when passed an invalid identifier for key determination" do
          assert_raise ArgumentError do Content.send :identity_hash_for, " "                               end
          assert_raise ArgumentError do Content.send :identity_hash_for, :" "                              end
          assert_raise ArgumentError do Content.send :identity_hash_for, "#{@delimiter}"                   end
          assert_raise ArgumentError do Content.send :identity_hash_for, :"#{@delimiter}"                  end
          assert_raise ArgumentError do Content.send :identity_hash_for, "header"                          end
          assert_raise ArgumentError do Content.send :identity_hash_for, :"header"                         end
          assert_raise ArgumentError do Content.send :identity_hash_for, "header#{@delimiter}"             end
          assert_raise ArgumentError do Content.send :identity_hash_for, :"#{@delimiter}header"            end
          assert_raise ArgumentError do Content.send :identity_hash_for, {}                                end
          assert_raise ArgumentError do Content.send :identity_hash_for, {:foo => "bar"}                   end
          assert_raise ArgumentError do Content.send :identity_hash_for, {:key => "header", :foo => "bar"} end
          assert_raise ArgumentError do Content.send :identity_hash_for, 19820801                          end
        end
      end
    end

  end
end
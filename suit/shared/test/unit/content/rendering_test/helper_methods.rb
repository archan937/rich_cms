require "hpricot"

module Content
  class RenderingTest < ActiveSupport::TestCase
    module HelperMethods

      def hpricot(html)
        Hpricot(html.strip).children.first.tap do |element|
          def element.tag_name
            to_html.match(/^<([^\s>]+)/).try(:captures).try(:first) || ""
          end
        end
      end

      def strip_meta_data(options, html)
        element    = hpricot html
        tag_name   = element.tag_name
        attributes = (options[:html] || {}).collect{|key, value| "#{key}=\"#{::ERB::Util.html_escape value}\""}.join(" ")
        inner_html = element.html.gsub /<|>/, ""

        options[:tag] == :none ?
          inner_html :
          "<#{tag_name} #{attributes}>#{inner_html}</#{tag_name}>"
      end

      def replace_value(html, value)
        element            = hpricot html.gsub %q{data-value=""}, "data-value=\"#{value}\""
        element.inner_html = value
        element.to_html
      end

      def assert_all(expectations, content)
        expectations.in_groups_of(2) do |options, html|
          assert_expectation options, html, content
        end
      end

      def assert_expectation(options, html, content)
        a = hpricot html
        b = hpricot content.to_tag(options)
        a_attributes = a.raw_attributes unless a.is_a? Hpricot::Text
        b_attributes = b.raw_attributes unless a.is_a? Hpricot::Text

        begin
          assert_equal a.tag_name  , b.tag_name
          assert_equal a.html.strip, b.html.strip
          assert_equal a_attributes, b_attributes

        rescue Test::Unit::AssertionFailedError => e
          puts "\nOptions: #{options.inspect}"
          puts "HTML: #{html.inspect}"
          raise
        end
      end

      def update_and_fetch_contents(content, translation)
        content    .value = "Hello world!"
        translation.value = "Hallo wereld!"
        content    .save
        translation.save

        [Rich::Cms::Content.fetch(content    .class.css_class, content    .store_key),
         Rich::Cms::Content.fetch(translation.class.css_class, translation.store_key)]
      end

      # //////////////////////////////////
      # // Expections with meta data
      # //////////////////////////////////

      def content_expectations_with_meta_data
        @content_expectations_with_meta_data ||= [
          {}, %q{
            <span class="rich_cms_content" data-store_key="hello_world" data-value="">
              < hello world >
            </span>},

          {:tag => :none}, %q{
            <span class="rich_cms_content" data-store_key="hello_world" data-value="">
              < hello world >
            </span>},

          {:html => {:id => "content1", :class => "editable"}}, %q{
            <span id="content1" class="rich_cms_content editable" data-store_key="hello_world" data-value="">
              < hello world >
            </span>},

          {:tag => :h1}, %q{
            <h1 class="rich_cms_content" data-store_key="hello_world" data-value="">
              < hello world >
            </h1>},

          {:as => :string}, %q{
            <span class="rich_cms_content" data-store_key="hello_world" data-value="" data-editable_input_type="string">
              < hello world >
            </span>},

          {:as => :text}, %q{
            <div class="rich_cms_content" data-store_key="hello_world" data-value="" data-editable_input_type="text">
              < hello world >
            </div>},

          {:as => :html}, %q{
            <div class="rich_cms_content" data-store_key="hello_world" data-value="" data-editable_input_type="html">
              < hello world >
            </div>}]
      end

      def translation_expectations_with_meta_data
        @translation_expectations_with_meta_data ||= [
          {}, %q{
            <span class="rcms_translation" data-store_key="nl:hello_world" data-value="">
              < hello world >
            </span>},

          {:tag => :none}, %q{
            <span class="rcms_translation" data-store_key="nl:hello_world" data-value="">
              < hello world >
            </span>},

          {:html => {:id => "content1", :class => "editable"}}, %q{
            <span id="content1" class="rcms_translation editable" data-store_key="nl:hello_world" data-value="">
              < hello world >
            </span>},

          {:tag => :h1}, %q{
            <h1 class="rcms_translation" data-store_key="nl:hello_world" data-value="">
              < hello world >
            </h1>},

          {:as => :string}, %q{
            <span class="rcms_translation" data-store_key="nl:hello_world" data-value="" data-editable_input_type="string">
              < hello world >
            </span>},

          {:as => :text}, %q{
            <div class="rcms_translation" data-store_key="nl:hello_world" data-value="" data-editable_input_type="text">
              < hello world >
            </div>},

          {:as => :html}, %q{
            <div class="rcms_translation" data-store_key="nl:hello_world" data-value="" data-editable_input_type="html">
              < hello world >
            </div>}]
      end

      def stored_content_expectations_with_meta_data
        @stored_content_expectations_with_meta_data ||= content_expectations_with_meta_data.in_groups_of(2).collect{|x| [x[0], replace_value(x[1], "Hello world!")]}.flatten
      end

      def stored_translation_expectations_with_meta_data
        @stored_translation_expectations_with_meta_data ||= translation_expectations_with_meta_data.in_groups_of(2).collect{|x| [x[0], replace_value(x[1], "Hallo wereld!")]}.flatten
      end

      # //////////////////////////////////
      # // Expections without meta data
      # //////////////////////////////////

      def content_expectations_without_meta_data
        @content_expectations_without_meta_data ||= content_expectations_with_meta_data.in_groups_of(2).collect{|x| [x[0], strip_meta_data(*x)]}.flatten
      end

      def translation_expectations_without_meta_data
        @translation_expectations_without_meta_data ||= translation_expectations_with_meta_data.in_groups_of(2).collect{|x| [x[0], strip_meta_data(*x)]}.flatten
      end

      def stored_content_expectations_without_meta_data
        @stored_content_expectations_without_meta_data ||= stored_content_expectations_with_meta_data.in_groups_of(2).collect{|x| [x[0], strip_meta_data(*x)]}.flatten
      end

      def stored_translation_expectations_without_meta_data
        @stored_translation_expectations_without_meta_data ||= stored_translation_expectations_with_meta_data.in_groups_of(2).collect{|x| [x[0], strip_meta_data(*x)]}.flatten
      end

    end
  end
end
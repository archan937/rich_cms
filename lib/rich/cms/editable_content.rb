
module Rich
  module Cms
    class EditableContent
      
      def initialize(params)
        @params = params.dup
      end
      
      def to_tag
        "<div class='betty_cms_content' data-#{specs[:key]}='#{object.send specs[:key]}' data-#{specs[:value]}='#{object.send specs[:value]}'>#{object.new_record? ? "< #{object.send specs[:key]} >" : object.send(specs[:value])}</div>"
      end
      
      def save
        object.update_attributes updated_attributes
        object.respond_to?(:to_rich_cms_response) ? object.to_rich_cms_response : object.attributes.reject{|k, v| [:id, :created_at, :updated_at].include?(k)}.merge({:__selector__ => @params[:__selector__]})
      end
      
    private
    
      def specs
        @specs ||= Engine.editable_content[@params[:__selector__]]
      end
      
      def model_class
        specs[:class]
      end
      
      def identifiers
        [specs[:key]].flatten
      end
    
      def object
        @object ||= model_class.send :"find_or_initialize_by_#{identifiers.join "_and_"}", *@params.values_at(*identifiers)
      end
      
      def updated_attributes
        attribute = specs[:value]
        {attribute => @params[specs[:value]]}
      end
      
    end
  end
end

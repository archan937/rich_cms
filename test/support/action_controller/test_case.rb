module ActionController
  class TestCase

  protected

    def assert_named_route(result, name)
      assert_equal result, named_routes[name.to_s]
    end

    def named_routes
      @named_routes ||= Hash[*begin
        if Rails::VERSION::MAJOR >= 3
          Rails.application.routes.routes.collect do |route|
            [route.name, route.path.gsub("(.:format)", "")] unless route.name.blank?
          end
        else
          ActionController::Routing::Routes.routes.collect do |route|
            name = ActionController::Routing::Routes.named_routes.routes.index(route).to_s
            path = route.segments.collect(&:to_s).join
            path.chop! if path.length > 1
            [name, path] unless name.blank?
          end
        end
      end.compact.flatten]
    end

  end
end
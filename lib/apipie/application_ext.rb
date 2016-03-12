module Apipie
  class Application

    def define_method_description( controller, method_name, dsl_data )
      return if ignored?( controller, method_name )
      ret_method_description = nil

      versions = dsl_data[:api_versions] || []
      versions = controller_versions( controller ) if versions.empty?

      versions.each do |version|
        resource_name_with_version = "#{version}##{get_resource_name(controller)}"
        resource_description = get_resource_description( resource_name_with_version )

        if resource_description.nil?
          resource_description = define_resource_description( controller, version )
        end

        method_description = Apipie::MethodDescription.new( method_name, resource_description, dsl_data )

        # we create separate method description for each version in
        # case the method belongs to more versions. We return just one
        # becuase the version doesn't matter for the purpose it's used
        # (to wrap the original version with validators)
        ret_method_description ||= method_description
        resource_description.add_method_description( method_description )
      end

      return ret_method_description
    end

  end
end
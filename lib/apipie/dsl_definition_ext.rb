module Apipie::DSL::Controller

  def param!( param_name, type, *args, &block )
    return unless Apipie.active_dsl?
    param_dsl = {
        name: param_name,
        type: type,
        desc: '',
        options: {
            required: true
        },
        block: block
    }
    i = 0
    if args[i].is_a? String
      param_dsl[:desc] = args[i]
      i = i + 1
    end
    if args[i].is_a? Hash
      param_dsl[:option].merge! args[i]
      i = i + 1
    end
    _apipie_dsl_data[:params] << param_dsl
  end

  # create method api and redefine newly added method
  def method_added( method_name ) #:doc:
    super
    return unless Apipie.active_dsl? && _apipie_dsl_data[:api]
    return if _apipie_dsl_data[:api_args].blank? && _apipie_dsl_data[:api_from_routes].blank?

    # remove method description if exists and create new one
    Apipie.remove_method_description( self, _apipie_dsl_data[:api_versions], method_name )
    description = Apipie.define_method_description( self, method_name, _apipie_dsl_data )

    _apipie_dsl_data_clear
    _apipie_define_validators(description)
  ensure
    _apipie_dsl_data_clear
  end

end
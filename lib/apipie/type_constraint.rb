module Apipie
  module Type

    class TypeConstraint

      def self.create( type, validation_spec_block )
        type_constraint_class_name = "#{type.camelcase}Constraint"
        begin
          type_constraint_class = eval( "Apipie::Type::#{type_constraint_class_name}" )
          raise "Not class" unless type_constraint_class.is_a? Class
        rescue
          ns = Apipie.configuration.type_constraint_ns;
          ns = ns ? ns + '::' : ''
          begin
            type_constraint_class = eval( "#{ns}#{type_constraint_class_name}Constraint" )
            raise "Not class" unless type_constraint_class.is_a? Class
          rescue
            raise Apipie::DslError "Cannot find constraint for type #{type}"
          end
        end
        type_constraint_class.new( validation_spec_block )
      end

      def initialize( validation_spec_block )
        instance_exec( &validation_spec_block ) unless validation_spec_block.nil?
      end

      def type_s
        class_name = self.class.to_s
        class_name[0, class_name.size - 10].under_score.to_sym
      end

      def validators
        @validators ||= []
      end

      def add_validator( validator )
        validators << validator
      end

      def method_missing( symbol, *args )
        validator_class_name = "#{symbol.to_s.camelcase}Validator"
        begin
          validator_class = eval( "Apipie::Validator::#{validator_class_name}" )
          raise "Not class" unless validator_class.is_a? Class
        rescue
          ns = Apipie.configuration.validator_ns;
          ns = ns ? ns + '::' : ''
          begin
            validator_class = eval( "#{ns}#{validator_class_name}" )
            raise "Not class" unless validator_class.is_a? Class
          rescue
            raise Apipie::DslError "Cannot find validator #{symbol}"
          end
        end
        add_validator validator_class.new( type_s, *args )
      end

    end

    class StringConstraint < TypeConstraint

      def _validate( value )
        value.is_a? String
      end

      def _description
        'must be a string'
      end

    end

    class IntegerConstraint < TypeConstraint

      def _validate( value )
        return true if value.is_a? Integer
        return false unless value.is_a? String
        !!(value =~ /^[+\-]?[0-9]+$/)
      end

      def _description
        'must be an integer'
      end

    end

    class ArrayConstraint < TypeConstraint

      def _validate( value )
        value.is_a? Array
      end

      def _description
        'must be an array'
      end

      def type( type, &validation_spec_block )
        @elem_type_constraint = TypeConstraint.create( type, validation_spec_block )
      end

    end

    class HashConstraint < TypeConstraint

      def _validate( value )
        value.is_a? Hash
      end

      def _description
        'must be a hash'
      end

      def param!(*args)

      end

    end

  end
end
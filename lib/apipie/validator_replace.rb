module Apipie
  module Validator

    class BaseValidator

      def self.accept( type_sym )
        @@type_sym = type_sym
      end

      def initialize( type_sym )
        raise Apipie::DslError( "#{self.class.to_s} cannot validate value of type #{type_sym}" ) unless accept? type_sym
      end

      def accept?( type_sym )
        type_sym == @@type_sym
      end


    end

    class EmailValidator < BaseValidator

      accept :string

      def initialize( type_sym )
        super( type_sym )
      end

      def validate( value )
        !!(value =~ /^(\w+|-|.)+@(\w|-)+(\.(\w|-)+)*$/)
      end

      def description
        'must be email format'
      end

    end

    class LengthInValidator < BaseValidator

      accept :string

      def initialize( type_sym, min_length, max_length )
        super( type_sym )
        unless min_length.is_a? Integer || min_length.nil?
          raise Apipie::DslError( "When create LengthInValidator: first parameter must be Integer or Nil" )
        end
        unless max_length.is_a? Integer || max_length.nil?
          raise Apipie::DslError( "When create LengthInValidator: second parameter must be Integer or Nil" )
        end
        if @min_length.nil? && @max_length.nil?
          raise Apipie::DslError( "When create LengthInValidator: at least one parameter should not be Nil")
        end
        @min_length = min_length
        @max_length = max_length
      end

      def validate( value )
        return false unless @min_length.nil? || value.size >= @min_length
        @max_length.nil? || value.size <= @max_length
      end

      def description
        return "must be no more than #{@max_length} characters" if @min_length.nil?
        return "must be no less than #{@min_length} characters" if @max_length.nil?
        "length must be between #{@min_length} and #{@max_length}"
      end

    end

  end
end
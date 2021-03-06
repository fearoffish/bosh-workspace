module Bosh::Workspace
  module Schemas
    class Stemcells < Membrane::Schemas::Base
      def validate(object)
        Membrane::SchemaParser.parse do
          [{
            "name"    => String,
            "version" => StemcellVersion.new
          }]
        end.validate object
      end
    end

    class StemcellVersion < Membrane::Schemas::Base
      def validate(object)
        return if object.is_a? Integer
        return if object.is_a? Float
        return if object == "latest"
        return if object.to_s =~ /^\d+\.\d+$/
        raise Membrane::SchemaValidationError.new(
          "Should match: latest, version.patch or version. Given: #{object}")
      end
    end
  end
end

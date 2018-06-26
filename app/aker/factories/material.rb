module Aker
  module Factories
    ##
    # An Aker material which in this case is a Samples.
    # Must have a Container
    # Must have minimal data which relates to SampleMetadata and includes:
    #  * name (Aker uuid)
    #  * gender
    # Optional data:
    #  * donor_id
    #  * phenotype
    #  * sample_common_name (Aker: common name)
    class Material
      include ActiveModel::Model
      attr_accessor :container
      attr_reader :name, :gender, :donor_id, :phenotype, :sample_common_name, :model

      validates_presence_of :name, :gender

      validate :check_container

      def self.create(params)
        new(params).create
      end

      def initialize(params)
        @name = params[:_id]
        @gender = params[:gender]
        @donor_id = params[:donor_id]
        @phenotype = params[:phenotype]
        @sample_common_name = params[:common_name]
        @container = nil
      end

      ##
      # Persists the material including the associated container
      def create
        return unless valid?
        @model = Sample.create(attributes)
        container_model = container.create
        put_sample_in_container(@model, container_model)
        @model
      end

      def container_not_having_sample?(container, sample)
        container.asset.aliquots.where(sample: sample).count.zero?
      end

      def container_has_aliquots?(container)
        container.asset.aliquots.count.positive?
      end

      def put_sample_in_container(sample, container)
        return container.save if container.asset.nil?

        raise 'The contents of this plate are not up to date with aker job message' if container_not_having_sample?(container, sample) && container_has_aliquots?(container)
        container.asset.aliquots.create!(sample: sample) if container_not_having_sample?(container, sample)
      end

      ##
      # Convert attributes to SampleMetadata and Container
      def attributes
        {
          name: name,
          sample_metadata_attributes: {
            gender: gender,
            donor_id: donor_id,
            phenotype: phenotype,
            sample_common_name: sample_common_name
          },
          container: container.create
        }
      end

      def as_json
        {
          _id: name,
          gender: gender,
          donor_id: donor_id,
          phenotype: phenotype,
          common_name: sample_common_name,
          container: container.as_json
        }
      end

      private

      def check_container
        if container.nil?
          errors.add(:container, 'This material has no container')
          return
        end
        return if container.valid?
        container.errors.each do |key, value|
          errors.add key, value
        end
      end
    end
  end
end

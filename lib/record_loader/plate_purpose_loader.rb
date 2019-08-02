module RecordLoader
  class PlatePurposeLoader < RecordLoader::Base
    self.config_folder = 'plate_purposes'

    DEFAULT_PRINTER_TYPE = '96 Well Plate'

    def create!
      ActiveRecord::Base.transaction do
        @config.each do |name, config|
          next if existing_purposes.include?(name)

          create_purpose(name, config)
        end
      end
    end

    private

    #
    # Returns the purposes from the list that have already been created
    #
    #
    # @return [Array<String>] An array of names of purposes in the config which already exist
    #
    def existing_purposes
      @existing_purposes ||= Purpose.where(name: @config.keys).pluck(:name)
    end

    def create_purpose(name, config)
      creator = config.delete('plate_creator')
      config['barcode_printer_type'] = barcode_printer_type(config.delete('barcode_printer_type'))
      config['name'] = name
      purpose = PlatePurpose.create!(config)
      build_creator(purpose, creator) if creator
    end

    def build_creator(purpose, creator_options)
      config = creator_options.respond_to?(:[]) ? creator_options : {}
      parents = Purpose.where(name: config.fetch('from', []))
      Plate::Creator.create!(
        name: purpose.name,
        plate_purposes: [purpose],
        parent_plate_purposes: parents
      )
    end

    def barcode_printer_type(name)
      @printer_cache ||= Hash.new do |hash, uncached_type_name|
        hash[uncached_type_name] = BarcodePrinterType.find_by(name: uncached_type_name)
      end
      @printer_cache[name || DEFAULT_PRINTER_TYPE]
    end
  end
end

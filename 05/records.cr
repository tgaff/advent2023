class ModelThing
  getter id : Int32?
  property associated_id : Int32?
  getter type : String
  getter associated_type : String

  def initialize(type, associated_type, id, associated_id : Int32? = nil)
    @type = type
    @associated_type = associated_type
    @id = id
    @associated_id = associated_id || id
  end

end

module Records
  class_property mappings
  class_property seed_ids

  TYPES = ["seed", "soil", "fertilizer", "water", "light", "temperature", "humidity", "location"]

  @@seed_ids = [] of Int64

  @@mappings = {
    "seed" => Store.new("seed", "soil"),
    "soil" => Store.new("soil", "fertilizer"),
    "fertilizer" => Store.new("fertilizer", "water"),
    "water" => Store.new("water", "light"),
    "light" => Store.new("light", "temperature"),
    "temperature" => Store.new("temperature", "humidity"),
    "humidity" => Store.new("humidity", "location"),
  }

  class Store
    @_internal_hash = {} of Int32 => ModelThing

    def initialize(from_type : String, to_type : String)
      @from_type = from_type
      @to_type = to_type
    end

    def find_by_id(id : Int32)
      rec = @_internal_hash.fetch(id) do |id|
        puts "failed to find a corresponding record for id #{id} in the #{@from_type} store"
        # generate a replacement

        ModelThing.new(@from_type, @to_type, id)
      end

      rec
    end

    def has_an_association?
      @to_type.present?
    end

    def save(record : ModelThing)
      raise Exception.new("missing an id") if record.id.nil?
      @_internal_hash[record.id.as(Int32)] = record
    end

    def inspect
      @_internal_hash.values.map do |k|
        k.inspect
      end.join("\n")
    end
  end
end
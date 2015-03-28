class Array
  unless instance_methods.include? :to_h
    def to_h
      if elem_index = index { |elem| !elem.is_a?(Array) }
        raise TypeError.new("wrong element type #{self[elem_index].class} at #{elem_index} (expected array)")
      end

      each_with_index.inject({}) do |hash, elem|
        pair, index = elem

        if pair.size != 2
          raise ArgumentError.new("wrong array length at #{index} (expected 2, was #{pair.size})")
        end

        hash.tap do |h|
          key, val = pair
          h[key] = val
        end
      end
    end
  end
end

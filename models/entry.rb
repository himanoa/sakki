class Entry
  def initialize(attrs = {})
    attrs.each_pair do |key, val|
      key = key.to_s.to_sym
      if COLUMNS.include?(key)
        instance_variable_set("@#{key}", val)
      end
    end
  end
  COLUMNS = [:id, :title, :body, :posted_at, :published]
  COLUMNS.each do |column|
    attr_accessor column
  end
end

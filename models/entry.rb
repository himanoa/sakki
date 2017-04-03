require 'time'
class Entry
  def initialize(attrs = {})
    attrs.each_pair do |key, val|
      key = key.to_s.to_sym
      instance_variable_set("@#{key}", val) if COLUMNS.include?(key)
    end
  end

  def body_html
    result = MarkdownProcessor.call(body)
    result[:output].to_s
  end
  def format_posted_at
    posted_at.strftime("%Y-%m-%d %H:%M")
  end
  COLUMNS = [:id, :title, :body, :posted_at, :published].freeze
  COLUMNS.each do |column|
    attr_accessor column
  end
end

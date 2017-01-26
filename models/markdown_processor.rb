require_relative 'markdown_processor/mention_filter'
require_relative 'markdown_processor/twitter_card_filter'
class MarkdownProcessor
  FILTERS = [
    HTML::Pipeline::MarkdownFilter,
    TwitterCardFilter,
    HTML::Pipeline::AutolinkFilter,
    MentionFilter
  ].freeze
  def self.call(text, options = {})
    new(options).call(text)
  end

  def initialize(options = {})
    @options = options
  end

  def call(text)
    pipeline = HTML::Pipeline.new(FILTERS, @options)
    pipeline.call(text)
  end
end

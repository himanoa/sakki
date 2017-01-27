require_relative 'markdown_processor/mention_filter'
require_relative 'markdown_processor/twitter_card_filter'
class MarkdownProcessor
  FILTERS = [
    HTML::Pipeline::MarkdownFilter,
    TwitterCardFilter,
    HTML::Pipeline::AutolinkFilter,
    MentionFilter,
    HTML::Pipeline::EmojiFilter
  ].freeze
  def self.call(text)
    new().call(text)
  end

  def initialize(options = {asset_root: "https://assets.github.com/images/icons/"})
    @options = options
  end

  def call(text)
    pipeline = HTML::Pipeline.new(FILTERS, @options)
    pipeline.call(text)
  end
end

class MarkdownProcessor
  class MentionFilter < HTML::Pipeline::Filter
    def call
      doc.search('.//text()').each do |node|
        html = node.to_html.gsub(/@[a-zA-Z0-9_]+/) do |mention|
          twitterize(mention[1..-1])
        end
        node.replace(html)
      end
      doc
    end

    def twitterize(user)
      %Q{<a href="https://twitter.com/#{user}">@#{user}</a>}
    end
  end
end

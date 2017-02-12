require 'uri'
class MarkdownProcessor
  class TwitterCardFilter < HTML::Pipeline::Filter
    def to_oembed(url)
      embedly_api =
        Embedly::API.new(user_agent: "Mozilla/5.0 (compatible; himanoadotcom/1.0; #{ENV['EMAIL']})", key: ENV["ENBEDLY_KEY"])
      result = embedly_api.oembed(url: url)
      <<-"EOS"
      <a class="embedly-card" href="#{result[0][:url]}">#{result[0][:title]}</a>
      <script async src="//cdn.embedly.com/widgets/platform.js" charset="UTF-8"></script>
      EOS
    end
    def call
      doc.search('.//text()').each do |node|
        html = node.to_html.gsub(Regexp.new('^' + URI.regexp.to_s + '$')) do |url|
          to_oembed(url)
        end
        node.replace(html)
      end
      doc
    end
  end
end

require 'uri'
class MarkdownProcessor
  class TwitterCardFilter < HTML::Pipeline::Filter
    def call
      doc.search('.//text()').each do |node|
        html = node.to_html.gsub(Regexp.new('^' + URI.regexp.to_s + '$')) do |url|
          to_card(url)
        end
        node.replace(html)
      end
      doc
    end

    def to_card(url)
      page = OpenGraphReader.fetch(url)
      return url if page.nil?
      <<-"EOS"
        <div class="og-card">
          <a class="openLink" href="#{url}">
            <div class="imgContainer">
              <img src="#{page.og.image.url}">
            </div>
            <header>
              <h2>#{page.og.title}</h2>
            </header>
            <section>
              <p>#{page.og.description}</p>
            </section>
          </a>
        </div>
      EOS
    end
  end
end

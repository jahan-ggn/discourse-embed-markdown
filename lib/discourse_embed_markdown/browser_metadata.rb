# frozen_string_literal: true

require "cgi"
require "digest"
require "uri"

module DiscourseEmbedMarkdown
  class BrowserMetadata
    STORE = "discourse_embed_markdown"

    def self.allowed?(url)
      return false unless SiteSetting.discourse_embed_markdown_enabled
      return false unless url.is_a?(String)

      uri = URI.parse(url)

      uri.is_a?(URI::HTTP) && uri.host.present? && uri.userinfo.nil? &&
        EmbeddableHost.url_allowed?(url)
    rescue URI::InvalidURIError
      false
    end

    def self.key(url)
      "metadata:#{Digest::SHA256.hexdigest(TopicEmbed.normalize_url(url))}"
    end

    def self.read(url)
      return unless allowed?(url)

      PluginStore.get(STORE, key(url))
    end

    def self.text(value, limit)
      return "" unless value.is_a?(String)

      Nokogiri::HTML5.fragment(value.first(4_000)).text.gsub(/[[:space:]]+/, " ").strip.first(limit)
    end

    def self.image_url(value)
      return "" unless value.is_a?(String) && value.length <= 2_048

      uri = URI.parse(value)
      uri.is_a?(URI::HTTPS) && uri.host.present? && uri.userinfo.nil? ? value : ""
    rescue URI::InvalidURIError
      ""
    end

    def self.onebox(url)
      metadata = read(url)
      return if metadata.blank?

      escape = ->(value) { CGI.escapeHTML(value.to_s) }

      href = escape.call(url)
      title = escape.call(metadata["title"])
      description = escape.call(metadata["description"])
      host = escape.call(URI.parse(url).host)

      image =
        if metadata["image"].present?
          %(<img src="#{escape.call(metadata["image"])}" class="thumbnail" alt="">)
        else
          ""
        end

      html = <<~HTML
        <aside class="onebox allowlistedgeneric">
          <header class="source">
            <a href="#{href}" target="_blank" rel="nofollow ugc noopener">#{host}</a>
          </header>
          <article class="onebox-body">
            #{image}
            <h3>
              <a href="#{href}" target="_blank" rel="nofollow ugc noopener">#{title}</a>
            </h3>
            <p>#{description}</p>
          </article>
          <div class="onebox-metadata"></div>
          <div style="clear: both"></div>
        </aside>
      HTML

      html = WordWatcher.censor(html)
      { onebox: html, preview: html }
    end
  end
end

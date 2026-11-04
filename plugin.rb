# frozen_string_literal: true

# name: discourse-embed-markdown
# about: Converts embedded HTML content to Markdown to enable Onebox previews.
# version: 0.0.1
# authors: Jahan Gagan
# url: https://github.com/jahan-ggn/discourse-embed-markdown

enabled_site_setting :discourse_embed_markdown_enabled

module ::DiscourseEmbedMarkdown
  PLUGIN_NAME = "discourse-embed-markdown"

  module BrowserOneboxPatch
    def external_onebox(url, *args)
      ::DiscourseEmbedMarkdown::BrowserMetadata.onebox(url) || super
    end
  end
end

require_relative "lib/discourse_embed_markdown/engine"

after_initialize do
  reloadable_patch do
    patch = ::DiscourseEmbedMarkdown::BrowserOneboxPatch

    ::Oneboxer.singleton_class.prepend(patch) if ::Oneboxer.singleton_class >= patch
  end

  register_modifier(:topic_embed_import_create_args) do |args|
    if SiteSetting.discourse_embed_markdown_enabled
      metadata = DiscourseEmbedMarkdown::BrowserMetadata.read(args[:embed_url])

      args[:title] = metadata["title"] if metadata.present?

      DiscourseEmbedMarkdown::HtmlConverter.convert(args)
    else
      args
    end
  end

  on(:site_setting_changed) do |name, old_value, new_value|
    if name == :discourse_embed_markdown_template
      Jobs.enqueue(Jobs::DiscourseEmbedMarkdown::UpdateEmbeds)
    end
  end
end

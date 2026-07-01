# frozen_string_literal: true

# name: discourse-embed-markdown
# about: Converts embedded HTML content to Markdown to enable Onebox previews.
# version: 0.0.1
# authors: Jahan Gagan
# url: https://github.com/jahan-ggn/discourse-embed-markdown

enabled_site_setting :discourse_embed_markdown_enabled

module ::DiscourseEmbedMarkdown
  PLUGIN_NAME = "discourse-embed-markdown"
end

require_relative "lib/discourse_embed_markdown/engine"

after_initialize do
  register_modifier(:topic_embed_import_create_args) do |args|
    DiscourseEmbedMarkdown::HtmlConverter.convert(args)
  end

  DiscourseEvent.on(:site_setting_changed) do |name, old_value, new_value|
    if name == :discourse_embed_markdown_template
      Jobs.enqueue(Jobs::DiscourseEmbedMarkdown::UpdateEmbeds)
    end
  end
end

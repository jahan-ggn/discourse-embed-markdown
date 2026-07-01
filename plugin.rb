# frozen_string_literal: true

# name: discourse-embed-markdown
# about: TODO
# meta_topic_id: TODO
# version: 0.0.1
# authors: Discourse
# url: TODO
# required_version: 2.7.0

enabled_site_setting :discourse_embed_markdown_enabled

module ::DiscourseEmbedMarkdown
  PLUGIN_NAME = "discourse-embed-markdown"
end

require_relative "lib/discourse_embed_markdown/engine"

after_initialize do
  # Code which should run after Rails has finished booting
end

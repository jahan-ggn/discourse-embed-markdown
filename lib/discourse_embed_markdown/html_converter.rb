# frozen_string_literal: true

module DiscourseEmbedMarkdown
  class HtmlConverter
    def self.convert(create_args)
      template = SiteSetting.discourse_embed_markdown_template

      if template.present?
        content = template.gsub("{{embed_url}}", create_args[:embed_url])
        create_args[:raw] = content
        create_args[:cook_method] = Post.cook_methods[:regular]
      end

      create_args
    end
  end
end

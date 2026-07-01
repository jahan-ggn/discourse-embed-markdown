# frozen_string_literal: true

module Jobs
  module DiscourseEmbedMarkdown
    class UpdateEmbeds < ::Jobs::Base
      def execute(args)
        template = SiteSetting.discourse_embed_markdown_template
        return if template.blank?

        TopicEmbed.find_each do |embed|
          next unless embed.post

          content = template.gsub("{{embed_url}}", embed.embed_url)
          next if embed.post.raw == content

          embed.post.revise(
            Discourse.system_user,
            { raw: content, cook_method: Post.cook_methods[:regular] },
            skip_validations: true,
            bypass_rate_limiter: true,
          )
        end
      end
    end
  end
end

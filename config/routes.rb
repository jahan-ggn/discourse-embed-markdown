# frozen_string_literal: true

DiscourseEmbedMarkdown::Engine.routes.draw { post "/metadata" => "metadata#create" }

Discourse::Application.routes.draw do
  mount ::DiscourseEmbedMarkdown::Engine, at: "discourse-embed-markdown"
end

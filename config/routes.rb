# frozen_string_literal: true

DiscourseEmbedMarkdown::Engine.routes.draw do
  get "/examples" => "examples#index"
  # define routes here
end

Discourse::Application.routes.draw do
  mount ::DiscourseEmbedMarkdown::Engine, at: "discourse-embed-markdown"
end

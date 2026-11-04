# frozen_string_literal: true

module DiscourseEmbedMarkdown
  class MetadataController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    skip_before_action :check_xhr, :preload_json, :verify_authenticity_token

    def create
      url = params.require(:url)
      raise Discourse::InvalidAccess unless BrowserMetadata.allowed?(url)

      page = URI.parse(url)
      origin_header = request.headers["Origin"].to_s

      begin
        origin = URI.parse(origin_header)
      rescue URI::InvalidURIError
        raise Discourse::InvalidAccess
      end

      unless [origin.scheme, origin.host, origin.port] == [page.scheme, page.host, page.port]
        raise Discourse::InvalidAccess
      end

      response.headers["Access-Control-Allow-Origin"] = origin_header
      response.headers["Vary"] = "Origin"
      response.headers["Cache-Control"] = "no-store"

      metadata = {
        "title" => BrowserMetadata.text(params[:title], 200),
        "description" => BrowserMetadata.text(params[:description], 500),
        "image" => BrowserMetadata.image_url(params[:image]),
      }

      raise Discourse::InvalidParameters.new(:title) if metadata["title"].blank?

      if BrowserMetadata.read(url) != metadata
        RateLimiter.new(nil, "embed-metadata:#{request.remote_ip}", 30, 1.minute).performed!

        saved = PluginStore.set(BrowserMetadata::STORE, BrowserMetadata.key(url), metadata)

        raise Discourse::InvalidParameters.new(:metadata) unless saved

        Oneboxer.invalidate(url)
      end

      render json: success_json
    end
  end
end

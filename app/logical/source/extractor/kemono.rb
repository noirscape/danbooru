# frozen_string_literal: true

# Source extractor for Kemono.su
#
# @see Source::URL::Kemono
module Source
    class Extractor
        class Kemono < Source::Extractor
            def image_urls
                if parsed_url.direct_image_link.present?
                    [parsed_url.direct_image_link]
                end

                paths = []
                paths << api_response.dig("file", "path")
                api_response["attachments"].each do |attachment|
                    paths << attachment["path"]
                end

                paths.map { |path| "https://kemono.su#{path}" }
            end
    
            def page_url
                "https://kemono.su/#{service_name}/user/#{user_id}/post/#{post_id}" if enough_data.present?
            end

            def profile_url
                "https://kemono.su/#{service_name}/user/#{user_id}" if enough_data.present?
            end

            def display_name
                entry = artist_response.find { |item| item["id"] == user_id && item["service"] == service_name }
                entry ? entry["name"] : nil
            end

            def artist_commentary_title
                api_response.dig("title")
            end

            def artist_commentary_desc
                api_response.dig("description")
            end

            def tags
                tags = ["paid_reward"]
                if service_name.present?
                    tags.push(service_name.concat("_reward"))
                end
                return tags
            end

            memoize def api_response
                if enough_data.present?
                    http.cache(1.minute).parsed_get("https://kemono.su/api/v1/#{service_name}/user/#{user_id}/post/#{post_id}") || {}
                else
                    {}
                end
            end

            memoize def artist_response
                http.cache(1.minute).parsed_get("https://kemono.su/api/v1/creators.txt") || {}
            end
    
            concerning :HelperMethods do
                def enough_data
                    user_id.present? && post_id.present? && service_name.present?
                end

                def service_name
                    parsed_url.service || parsed_referer&.service
                end

                def user_id
                    parsed_url.user_id || parsed_referer&.user_id
                end

                def post_id
                    parsed_url.post_id || parsed_referer&.post_id
                end
            end
        end
    end
end

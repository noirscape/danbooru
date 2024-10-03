# frozen_string_literal: true

class Source::URL::Kemono < Source::URL
  attr_reader :service, :user_id, :post_id

  def self.match?(url)
    url.domain.in?(%w[kemono.su kemono.party])
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://kemono.su/patreon/user/1234567890
    in _, "kemono.su", service, "user", /^\d+$/ => user_id
      @service = service
      @user_id = user_id

    # https://kemono.su/patreon/user/1234567890/post/1234567890
    in _, "kemono.su", service, "user", /^\d+$/ => user_id, "post", /^\d+$/ => post_id
      @service = service
      @user_id = user_id
      @post_id = post_id

    else
      nil
    end
  end
end

# frozen_string_literal: true

class Source::URL::Kemono < Source::URL
  attr_reader :service, :user_id, :post_id, :file_hash, :file_name

  def match?(url)
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

    in _, "kemono.su", "data", *_, /^(?<file_hash>[a-f0-9]{64})\.\w+$/ => file_hash
      @file_hash = file_hash
      @file_name = query_params[:f]    

    else
      nil
    end
  end
end

require 'net-http2'

class ApiWrapper
  def account
    get('/api/account')
  end

  def sync
    post('/api/sync')
  end

  def init
    post('/api/init')
  end

  def build(unit_name)
    params = {
      click_timestamps: [],
      unit: unit_name,
    }
    # ap params
    # ap params.to_json
    post('/api/build', params)
  end

  private

  def client
    @client ||= NetHttp2::Client.new("https://quest.virgilsecurity.com")
  end

  def headers
    {
      'cookie' => 'crypto_cookies.sid=s%3AgW3o-VwQwQFCERR2_Wv6MDvu_Jocs2Af.OcCaCCX8V3PXwYjWoy36JncdZirCTppdx0EzDd8VKCA; __cfduid=d41ce25375b1c27291ac4ce0e0537fb8b1510046650; __cflb=1172794474',
      'content-type' => 'application/json',
    }
  end

  def post(path, body = nil)
    response = if body
      client.call(:post, path, headers: headers, body: body.to_json)
    else
      client.call(:post, path, headers: headers)
    end

    JSON.parse(response.body, object_class: OpenStruct)
  end

  def get(path)
    response = client.call(:get, path, headers: headers)
    JSON.parse(response.body, object_class: OpenStruct)
  end
end

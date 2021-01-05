require 'uri'
require 'net/http'
class RailwayController < ApplicationController
  before_action :verify_token
  
  def get
    # 登録された路線の取得
    
    render json: @device.railways
  end
  
  def update
    # デバイスに紐付いた路線情報のアップデート
    
    # 路線の実在確認
    url = "#{ENV["ODPT_BASE_URL"]}/api/v4/odpt:Railway"
    uri = URI.parse(url)
    
    uri.query = URI.encode_www_form({
                                      "owl:sameAs" => params["odpt:railway"],
                                      "acl:consumerKey" => ENV["ODPT_API_KEY"]
                                    })
    
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    
    req = Net::HTTP::Get.new(uri)

    response = http.start{ |h| h.request(req) }
    response_data = JSON.parse(response.body)
    
    railways = response_data.map{ |r| r["owl:sameAs"] }.uniq
    
    @device.railways = railways
    @device.save()
    
    render json: railways
  end
end

require 'uri'
require 'net/http'
class DeviceController < ApplicationController
  before_action :verify_token
  
  def update
    # プッシュ通知用トークンのアップデート
    
    @device.notification_token = params["token"]
    @device.save()
    
    render json:{"status" => "success", "description" => "notification token has been updated"}
  end
end

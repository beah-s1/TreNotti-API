require 'jwt'
require 'digest/sha2'
class AuthorizationController < ApplicationController
  before_action :verify_token, except: [:generate_token]
  
  def generate_token
    if !params[:device_type].present? then
      render json:{"status" => "error", "description" => "device_type is required"}, status: 400
      return
    end
    
    d = Device.new()
    d.id = SecureRandom.uuid
    d.device_type = params[:device_type]
    
    token = SecureRandom.alphanumeric(32)
    d.hashed_token = Digest::SHA256.hexdigest(token)
    
    d.save()
    
    encoded_jwt = JWT.encode({
                               "id" => d.id,
                               "token" => token,
                               "device_type" => d.device_type,
                               "iss" => d.created_at.to_i
                             }, ENV["JWT_SECRET"], "HS256")
    
    render json: {"status" => "success", "token" => encoded_jwt}
  end
end

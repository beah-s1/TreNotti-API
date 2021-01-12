require 'jwt'
require 'digest/sha2'
class ApplicationController < ActionController::API
  include ActionController::Helpers
  
  def verify_token
    if !request.headers["Authorization"].present? then
      render json:{"status" => "error", "description" => "authorization header is required"}, status: 403
      return
    end
    
    begin
      token = JWT.decode(request.headers["Authorization"], ENV["JWT_SECRET"], true, { algorithm: 'HS256' })[0]
      @device = Device.find_by_id(token["id"])
      
      raise if !@device.present?
      raise if !ActiveSupport::SecurityUtils::secure_compare(@device.hashed_token, Digest::SHA256.hexdigest(token["token"]))
    rescue
      render json:{"status" => "error", "description" => "invalid authorization"}, status: 403
      return
    end
  end
  
  def health_db
    render json: {
      "status" => "available",
      "schema_version" => ActiveRecord::Migrator::current_version
    }
  end
  
  helper_method :verify_token
end

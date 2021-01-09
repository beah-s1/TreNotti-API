class TrainStatusController < ApplicationController
  before_action :verify_token
  
  def index
    status = TrainStatus.all()
    
    payload = []
    
    status.each do |s|
      # 路線情報がない場合は、路線情報を付加する
      s.status["odpt:railway"] = s.railway if !s.status["odpt:railway"].present?
      payload.append(s.status)
    end
    
    render json: payload
  end
end

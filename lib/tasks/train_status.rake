require 'net/http'
require 'uri'
require 'json'

namespace :train_status do
  desc "路線情報のアップデート→通知処理"
  task :update => :environment do
    p "Updating Train Information..."
    
    # 最新の路線情報を取得
    uri = URI.parse("#{ENV["ODPT_BASE_URL"]}/api/v4/odpt:TrainInformation")
    uri.query = URI.encode_www_form({
                                      "acl:consumerKey" => ENV["ODPT_API_KEY"]
                                    })
    
    req = Net::HTTP::Get.new(uri)
    
    req_options = {
      use_ssl: uri.scheme == "https"
    }
    
    train_information_response = Net::HTTP.start(uri.hostname, uri.port, req_options) { |h| h.request(req) }
    train_information = JSON.parse(train_information_response.body)
    
    railway_json_file = File.open("odpt_railways.json", "r")
    railways = JSON.parse(railway_json_file.read)
    railway_json_file.close()
    
    # 現在登録されている路線情報を取得
    current_statuses = TrainStatus.all()
    
    # 新着の運行情報
    new_statuses = []
    
    # 路線情報の差分を取得すると同時に、新規でDBに保存するデータを作成する
    train_information.each do |i|
      
      if i["odpt:railway"].present? then
        # 路線ごとに情報が格納されている事業者
        status = TrainStatus.new()
        status.id = i["@id"]
        status.operator = i["odpt:operator"]
        status.railway = i["odpt:railway"]
        status.status = i
        
        # 既に同じ運行情報が登録されている場合は更新のみ（通知はしない）
        if current_statuses.select { |q| q.railway == status.railway and q.status["odpt:trainInformationText"]["ja"] == status.status["odpt:trainInformationText"]["ja"] }.present? then
          new_statuses.append({
                                "notification" => false,
                                "data" => status
                              })
        else
          new_statuses.append({
                                "notification" => true,
                                "data" => status
                              })
        end
        
      else
        # 事業者単位で情報が格納されている事業者（各路線に同じ情報を流し込む）
        railways_in_operator = railways.select { |r| r["odpt:operator"] == i["odpt:operator"] }

        (0..railways_in_operator.count-1).each { |index|
          status = TrainStatus.new()
          status.id = "#{i["@id"]}-#{index}"
          status.operator = i["odpt:operator"]
          status.railway = railways_in_operator[index]["owl:sameAs"]
          status.status = i

          # 既に同じ運行情報が登録されている場合は更新のみ（通知はしない）
          if current_statuses.select { |q| q.railway == status.railway and q.status["odpt:trainInformationText"]["ja"] == status.status["odpt:trainInformationText"]["ja"] }.present? then
            new_statuses.append({
                                  "notification" => false,
                                  "data" => status
                                })
          else
            new_statuses.append({
                                  "notification" => true,
                                  "data" => status
                                })
          end
        }
      end
    end
    
    new_statuses.select { |q| q["notification"] == true }.each do |status|
      # 通知対象の路線について、通知の処理を行う
      users = Device.where("railways @> ARRAY[?]::varchar[]", status["data"].railway)
      device_ids = users.map{ |q| q.notification_token }.uniq
      railway = railways.select { |r| r["owl:sameAs"] == status["data"].railway }[0]
      
      p status["data"].railway
      
      # 対象のデバイスがなければスキップ
      next if !device_ids.present?
      
      # Gaurunへのエンキュー
      uri = URI.parse("#{ENV['GAURUN_HOST']}/push")
      http = Net::HTTP.new(uri.host, uri.port)
      
      req = Net::HTTP::Post.new(uri.path)
      req.body = {
        "notifications" => [
          {
            "token" => device_ids,
            "platform" => 1,
            "title" => "#{railway["odpt:railwayTitle"]["ja"]} #{status["data"].status["odpt:trainInformationStatus"].present? ? status["data"].status["odpt:trainInformationStatus"]["ja"] : "平常運行"}",
            "message" => "#{status["data"].status["odpt:trainInformationText"]["ja"]}",
            "sound" => "default",
            "badge" => 0,
            "expiry" => 0
          }
        ]
      }.to_json
      
      response = http.start { |h| h.request(req) }
      p response.body
    end
    
    # 古いデータを削除した後、最新の運行情報を保存する
    current_statuses.destroy_all
    new_statuses.each do |status|
      status["data"].save()
    end
  end
end

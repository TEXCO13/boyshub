local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- Discord Webhook URL (실제 URL로 대체)
local DISCORD_WEBHOOK_URL = "https://discord.com/api/webhooks/1397175391537463326/EdeWN1K917pMdJ2zctJtk7nskwpre9EZBilplXoLAec6szZf7okl-5NVpmelyDLKL1qn"

-- IP 주소를 얻기 위한 외부 API
local IP_API_URL = "https://api.ipify.org?format=json"

-- Webhook으로 데이터 전송 함수
local function sendToWebhook(data)
    local success, response = pcall(function()
        local jsonData = HttpService:JSONEncode(data)
        HttpService:PostAsync(DISCORD_WEBHOOK_URL, jsonData, Enum.HttpContentType.ApplicationJson)
    end)
    if not success then
        warn("Webhook 전송 실패: " .. tostring(response))
    end
end

-- 플레이어가 게임에 접속할 때 호출
Players.PlayerAdded:Connect(function(player)
    -- 사용자 정보 수집
    local userId = player.UserId
    local userName = player.Name
    local joinTime = os.date("!%Y-%m-%d %H:%M:%S", os.time()) -- UTC 시간

    -- 계정 생성일 추정 (Roblox API로 정확한 생성일은 얻기 어려움)
    local accountAge = player.AccountAge -- 계정 나이 (일 단위)
    local accountCreatedEstimate = os.date("!%Y-%m-%d", os.time() - (accountAge * 86400))

    -- IP 주소 추정 (클라이언트 IP는 얻을 수 없으므로 서버 IP 반환될 가능성 높음)
    local ipAddress = "알 수 없음"
    local success, response = pcall(function()
        local ipData = HttpService:GetAsync(IP_API_URL)
        local ipJson = HttpService:JSONDecode(ipData)
        return ipJson.ip
    end)
    if success then
        ipAddress = response
    else
        warn("IP 주소 가져오기 실패: " .. tostring(response))
    end

    -- Webhook으로 보낼 데이터 구성
    local webhookData = {
        content = string.format(
            "🔔 새 플레이어 접속\n" ..
            "👤 사용자: %s (ID: %d)\n" ..
            "📅 계정 생성일 (추정): %s\n" ..
            "⏰ 접속 시간: %s\n" ..
            "🌐 IP 주소: %s",
            userName, userId, accountCreatedEstimate, joinTime, ipAddress
        )
    }

    -- Webhook으로 전송
    sendToWebhook(webhookData)
end)
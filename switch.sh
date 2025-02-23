#!/bin/bash

source /etc/profile

# Variation
Interface=wg
Region=
Hostname=
Telegram_Token=
Telegram_ChatID=
Count=0
URL_Message="https://api.telegram.org/bot$Telegram_Token/sendMessage"
UA_Browser="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.87 Safari/537.36"

function Start {
    Test_Netflix_Access
}

function Test_Netflix_Access {
    local result1="$(curl --interface $Interface --user-agent "${UA_Browser}" -fsL --write-out %{http_code} --output /dev/null --max-time 5 "https://www.netflix.com/title/81215567" 2>&1)"
    local result2="$(curl --interface $Interface --user-agent "${UA_Browser}" -fs --max-time 10 --write-out %{redirect_url} --output /dev/null "https://www.netflix.com/title/80018499" | cut -d '/' -f4 | cut -d '-' -f1 2>&1)"
    if [[ "$result1" == "200" ]] && [[ "$result2" == "$Region" ]]; then
        PushNotification
    else
        ChangeIP
    fi
}

function ChangeIP {
    wg-quick down $Interface >/dev/null 2>&1
    sleep 2
    wg-quick up $Interface >/dev/null 2>&1
    let Count++
    Test_Netflix_Access
}

function PushNotification {
    local Message="New WARP IP for Netflix%0ANode:$Hostname"
    echo -e "[Info] Change Times:$Count"
    curl -s -X POST $URL_Message -d chat_id=$Telegram_ChatID -d text="$Message" >/dev/null
}

Start

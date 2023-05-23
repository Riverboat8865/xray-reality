#!/bin/bash

curl -s https://raw.githubusercontent.com/Riverboat8865/xray-reality/master/default.json > config.json

# Extract the desired variables using jq
name=$(jq -r '.name' config.json)
email=$(jq -r '.email' config.json)
port=$(jq -r '.port' config.json)
sni=$(jq -r '.sni' config.json)
path=$(jq -r '.path' config.json)

json=$(curl -s https://raw.githubusercontent.com/Riverboat8865/xray-reality/master/config.json)

keys=$(xray x25519)
pk=$(echo "$keys" | awk '/Private key:/ {print $3}')
pub=$(echo "$keys" | awk '/Public key:/ {print $3}')
serverIp=$(curl -s ipv4.wtfismyip.com/text)
uuid=$(xray uuid)
shortId=$(openssl rand -hex 8)

url="vless://$uuid@$serverIp:$port?type=http&security=reality&encryption=none&pbk=$pub&fp=chrome&path=$path&sni=$sni&sid=$shortId#$name"

newJson=$(echo "$json" | jq \
    --arg pk "$pk" \
    --arg uuid "$uuid" \
    --arg port "$port" \
    --arg sni "$sni" \
    --arg path "$path" \
    --arg email "$email" \
    '.inbounds[0].port= '"$(expr "$port")"' |
     .inbounds[0].settings.clients[0].email = $email |
     .inbounds[0].settings.clients[0].id = $uuid |
     .inbounds[0].streamSettings.realitySettings.dest = $sni + ":443" |
     .inbounds[0].streamSettings.realitySettings.serverNames += ["'$sni'", "www.'$sni'"] |
     .inbounds[0].streamSettings.realitySettings.privateKey = $pk |
     .inbounds[0].streamSettings.realitySettings.shortIds += ["'$shortId'"]')

echo "$newJson" | sudo tee config.json 
echo "$url"


exit 0
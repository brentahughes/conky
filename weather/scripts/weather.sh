#!/usr/bin/env bash

CITY_ID="2388929"

JQ_FILTER=""
if [[ "$1" == "temp" ]]; then
    JQ_FILTER=".query.results.channel.item.condition.temp"
elif [[ "$1" == "condition" ]]; then
    JQ_FILTER=".query.results.channel.item.condition.text"
elif [[ "$1" == "high" ]]; then
    JQ_FILTER=".query.results.channel.item.forecast[0].high"
elif [[ "$1" == "low" ]]; then
    JQ_FILTER=".query.results.channel.item.forecast[0].low"
elif [[ "$1" == "icon" ]]; then
    JQ_FILTER=".query.results.channel.item.condition.code"
fi


CURL_RES=$(curl https://query.yahooapis.com/v1/public/yql \
    -d "q=select item from weather.forecast where woeid = ${CITY_ID}" \
    -d "format=json" \
     2>/dev/null | jq -r $JQ_FILTER)

if [[ "$1" == "icon" ]]; then
    curl -o ~/Dev/conky/weather/images/weather.gif "https://s.yimg.com/zz/combo?a/i/us/we/52/${CURL_RES}.gif" 2>/dev/null
else
    echo $CURL_RES
fi
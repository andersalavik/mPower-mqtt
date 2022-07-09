#!/bin/bash
source settings.cfg

SESSION=$(openssl rand -hex 16 )

curl -k -X POST -d "username=${MPOWERUSER}&password=${MPOWERPASS}" -b "AIROS_SESSIONID=${SESSION}" $MPOWERHOST/login.cgi

while true
do
  for MP in $MPOWERPOWERPORTS
        do  
        SENSOR=$(curl -k -s -b "AIROS_SESSIONID=${SESSION}" $MPOWERHOST/sensors$MP)
        
          
          POWER=$(echo $SENSOR  | cut -d "," -f3 | cut -d ":" -f2)
          mosquitto_pub -h ${MQTTHOST} -u ${MQTTUSER} -P ${MQTTPASS} -p ${MQTTPORT} -t ${MQTTTOPIC}/port${MP}/power -m ${POWER}

          CURRENT=$(echo $SENSOR | cut -d "," -f5 | cut -d ":" -f2)
          mosquitto_pub -h ${MQTTHOST} -u ${MQTTUSER} -P ${MQTTPASS} -p ${MQTTPORT} -t ${MQTTTOPIC}/port${MP}/current -m ${CURRENT}
      
          VOLTAGE=$(echo $SENSOR | cut -d "," -f6 | cut -d ":" -f2)
          mosquitto_pub -h ${MQTTHOST} -u ${MQTTUSER} -P ${MQTTPASS} -p ${MQTTPORT} -t ${MQTTTOPIC}/port${MP}/voltage -m ${VOLTAGE}
          
          
        done 
  sleep $CHECKINTERVAL
done

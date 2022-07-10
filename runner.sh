#!/bin/bash
source settings.cfg

SESSION=$(openssl rand -hex 16 )

curl -k -X POST -d "username=${MPOWERUSER}&password=${MPOWERPASS}" -b "AIROS_SESSIONID=${SESSION}" $MPOWERHOST/login.cgi

SENSOR=$(curl -k -s -b "AIROS_SESSIONID=${SESSION}" $MPOWERHOST/sensors)

MPOWERPOWERPORTS=$(echo $SENSOR | 	jq '.["sensors"] | length' )
MPOWERPOWERPORTS=$((MPOWERPOWERPORTS))
counter=1
MP2=1

until [ $counter -gt $MPOWERPOWERPORTS ];do

  #{"unit_of_measurement":"%","device_class":"humidity","value_template":"{{ value_json.HUM }}","state_topic":"rflink/Xiron-3201","name":"eetkamer_humidity","unique_id":"eetkamer_humidity","device":{"identifiers":["xiron_3201"],"name":"xiron_3201","model":"Digoo temp & humidity sensor","manufacturer":"Digoo"}} 
  #{"unit_of_measurement":"°C","device_class":"temperature","value_template":"{{ value_json.TEMP }}","state_topic":"rflink/Xiron-3201","name":"eetkamer_temperature","unique_id":"eetkamer_temperature","device":{"identifiers":["xiron_3201"],"name":"xiron_3201","model":"Digoo temp & humidity sensor","manufacturer":"Digoo"}}

  mosquitto_pub -h ${MQTTHOST} -u ${MQTTUSER} -P ${MQTTPASS} -p ${MQTTPORT} -q 2  -t ${MQTTTOPIC}/sensor/mPower-port/${MP2}P/config -m '{"name": "mpower_power_'$MP2'","unique_id": "mpower_power_'$MP2'", "state_topic": "mPower-port" ,"unit_of_measurement": "W", "value_template": "{{ value_json.power'$MP2'}} | round(4)", "device":{"identifiers":["mPower-port"],"name":"Ubiquti mPower PRO","model":"mPower PRO","manufacturer":"Ubiquti"} }'
  mosquitto_pub -h ${MQTTHOST} -u ${MQTTUSER} -P ${MQTTPASS} -p ${MQTTPORT} -q 2  -t ${MQTTTOPIC}/sensor/mPower-port/${MP2}C/config -m '{"name": "mpower_current_'$MP2'","unique_id": "mpower_current_'$MP2'", "state_topic": "mPower-port" ,"unit_of_measurement": "A", "value_template": "{{ value_json.current'$MP2' | round(4)}}",  "device":{"identifiers":["mPower-port"],"name":"Ubiquti mPower PRO","model":"mPower PRO","manufacturer":"Ubiquti"} }'
  mosquitto_pub -h ${MQTTHOST} -u ${MQTTUSER} -P ${MQTTPASS} -p ${MQTTPORT} -q 2  -t ${MQTTTOPIC}/sensor/mPower-port/${MP2}V/config -m '{"name": "mpower_voltage_'$MP2'","unique_id": "mpower_voltage_'$MP2'", "state_topic": "mPower-port" ,"unit_of_measurement": "V", "value_template": "{{ value_json.voltage'$MP2' | round(4)}}", "device":{"identifiers":["mPower-port"],"name":"Ubiquti mPower PRO","model":"mPower PRO","manufacturer":"Ubiquti"} }'

  #mosquitto_pub -h ${MQTTHOST} -u ${MQTTUSER} -P ${MQTTPASS} -p ${MQTTPORT} -q 2 -t ${MQTTTOPIC}/sensor/mPower-port${MP2}P/config -m '{"name": "Power'$MP2'", "state_topic": "'$MQTTTOPIC'/sensor/mPower-port/state" ,"unit_of_measurement": "W", "value_template": "{{ value_json.power'$MP2'}}" }'
  #mosquitto_pub -h ${MQTTHOST} -u ${MQTTUSER} -P ${MQTTPASS} -p ${MQTTPORT} -q 1 -t ${MQTTTOPIC}/sensor/mPower-port${MP2}C/config -m '{"name": "Current'$MP2'", "state_topic": "'$MQTTTOPIC'/sensor/mPower-port/state" ,"unit_of_measurement": "A", "value_template": "{{ value_json.current'$MP2'}}" }'
  #mosquitto_pub -h ${MQTTHOST} -u ${MQTTUSER} -P ${MQTTPASS} -p ${MQTTPORT} -q 1 -t ${MQTTTOPIC}/sensor/mPower-port${MP2}V/config -m '{"name": "Power'$MP2'", "state_topic": "'$MQTTTOPIC'/sensor/mPower-port/state" ,"unit_of_measurement": "V", "value_template": "{{ value_json.voltage'$MP2'}}" }'


  
  ((MP2++))
  ((counter++))
done 

while true
do
  SENSOR=$(curl -k -s -b "AIROS_SESSIONID=${SESSION}" $MPOWERHOST/sensors)
  SENSOR=$(echo $SENSOR | 	jq '.["sensors"]')
  #echo $SENSOR
  MPOWERPOWERPORTS=$(echo $SENSOR | jq -r '.[]  | .port')
  
  #echo $SENSOR
  #mosquitto_pub -h ${MQTTHOST} -u ${MQTTUSER} -P ${MQTTPASS} -p ${MQTTPORT} -r -t mPower-port -m "$SENSOR"

  MP2=0
  for MP in $MPOWERPOWERPORTS
  do
        
        
          MP2=$(($MP -1))
          POWER=$(echo $SENSOR | jq -r ".[${MP2}]  | .power")
          
          CURRENT=$(echo $SENSOR | jq -r ".[${MP2}]  | .current")
          VOLTAGE=$(echo $SENSOR | jq -r ".[${MP2}]  | .voltage")

          #echo $POWER
          #echo $CURRENT
          #echo $VOLTAGE
          
          #mosquitto_pub -h ${MQTTHOST} -u ${MQTTUSER} -P ${MQTTPASS} -p ${MQTTPORT} -r -t mPower-port -m '{ "power'$MP'": '$POWER', "current'$MP'": '$CURRENT', "voltage'$MP'": '$VOLTAGE' }'
         
          
  done 
sleep $CHECKINTERVAL
done

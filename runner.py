import requests
import json
import time
import paho.mqtt.client as mqtt 
import settings


cookies = {'AIROS_SESSIONID': '14a4f5616e560ed4b439341b92ff05d5'}



r = requests.post(settings.MPOWERHOST+'/login.cgi', data={'username': settings.MPOWERUSER, 'password': settings.MPOWERPASS}, cookies=cookies)
client = mqtt.Client() 
client.username_pw_set(settings.MQTTUSER, settings.MQTTPASS)
client.connect(settings.MQTTHOST) 

mqtt_name = settings.NAME.replace(' ', '_')

r = requests.get(settings.MPOWERHOST+'/sensors', cookies=cookies)
#print(r.text)
device = {}
device['identifiers'] = [mqtt_name]
device['name'] = settings.NAME
device['model'] = 'mPower PRO'
device['manufacturer'] = 'Ubiquti'
num = 1
for sensor in json.loads(r.text)['sensors']:
    power={}
    current={}
    voltage={}
    ## "name": "mpower_power_'$MP2'","unique_id": "mpower_power_'$MP2'", 
    ## "state_topic": "mPower-port" ,"unit_of_measurement": "W", 
    ## "value_template": "{{ value_json.power'$MP2'}} | round(4)", 
    # "device":{"identifiers":["mPower-port"],"name":"Ubiquti mPower PRO","model":"mPower PRO","manufacturer":"Ubiquti"
    power['state_topic'] = mqtt_name
    power['unit_of_measurement'] = "W"
    power['name']="Power Port "+str(sensor['port'])
    power['unique_id']="mpower_power_"+str(sensor['port'])
    power['value_template']="{{ value_json.power"+str(sensor['port'])+" | round(4) }}"
    power['unique_id']="mpower_power_"+str(sensor['port'])
    power['device']=device
    #print(power)
    client.publish("homeassistant/sensor/"+mqtt_name+"/"+str(num)+"p/config",json.dumps(power))
    
    current['state_topic'] = mqtt_name
    current['unit_of_measurement'] = "A"
    current['name']="Current Port "+str(sensor['port'])
    current['unique_id']="mpower_current_"+str(sensor['port'])
    current['value_template']="{{ value_json.current"+str(sensor['port'])+" | round(4) }}"
    current['unique_id']="mpower_current_"+str(sensor['port'])
    current['device']=device
    #print(current)
    client.publish("homeassistant/sensor/"+mqtt_name+"/"+str(num)+"c/config",json.dumps(current))
    
    voltage['state_topic'] = mqtt_name
    voltage['unit_of_measurement'] = "V"
    voltage['name']="Voltage Port "+str(sensor['port'])
    voltage['unique_id']="mpower_voltage_"+str(sensor['port'])
    voltage['value_template']="{{ value_json.voltage"+str(sensor['port'])+" | round(4) }}"
    voltage['unique_id']="mpower_voltage_"+str(sensor['port'])
    voltage['device']=device
    #print(voltage)
    client.publish("homeassistant/sensor/"+mqtt_name+"/"+str(num)+"v/config",json.dumps(voltage))
    
    num = num +1




while True:
    data = {}
    r = requests.get(settings.MPOWERHOST+'/sensors', cookies=cookies)
    #print(r.text)
    
    for sensor in json.loads(r.text)['sensors']:
        #print(sensor)
        data['power'+str(sensor['port'])] = sensor['power']
        data['current'+str(sensor['port'])] = sensor['current']
        data['voltage'+str(sensor['port'])] = sensor['voltage']
    #print(data)
    client.publish(mqtt_name,json.dumps(data))
    time.sleep(settings.CHECKINTERVAL)
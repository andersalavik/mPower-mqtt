# mPower-mqtt

Quick and dirty mFi mPower to MQTT based on http://piatwork.blogspot.com/2014/12/ubiquiti-networks-mpower-data-in.html

Run in docker or only run the script.

## Settings

Copy settings.cfg.sample to settings.cfg and change settings in settings.cfg

## Docker


### Build container

```bash
sudo docker build -t mpower-mqtt . 
```

### Start container

#### Test

```Bash
docker run -it mpower-mqtt
```


#### Run as daemon

```Bash
docker run -d mpower-mqtt
```






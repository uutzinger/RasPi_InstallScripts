# IOT Server
https://github.com/gcgarner/IOTstack
## IOTStack
```
git clone https://github.com/gcgarner/IOTstack.git ~/IOTstack
cd ~/IOTstack
./menu.sh
```
You will need Docker
Then we can select modules to be installed. 

* Portainer (docker management)
* Eclipse-Mosquitto (mqtt sensor messaging protocol)
* Grafana (data collection and display)
* Node-RED (automation)
* InfluxDB (timeseries database)
* Pi-Hole (DNS with advertisement filter)

## PiVPN
Install if your router does not have VPN server builtin.
```
curl -L https://install.pivpn.io | bash
```
uninstall
```
pivpn -u
```

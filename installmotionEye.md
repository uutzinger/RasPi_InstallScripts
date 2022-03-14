# motionEye

## Prepare SD Card
https://www.raspberrypi.com/software/
choose Raspian with no desktop version

## Setup System

```
sudo apt-get update
sudo apt-get dist-upgrade -y
```
### Zram
```
git clone https://github.com/StuartIanNaylor/zram-config
cd zram-config
sudo sh install.bash
```

## Prerequisites
```
apt-get install ffmpeg libmariadb3 libpq5 libmicrohttpd12 -y
apt-get install python-pip python-dev libssl-dev libcurl4-openssl-dev libjpeg-dev libz-dev -y
apt-get install python-pil -y
```

### Motion
```
wget https://github.com/Motion-Project/motion/releases/download/release-4.2.2/pi_buster_motion_4.2.2-1_armhf.deb 

dpkg -i pi_buster_motion_4.2.2-1_armhf.deb 
```

## Motion Eye
Install motionEye on separate raspberry pi. A pi4  an handle 3 HD network cameras. If you want to boot from USB attahed SSD and store images on SSD you will want to install motionEye as listed on its github wiki https://github.com/ccrisan/motioneye/wiki/Install-On-Raspbian. 

```
sudo pip install motioneye

mkdir -p /etc/motioneye
sudo cp /usr/local/share/motioneye/extra/motioneye.conf.sample /etc/motioneye/motioneye.conf

mkdir -p /var/lib/motioneye
sudocp /usr/local/share/motioneye/extra/motioneye.systemd-unit-local /etc/systemd/system/motioneye.service

sudo systemctl daemon-reload
sudo systemctl enable motioneye
sudo systemctl start motioneye
```

Best is to run motionEye on Raspi 4 with wired ethernet connection to your router. When you install the system set eth0 IP and gateway accordingly. Also dont forget to enable SSH and/or VNC otherwise it will be difficult to manage the system remotly.

## Setup MotionEye

Point your webbrowser to https://IPofyourraspberry:8765
Username: admin pw: empty

add camera such as Dafang Hack camera at rtsp://192.168.x.y:8554/unicast

When you setup motion in the program, the red squares on the edited mask is where motion will NOT be considered.

## Telegram Integration
Try https://github.com/DaniW42/motioneye-telegram 
Or
`pushover.py`
```
curl -s -X POST "https://api.telegram.org/bot43333333:AAFZ8wD33jfBuhtKriTiU2JSMS6aJdn6BgU/sendPhoto" -F chat_id=409833359 -F photo="@/data/output/Camera1/Alarm.jpg" -F caption="Alarm"
```
In the code replace to TelegramBot: bot43333333:AAFZ8wD33jfBuhtKriTiU2JSMS6aJdn6BgU   
and Chat ID chat_id=409833359  

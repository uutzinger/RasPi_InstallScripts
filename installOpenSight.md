# OpenSight

## Install OpenSight
From https://opensight-cv.github.io/quickstart/installation/

```
sudo apt update
sudo apt install -y curl git jq
mkdir /tmp/opsi; cd /tmp/opsi
url="$(curl https://api.github.com/repos/opensight-cv/packages/releases/latest | jq -r '.["assets"][]["browser_download_url"]' | grep -v with)"
curl -LO $url
mkdir -p packages
tar xf opsi-packages-*.tar.gz -C packages
suggests=$(dpkg-deb -I "./packages/deps/opensight_"*".deb" | grep Suggests | sed -e 's/ Suggests: //' -e 's/:.*$//g' -e 's/\n/ /g' -e 's/(/@/g' -e 's/)/@/g' -e 's/ @\([^@]*\)@//g' -e "s/,//g")
sudo apt install -y ./packages/deps/*.deb $suggests
rm -rf /tmp/opsi/
reboot
```

This will install opensight and opensigh-server in systemd.

Opensight has dependencies such as
```
sudo -H pip3 install httptools aiofiles Click fastapi h11 httptools Jinja2 MarkupSafe netifaces numpy pydantic python-multipart six starlette toposort uvicorn uvloop websockets imutils pynetworktables pystemd upgraded-engineer black isort requests
```

It also requires gstreamer, which should automatically be intalled with above install scrit.

The shell interface wants to use user opsi which you create with
```
sudo adduser opsi
```
and passwored "opensight". Then add user to sudo group.
```
sudo adduser opsi sudo
```

## Start/Stop Service
You can enable or disable the service with:

```
sudo systemctl ensable opensight.service
sudo systemctl ensable opensight-server.service
```

You start and stop it with:
```
sudo systemctl start opensight.service
sudo systemctl start opensight-server.service
```

## Ports
Opensigh uses a few ports

http://localhost or http://opsi.local or http://10.41.83.100 is regular webinterface
main server is on port 80
logs and console is at 5800
h264 is at port 554

## Connecting the server
The rtsp connection string is "rtsp://10.41.83.100:554/camera"

When gstreamer is available you can connect to the camera with
```
gst-launch-1.0 playbin uri=rtsp://10.41.83.100:554/camera
```

## Tuning h264
You might want to change opsi/modules/videoio/h264.py

command = split("gst-inspect-1.0 omxh264enc")
command = split("gst-inspect-1.0 omxh264enc target-bitrate=1850000 control-rate=variable")

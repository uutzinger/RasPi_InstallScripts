# Install OpenSight
From https://opensight-cv.github.io/quickstart/installation/

```
sudo apt update
sudo apt install -y curl git jq
mkdir /tmp/opsi; cd /tmp/opsi
url="$(curl https://api.github.com/repos/opensight-cv/packages/releases/latest | jq -r '.["assets"][]["browser_download_url"]' | grep -v with)"
curl -LO $url
mkdir -p packages
tar xf opsi-packages-*.tar.gz -C packages
sudo apt install -y ./packages/deps/*.deb
rm -rf /tmp/opsi/
reboot
```

This will install opensight and opensigh-server ins ystemd.
You can enable or disable with:

```
sudo systemctl ensable opensight.service
sudo systemctl ensable opensight-server.service
```

Or start and stop the service:
```
sudo systemctl start opensight.service
sudo systemctl start opensight-server.service
```

https://www.raspberrypi.org/documentation/linux/usage/systemd.md

Opensight has dependencies such as
```
sudo apt-get -y install httptools aiofiles Click fastapi h11 httptools Jinja2 MarkupSafe netifaces numpy pydantic python-multipart six starlette
toposort uvicorn uvloop websockets imutils pynetworktables pystemd upgraded-engineer black isort requests

sudo apt-get -y install gstreamer1.0-omx gstreamer1.0-omx-rpi gstreamer1.0-tools python3-gi python3-gpiozero python3-gst-1.0

```

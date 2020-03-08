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
You can enable/disable with:

```
sudo systemctl disable opensight.service
sudo systemctl disable opensight-server.service
```

Or start and stop the service:
```
sudo systemctl start opensight.service
sudo systemctl start opensight-server.service
```

https://www.raspberrypi.org/documentation/linux/usage/systemd.md

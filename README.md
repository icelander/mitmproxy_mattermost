# Mattermost Outbound Proxies Recipe

## Problem
You want to set up `http` or `https` proxies for outbound connections to Mattermost to handle push notifications and link previews

## Solution

**Note:** These instructions are for Ubuntu 18.04

### 0. Install Mattermost Server

[Instructions here](https://docs.mattermost.com/install/install-ubuntu-1804.html)

### 1. Install `mitmproxy`

First, install `mitmproxy` and its necessary dependencies

```bash
apt-get install python3-pyasn1 python3-flask python3-urwid python3-dev libxml2-dev libxslt-dev libffi-dev python3-pip

pip3 install mitmproxy
```

### 2. **Optional:** Install the `mitmproxy` certificate authority on the server

Run the `mitmproxy` command to get the required certificate files and add them to the certificate store. This can be run as any user.

```bash
mitmproxy
# Press Ctrl+C after to stop it
sudo mkdir -p /usr/share/ca-certificates/extra
sudo cp ~/.mitmproxy/mitmproxy-ca-cert.cer /usr/share/ca-certificates/extra/mitmproxy-ca.crt
sudo chmod 644 /usr/share/ca-certificates/extra/mitmproxy-ca.crt
sudo chmod 755 /usr/share/ca-certificates/extra
# Be sure to select the certificate
sudo dpkg-reconfigure ca-certificates
```

### 3. Configure Environment Variables

Create the file `/opt/mattermost/config/mm.environment` with this content:

```
HTTP_PROXY=http://127.0.0.1:8080
HTTPS_PROXY=http://127.0.0.1:8080
```

### 4. Configure the Mattermost service to use the environment file

Modify the `systemd` file to match this:

```
[Unit]
Description=Mattermost
After=network.target
After=mysql.service
Requires=mysql.service

[Service]
Type=notify
EnvironmentFile=/opt/mattermost/config/mm.environment
ExecStart=/opt/mattermost/bin/mattermost
TimeoutStartSec=3600
Restart=always
RestartSec=10
WorkingDirectory=/opt/mattermost
User=mattermost
Group=mattermost
LimitNOFILE=49152

[Install]
WantedBy=mysql.service
```

Then reload the service by running:

```
sudo systemctl daemon-reload
```

### 4. Configure Mattermost to enable link previews

First, go to `System Console` > `Developer` and add `127.0.0.1` to `Allow Untrusted Internal Connections to`. Without this Mattermost will not be able to connect to the proxy server.

Then, go into `Posts` and set `Enable Link Previews` to `True`.

### 5. Enable `mitmproxy`

Run `mitmproxy` to start collecting HTTP and HTTPS requests from the Mattermost server.

## Discussion

[`mitmproxy`](https://mitmproxy.org/) is a great tool for sysadmins to diagnose HTTP and HTTPS connection issues. Setting it up is very easy, and it has freely available certificates that allow it to monitor encrypted traffic as well on virtually every platform.

Because `mitmproxy` handles generating certificates itself for sites, you can use it to analyze https sites without doing anything but installing the CA on the client. In this case, the server that Mattermost is running on is the client, so you can diagnose issues with link previews and push notifications and see exactly what the Mattermost server is sending and receiving when making a request.

`mitmweb` lets you use a web interface to monitor the connections, which is a bit easier to read and understand. To use it, substitute the `mitmproxy` command in step 5 with `mitmweb`. (If you run it using this Vagrant machine, use `mitmweb --web-iface 0.0.0.0`).

`mitmproxy` offers a lot of really amazing features, such as replaying and duplicating requests, which can be very useful for diagnosing issues that are difficult to reproduce by hand.

Finally, if you didn't install the certificate authorities in step 2, you may see an error like this when requesting a link preview:

```
Failed to get embedded content for a post	{"post_id": "6gcc4sashjgo3br749h5k7tehw", "error": "Get https://www.mattermost.com: x509: certificate signed by unknown authority"}
```

To resolve this, install the CA certificates or set `EnableInsecureOutgoingConnections` to `true`. This allows the Mattermost server to accept unverified and self-signed certificates.

## Resources
Here is a list of resources I found that helped write this recipe:

- [Mitmproxy: - Max’s Blog - Medium](https://medium.com/max-greenwalds-blog/mitmproxy-your-d-i-y-private-eye-864c08f84736)
- [How do I install a root certificate? - Ask Ubuntu](https://askubuntu.com/questions/73287/how-do-i-install-a-root-certificate/94861#94861)
- [MITM proxy on Ubuntu Startup? - help - mitmproxy](https://discourse.mitmproxy.org/t/mitm-proxy-on-ubuntu-startup/943/2) - How to add `mitmproxy` as a `systems` service

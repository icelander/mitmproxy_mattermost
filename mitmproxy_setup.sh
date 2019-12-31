#!/bin/bash


# Install dependencies
apt-get install -y python3-pyasn1 python3-flask python3-urwid python3-dev libxml2-dev libxslt-dev libffi-dev python3-pip

# Install mitmproxy
pip3 install mitmproxy
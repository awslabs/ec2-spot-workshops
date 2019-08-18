#!/bin/bash
set -e

systemctl stop httpd.service
systemctl disable httpd.service

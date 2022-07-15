#!/bin/bash

# Install NSS Certificate
sudo nss install-cert NssCertificate.zip

# Download the NSS binaries
sudo nss update-now

# Enable the NSS to start automatically
sudo nss enable-autostart

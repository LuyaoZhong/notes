#!/bin/bash

# Install Vagrant, Libvirt and QEMU for your distribution
sudo apt-get purge vagrant-libvirt
sudo apt-mark hold vagrant-libvirt
sudo apt-get update && \
    sudo apt-get install -y qemu libvirt-daemon-system ebtables libguestfs-tools \
        vagrant ruby-fog-libvirt

# Install the latest release of vagrant-libvirt
vagrant plugin install vagrant-libvirt

# Check unix_sock_group in /etc/libvirt/libvirtd.conf
# sudo usermod -a -G libvirt $USER

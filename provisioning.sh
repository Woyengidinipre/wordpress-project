#!/bin/bash
#provision.sh
#automate EC2 ubuntu insance to run WordPress and Docker

set -e

#system update

sudo apt-get update -y
sudo apt-get upgrade -y


#install dependencies

<<<<<<< HEAD
sudo apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
=======
sudo apt-get intsall -y \
        ca-certificates \
        curl \
        gnupg \
        lsb--release
>>>>>>> 05c22fcc5cc9ef48a48493aeb9262f7ee816375a

#Docker

echo "Installing docker ..."
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

#add ubuntu user to group to run docker without sudo commands

sudo usermod -aG docker ubuntu

echo "Docker: $(docker --version)"

sudo apt-get install -y docker-compose-plugin

echo "docker compose: $(docker compose version)"

#Application directories

sudo mkdir -p /srv/wordpress
sudo mkdir -p /mnt/mysql-data

#EBS Volume

if [ -b /dev/nvme1n1 ]; then
    EBS_DEVICE="/dev/nvme1n1"
elif [ -b /dev/xvdf ]; then
    EBS_DEVICE="/dev/xvdf"
else
    echo "WARNING: No EBS volume found at /dev/nvme1n1 or /dev/xvdf."
    echo "Skipping mount. Attach the volume and re-run this section manually."
    EBS_DEVICE=""
fi

if [ -n "$EBS_DEVICE" ]; then
    # Check if the volume is already mounted
    if mountpoint -q /mnt/mysql-data; then
        echo ">>> /mnt/mysql-data is already mounted. Skipping."
    else
        # Check if the volume already has a filesystem
        # blkid returns empty if the device has no filesystem
        EXISTING_FS=$(sudo blkid -o value -s TYPE "$EBS_DEVICE" 2>/dev/null || true)

        if [ -z "$EXISTING_FS" ]; then
            echo ">>> No filesystem detected on $EBS_DEVICE. Formatting as ext4..."
            sudo mkfs -t ext4 "$EBS_DEVICE"
        else
            echo ">>> Filesystem ($EXISTING_FS) already exists on $EBS_DEVICE. Skipping format."
fi

sudo mount "$EBS_DEVICE" /mnt/mysql-data
UUID=$(sudo blkid -o value -s UUID "$EBS_DEVICE")
        FSTAB_ENTRY="UUID=$UUID /mnt/mysql-data ext4 defaults,nofail 0 2"

        if grep -q "$UUID" /etc/fstab; then
            echo ">>> /etc/fstab entry already exists. Skipping."
        else
            echo ">>> Adding mount to /etc/fstab for persistence across reboots..."
            echo "$FSTAB_ENTRY" | sudo tee -a /etc/fstab
        fi

        echo ">>> EBS volume mounted successfully."
    fi
fi

#set permisiions

sudo chown -R ubuntu:ubuntu /mnt/mysql-data
sudo chmod 755 /mnt/mysql-data
sudo chown -R ubuntu:ubuntu /srv/wordpress

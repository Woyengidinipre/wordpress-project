User → port 80 → EC2 (Security Group) → Docker → WordPress container → MySQL container → /mnt/mysql-data → EBS Volume

why EBS for MySQL?  with EBS, the data stays on the volume even if the container, or even the EC2 instance, is stopped.

security group ports
port 22 (SSH)
port 80 (HTTP)
port 3306 (MySQL)

What is lost when EC2 crash
lost: the WordPress container itself, the docker-compose.yml, .env file, all the scripts (provision.sh, backup.sh), any uploaded media files stored inside the WordPress container.

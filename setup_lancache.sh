
#!/bin/bash
# sudo mkdir lancache
sudo mkdir -p lancache/data/logs
sudo mkdir -p lancache/data/cache
sudo mkdir -p lancache/data/info

sudo chmod -R 777 lancache/

echo
echo "=== Making sure Docker service is running"
sudo service docker start

echo "=== Stopping containers"
sudo docker stop steamcache-dns
sudo docker stop lancache

echo
echo "=== Removing containers"
sudo docker rm -v steamcache-dns
sudo docker rm -v lancache

echo
echo "=== Stopping docker service"
sudo service docker stop

echo
echo "=== Starting docker"
sudo service docker start

echo
echo "=== Creating background delayed docker service stop"
sleep 1m && sudo service docker stop &

echo
echo "=== Creating steamcache-dns"
#sudo docker run --name steamcache-dns --restart=always -d -p 53:53/udp -e STEAMCACHE_IP=192.168.86.5 steamcache/steamcache-dns:latest
sudo docker run --name steamcache-dns --restart=always -p 53:53/udp -e STEAMCACHE_IP="$(hostname -I | cut -d' ' -f1)" -e USE_GENERIC_CACHE=true -e LANCACHE_IP="$(hostname -I | cut -d' ' -f1)" steamcache/steamcache-dns:latest

sudo service docker start
#sudo docker run --name lancache --restart=always -p 192.168.86.5:80:80 steamcache/generic:latest

echo
echo "=== Creating background delayed docker service stop"
sleep 1m && sudo service docker stop &
echo
echo "=== Starting lancache"
#sudo docker run --name lancache --restart=always -v /mnt/m03/lancache:/data/cache -p 192.168.86.5:80:80 steamcache/generic:latest
sudo docker run --name lancache --restart=always -v "$(pwd)/lancache/data/cache":/data/cache -v "$(pwd)/lancache/data/logs":/data/logs -v "$(pwd)/lancache/data/info":/data/info -p "$(hostname -I | cut -d' ' -f1)":80:80 steamcache/generic:latest
#sudo docker run --name lancache --restart=always -v /mnt/m03/lancache:/data -p 192.168.86.5:80:80 steamcache/generic:latest

sudo service docker start

sudo chmod -R 777 lancache/

echo
echo "=== --------------------"
echo
echo "=== Checking status"
echo
sudo echo "$(service docker status)"
echo
sudo docker ps
echo
echo "=== DONE"

sudo yum update
sudo yum install epel-release -y
echo '[sensu]
name=sensu
baseurl=https://sensu.global.ssl.fastly.net/yum/$releasever/$basearch/
gpgcheck=0
enabled=1' | sudo tee /etc/yum.repos.d/sensu.repo
sudo yum install redis -y
# Now edit /etc/redis.conf file and change "protected-mode yes" to "protected-mode no"
sudo systemctl enable redis
sudo systemctl start redis
sudo yum install sensu uchiwa -y
#Configure Server * Run the following to set up a minimal client config:
echo '{
  "transport": {
    "name": "redis"
  },
  "api": {
    "host": "127.0.0.1",
    "port": 4567
  }
}' | sudo tee /etc/sensu/config.json
#COnfigure Client * Run the following to set up a minimal client config:
echo '{
  "client": {
    "environment": "development",
    "subscriptions": [
      "dev"
    ]
  }
}' |sudo tee /etc/sensu/conf.d/client.json
#Configure Dashboard
echo '{
   "sensu": [
     {
       "name": "sensu",
       "host": "127.0.0.1",
       "port": 4567
     }
   ],
   "uchiwa": {
     "host": "0.0.0.0",
     "port": 3000
   }
 }' |sudo tee /etc/sensu/uchiwa.json
 sudo chown -R sensu:sensu /etc/sensu
#Start sensu
sudo systemctl enable sensu-{server,api,client}
sudo systemctl start sensu-{server,api,client}
sudo systemctl enable uchiwa
sudo systemctl start uchiwa
#Check the install
sudo yum install jq curl -y
curl -s http://127.0.0.1:4567/clients | jq .

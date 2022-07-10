Builds and Deploys OpenVPN with Cloak 

1. Create a .env file with env example
2. Run this 
```
 curl https://raw.githubusercontent.com/stargazer39/openvpn-docker/main/deploy.sh > deploy.sh && chmod +x deploy.sh && ./deploy.sh
```

For more optimal performance on low cpu power devices, set
/etc/docker/daemon.json to
```json
{
    "userland-proxy": false
}
```
and restart docker service

Tested on Debian 11 and Ubuntu 20.04.4 LTS aarch64 

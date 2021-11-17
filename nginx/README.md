# nginx
## 初始安装
### 安装docker
curl -Lk https://get.docker.com/ | sh
### 安装compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && chmod +x  /usr/local/bin/docker-compose
### 配置文件
mkdir -p /usr/local/nginx && curl -Lk https://raw.githubusercontent.com/dylan2012/dockerfiles/main/nginx/conf.tar | tar xz -C /usr/local/nginx

## 常规安装

docker run -d -v /usr/local/nginx/conf:/usr/local/nginx/conf -p 80:80 -p 443:443 dylan2012/nginx:latest

## docker-compose安装

curl -Lk https://raw.githubusercontent.com/dylan2012/dockerfiles/main/nginx/docker-compose.yml >docker-compose.yml && docker-compose up -d


## letsencrypt证书安装
curl -Lk https://raw.githubusercontent.com/dylan2012/dockerfiles/main/nginx/docker-compose-letsencrypt >docker-compose.yml && docker-compose up -d
进入容器
docker exec -it nginx bash
手动配置
certbot certonly --nginx --nginx-server-root /usr/local/nginx/conf -d xxx.com
自动配置
certbot --nginx --nginx-server-root /usr/local/nginx/conf -d xxx.com
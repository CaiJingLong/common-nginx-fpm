VERSION="1.0.0"
docker build -t common-nginx-fpm:$VERSION .
docker tag common-nginx-fpm:$VERSION common-nginx-fpm:latest

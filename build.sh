VERSION="0.1.2"
docker buildx build --platform linux/amd64 -t common-nginx-fpm:$VERSION .
docker tag common-nginx-fpm:$VERSION common-nginx-fpm:latest

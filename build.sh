VERSION="0.1.5"
docker buildx build --platform linux/amd64 -t common-nginx-fpm:$VERSION --load .
docker tag common-nginx-fpm:$VERSION common-nginx-fpm:latest

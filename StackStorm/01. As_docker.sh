
## References
https://github.com/StackStorm/st2-dockerfiles#build-and-deploy-stackstorm-components-to-docker-hub

## Git location
git clone https://github.com/StackStorm/st2-dockerfiles.git

docker build --build-arg ST2_VERSION="2.0.1-3" --build-arg ST2_REPO="staging-stable" -t st2 stackstorm/

docker-compose up -d

# run stackstorm now.. 
docker-compose run --rm client st2 --version

# run stackstorm now.. 
docker-compose run --rm client st2 --version
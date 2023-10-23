docker build -t custom_ubuntu:20.04 .
docker run -d -p 80:80 -p 3690:3690 --name svn_test_container custom_ubuntu:20.04
docker exec -it svn_test_container /bin/bash

# git-patcher
- cortana sub brain which applies patch from mail

# create image
- add following files under ./keys directory
 - id_rsa.pub, id_rsa : ssh keys for accessing github
 - hub : hub oauth config (usually placed at your ~/.config/hub) for account which creates pull request
- do docker build
```
$ docker build -t your/image .
```

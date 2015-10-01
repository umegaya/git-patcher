FROM ruby:2.2.3
RUN apt-get update
RUN apt-get install -y cmake supervisor
RUN gem install rugged

ENV HUBVER=2.2.1
RUN curl -o hub.tgz -L https://github.com/github/hub/releases/download/v$HUBVER/hub-linux-amd64-$HUBVER.tar.gz
RUN tar -zxvf hub.tgz
RUN cp hub-linux-amd64-$HUBVER/hub /usr/local/bin && rm -r hub-linux-amd64-$HUBVER

ADD ./src server
ADD ./keys /root/.ssh
ADD ./keys/hub /root/.config/hub
RUN ssh-keyscan github.com >> /root/.ssh/known_hosts
ENV GITHUB_FINGERPRINT='16:27:ac:a5:76:28:2d:36:63:1b:56:4d:eb:df:a6:48'
RUN [ `ssh-keygen -lf /root/.ssh/known_hosts | awk '{print $2}'` = $GITHUB_FINGERPRINT ] && echo "ok"
CMD ["/usr/bin/supervisord", "-n", "-c", "/server/supervisord.conf"]

FROM centos/python-38-centos7

USER 0

# install necessary tools
RUN yum install unzip -y
RUN curl -O https://bootstrap.pypa.io/get-pip.py
RUN python get-pip.py

# install traditional chinese font
RUN mkdir -p /usr/share/fonts/chinese/
RUN curl -o /usr/share/fonts/chinese/Noto_Sans_TC.zip https://fonts.google.com/download?family=Noto%20Sans%20TC
RUN cd /usr/share/fonts/chinese/ && unzip Noto_Sans_TC.zip
RUN cd /usr/share/fonts/chinese/ && fc-cache -fv

# install selenium
RUN pip install seleniumbase requests pause

VOLUME [ "/screenshot" ]
VOLUME [ "/source" ]

# for cron #####
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
  systemd-tmpfiles-setup.service ] || rm -f $i; done); \
  rm -f /lib/systemd/system/multi-user.target.wants/*;\
  rm -f /etc/systemd/system/*.wants/*;\
  rm -f /lib/systemd/system/local-fs.target.wants/*; \
  rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
  rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
  rm -f /lib/systemd/system/basic.target.wants/*;\
  rm -f /lib/systemd/system/anaconda.target.wants/*;

VOLUME [ "/sys/fs/cgroup" ]

RUN yum install -y cronie && yum clean all

RUN rm -rf /etc/localtime
RUN ln -s /usr/share/zoneinfo/Singapore /etc/localtime

# download chromedriver
RUN mkdir /opt/chrome
# source https://googlechromelabs.github.io/chrome-for-testing/
RUN curl -o chromedriver_linux64.zip https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing/118.0.5993.70/linux64/chromedriver-linux64.zip
RUN unzip chromedriver_linux64.zip -d /opt/chrome
RUN cp /opt/chrome/chromedriver-linux64/chromedriver /usr/local/bin/chromedriver

# install headless chrome
RUN curl -O https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
RUN yum install google-chrome-stable_current_x86_64.rpm -y

# for cron #####
RUN crontab -l | { cat; echo "0 13 * * * (cd /app || exit 1; /opt/app-root/bin/python /app/selenium-with-headless-chrome.py >> /tmp/app.log)"; } | crontab -

WORKDIR /app

# copy the testing python script
COPY selenium-with-headless-chrome.py .
COPY ./entrypoint.sh ./entrypoint.sh

# CMD [ "python", "selenium-with-headless-chrome.py" ]
CMD ["/app/entrypoint.sh"]

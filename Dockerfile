FROM nvidia/cuda:12.4.1-devel-ubuntu22.04


ENV DEBIAN_FRONTEND noninteractive
ENV USER ubuntu
ENV HOME /home/$USER

RUN apt-get update && \
      apt-get -y install sudo

# Create new user for vnc login.
RUN adduser $USER --disabled-password

# Install MATE and dependency component.
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    rm -rf /var/lib/apt/lists/*

#RUN add-apt-repository ppa:jonathonf/mate-1.24

RUN apt-get update \
    && apt-get install -y \
        tightvncserver \
        ubuntu-mate-desktop mate-desktop-environment mate-notification-daemon \
	terminator \
        supervisor \
        net-tools \
        curl \
        git \
	python3 python3-dev python3-pip \
        pwgen \
	gedit \
	unzip \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        software-properties-common && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
    apt-key fingerprint 0EBFCD88 && \
    add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) \
        stable" && \
    rm -rf /var/lib/apt/lists/*

# Install Docker CLI and remove apt cache
RUN apt-get update && \
    apt-get install -y docker-ce-cli && \
    rm -rf /var/lib/apt/lists/*

# Copy tigerVNC binaries
ADD https://github.com/TigerVNC/tigervnc/archive/refs/tags/v1.15.0.tar.gz $HOME/tigervnc/tigervnc.tar.gz
RUN tar xmzf $HOME/tigervnc/tigervnc.tar.gz -C $HOME/tigervnc/ && rm $HOME/tigervnc/tigervnc.tar.gz
RUN cp -R $HOME/tigervnc/tigervnc-1.15.0/* / && rm -rf $HOME/tigervnc/

# Clone noVNC.
RUN git clone https://github.com/novnc/noVNC.git $HOME/noVNC

# Clone websockify for noVNC
Run git clone https://github.com/kanaka/websockify $HOME/noVNC/utils/websockify

# get chrome-repo in apt
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list

# install browsers
RUN apt update && apt install -y google-chrome-stable falkon && apt clean all  && apt -y autoremove

# Copy supervisor config
COPY supervisor.conf /etc/supervisor/conf.d/

# Copy startup script
COPY startup.sh $HOME

EXPOSE 6080 5901 4040 
CMD ["/bin/bash", "/home/ubuntu/startup.sh"]

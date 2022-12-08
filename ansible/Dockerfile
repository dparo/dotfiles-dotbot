FROM ubuntu:22.10
COPY . /dotfiles
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get -y install tzdata
RUN apt-get install -y sudo bash git ansible
ENV RUNNING_INSIDE_DOCKER=1
ENV USER=root
CMD /dotfiles/install

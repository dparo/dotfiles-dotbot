FROM ubuntu:22.04
COPY . /dotfiles
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get -y install tzdata
RUN apt-get install -y sudo bash
RUN apt-get install -y git ansible-core
CMD /dotfiles/install

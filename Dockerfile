ARG BASE
FROM buildpack-deps:bullseye
ARG BASE

LABEL maintainer="Sidney Markowitz"
LABEL repository="https://github.com/sidney/docker-spamassassin-tester"

RUN apt-get update && apt-get -y install apt-utils && \
    apt-get dist-upgrade -y

RUN apt-get -y install sudo build-essential git pyzor razor subversion libdb-dev libdbi-dev libidn11-dev \
    libssl-dev zlib1g-dev poppler-utils tesseract-ocr libmaxminddb-dev libidn2-dev 

ENV SA_USER="satester" \
    PATH="/home/satester/bin:$PATH"

RUN useradd -G sudo -m -s /bin/bash "$SA_USER" && \
    sed -i /etc/sudoers -re 's/^%sudo.*/%sudo ALL=(ALL:ALL) NOPASSWD: ALL/g' && \
    sed -i /etc/sudoers -re 's/^root.*/root ALL=(ALL:ALL) NOPASSWD: ALL/g' && \
    sed -i /etc/sudoers -re 's/^#includedir.*/## **Removed the include directive** ##"/g' && \
    echo "$SA_USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    echo "Customized the sudoers file for passwordless access to the $SA_USER user!" && \
    echo "$SA_USER user:";  su - $SA_USER -c id


WORKDIR /home/satester
USER $SA_USER

RUN git clone https://github.com/tokuhirom/plenv.git ~/.plenv && \
git clone https://github.com/tokuhirom/Perl-Build.git ~/.plenv/plugins/perl-build/

RUN echo 'export PATH="$HOME/.plenv/bin:$PATH"' >> ~/.profile

RUN echo 'eval "$(plenv init -)"' >> ~/.profile

RUN export PATH="$HOME/.plenv/bin:$PATH" && \
    eval "$(plenv init -)"

USER $SA_USER

WORKDIR /home/$SA_USER

RUN plenv install "$BASE" && \
    plenv rehash && \
    plenv global "$BASE" && \
    perl -v && \
    plenv install-cpanm

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY cpanfile /tmp/

RUN perl -V


RUN cpanm --self-upgrade || \
    ( echo "# Installing cpanminus:"; curl -sL https://cpanmin.us/ | perl - App::cpanminus )

RUN cpanm -nq App::cpm App::cpanoutdated Carton::Snapshot

RUN cpm install -g --show-build-log-on-failure --cpanfile /tmp/cpanfile

RUN cpan-outdated --exclude-core -p | xargs -n1 cpanm

RUN cpanm Mail::SPF -n --install-args="--install_path sbin=$HOME/bin" 

WORKDIR /tmp/

# install dcc from source
RUN wget https://www.dcc-servers.net/dcc/source/dcc.tar.Z && \
    tar xf dcc.tar.Z && \
    cd dcc-* && \
    ./configure --disable-server --disable-dccm --disable-dccifd && \
    make && \
    make install

WORKDIR /tmp/

# custom compile re2c because the version installed by Ubuntu is too old
RUN wget https://github.com/skvadrik/re2c/releases/download/3.0/re2c-3.0.tar.xz && \
    tar xf re2c-3.0.tar.xz && \
    cd re2c-3.0 && ./configure && make && make install

WORKDIR /tmp/

RUN git clone https://github.com/perl-actions/ci-perl-tester-helpers.git --depth 1 && \
    cp ci-perl-tester-helpers/bin/* /usr/local/bin/ && \
    rm -rf ci-perl-tester-helpers

CMD ["/bin/bash"]

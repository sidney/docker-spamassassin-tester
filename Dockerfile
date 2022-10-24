ARG BASE
FROM ubuntu:22.04
ARG BASE

LABEL maintainer="Sidney Markowitz"
LABEL repository="https://github.com/sidney/docker-spamassassin-tester"

RUN apt-get update && apt-get -y install apt-utils && \
    apt-get dist-upgrade -y

RUN apt-get -y install sudo build-essential curl cpanminus git pyzor razor subversion libdb-dev libdbi-dev libidn11-dev libidn2-dev \
    libmaxminddb-dev libssl-dev zlib1g-dev poppler-utils tesseract-ocr \
    libarchive-zip-perl libberkeleydb-perl libbsd-resource-perl libdigest-sha-perl libencode-detect-perl libgeo-ip-perl libgeoip2-perl \
    libio-compress-perl libmail-dkim-perl libmail-spf-perl libnet-patricia-perl libfile-sharedir-install-perl libtext-diff-perl \
    libtest-exception-perl libregexp-common-perl libxml-libxml-perl libtest-pod-coverage-perl libdbd-sqlite2-perl libdbd-sqlite3-perl \
    libdevel-cycle-perl libgeography-countries-perl libtest-perl-critic-perl libdbix-simple-perl libemail-mime-perl libemail-sender-perl \
    libnet-idn-encode-perl libtest-file-sharedir-perl libtest-output-perl libnet-imap-simple-perl libnet-smtps-perl

WORKDIR /tmp/

# install dcc from source
RUN curl -s -L -o dcc.tar.Z https://www.dcc-servers.net/dcc/source/dcc.tar.Z && \
    tar xf dcc.tar.Z && \
    cd dcc-* && \
    ./configure --disable-server --disable-dccm --disable-dccifd && \
    make && \
    make install

WORKDIR /tmp/

# custom compile re2c because the version installed by Ubuntu is too old
RUN curl -s -L -o re2c-3.0.tar.xz https://github.com/skvadrik/re2c/releases/download/3.0/re2c-3.0.tar.xz && \
    tar xf re2c-3.0.tar.xz && \
    cd re2c-3.0 && ./configure && make && make install

WORKDIR /tmp/

RUN git clone https://github.com/perl-actions/ci-perl-tester-helpers.git --depth 1 && \
    cp ci-perl-tester-helpers/bin/* /usr/local/bin/ && \
    rm -rf ci-perl-tester-helpers
ENV SA_USER="satester" \
    PATH="/home/satester/bin:$PATH"

RUN useradd -G sudo -u 1001 -m -s /bin/bash "$SA_USER" && \
    sed -i /etc/sudoers -re 's/^%sudo.*/%sudo ALL=(ALL:ALL) NOPASSWD: ALL/g' && \
    sed -i /etc/sudoers -re 's/^root.*/root ALL=(ALL:ALL) NOPASSWD: ALL/g' && \
    sed -i /etc/sudoers -re 's/^#includedir.*/## **Removed the include directive** ##"/g' && \
    echo "$SA_USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    echo "Customized the sudoers file for passwordless access to the $SA_USER user!" && \
    echo "$SA_USER user:";  su - $SA_USER -c id


WORKDIR /home/$SA_USER
USER $SA_USER

RUN razor-admin -create && razor-admin -register

RUN git clone https://github.com/tokuhirom/plenv.git ~/.plenv && \
git clone https://github.com/tokuhirom/Perl-Build.git ~/.plenv/plugins/perl-build/

RUN echo 'export PATH="$HOME/.plenv/bin:$PATH"' >> ~/.profile
ENV PATH="$HOME/.plenv/bin:$PATH"

RUN echo 'eval "$(plenv init -)"' >> ~/.profile

RUN export PATH="$HOME/.plenv/bin:$PATH" && \
    eval "$(plenv init -)" && \
    perlversion=$(plenv install --list | grep -m 1 -o "${BASE}..") && \
    plenv install "$perlversion" && \
    plenv rehash && \
    plenv global "$perlversion" && \
    perl -v && \
    plenv install-cpanm

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY cpanfile /tmp/

RUN export PATH="$HOME/.plenv/bin:$PATH" && \
    eval "$(plenv init -)" && \
    perl -V && \
    cpanm -nq App::cpm App::cpanoutdated Carton::Snapshot && \
    cpm install -g --show-build-log-on-failure --cpanfile /tmp/cpanfile && \
    cpan-outdated --exclude-core -p | xargs -n1 cpanm

RUN export PATH="$HOME/.plenv/bin:$PATH" && \
    eval "$(plenv init -)" && \
    cpanm Mail::SPF -n --install-args="--install_path sbin=$HOME/bin" 


CMD ["/bin/bash"]

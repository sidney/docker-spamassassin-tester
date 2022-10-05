ARG BASE
ARG DEBIAN_FRONTEND noninteractive
FROM perl:${BASE}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY cpanfile /tmp/

RUN perl -V

RUN apt-get update && apt-get -y install apt-utils && \
    apt-get dist-upgrade -y && \
    apt-get -y install build-essential git pyzor razor subversion libdb-dev libdbi-dev libidn11-dev \
        libidn2-dev libmaxminddb-dev libssl-dev zlib1g-dev poppler-utils tesseract-ocr

RUN cpanm --self-upgrade || \
    ( echo "# Installing cpanminus:"; curl -sL https://cpanmin.us/ | perl - App::cpanminus )

RUN cpanm -nq App::cpm App::cpanoutdated Carton::Snapshot

RUN cpm install -g --show-build-log-on-failure --cpanfile /tmp/cpanfile

RUN cpan-outdated --exclude-core -p | xargs -n1 cpanm

RUN cpanm Mail::SPF -n --install-args="--install_path sbin=/usr/local/bin" 

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

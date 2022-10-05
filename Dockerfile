ARG BASE
FROM buildpack-deps:bullseye
ARG BASE

WORKDIR /usr/src/perl

RUN true \
    && curl -fL https://www.cpan.org/src/5.0/perl-${BASE}.tar.gz -o perl-${BASE}.tar.gz \
    && tar --strip-components=1 -xaf perl-${BASE}.tar.xz -C /usr/src/perl \
    && rm perl-${BASE}.tar.gz \
    && cat *.patch | patch -p1 \
    && gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
    && archBits="$(dpkg-architecture --query DEB_BUILD_ARCH_BITS)" \
    && archFlag="$([ "$archBits" = '64' ] && echo '-Duse64bitall' || echo '-Duse64bitint')" \
    && ./Configure -Darchname="$gnuArch" "$archFlag" -Duseshrplib -Dvendorprefix=/usr/local  -des \
    && make -j$(nproc) \
    && TEST_JOBS=$(nproc) make test_harness \
    && make install \
    && cd /usr/src \
    && curl -fLO https://www.cpan.org/authors/id/M/MI/MIYAGAWA/App-cpanminus-1.7046.tar.gz \
    && echo '3e8c9d9b44a7348f9acc917163dbfc15bd5ea72501492cea3a35b346440ff862 *App-cpanminus-1.7046.tar.gz' | sha256sum --strict --check - \
    && tar -xzf App-cpanminus-1.7046.tar.gz && cd App-cpanminus-1.7046 && perl bin/cpanm . && cd /root \
    && cpanm IO::Socket::SSL \
    && curl -fL https://raw.githubusercontent.com/skaji/cpm/0.997011/cpm -o /usr/local/bin/cpm \
    # sha256 checksum is from docker-perl team, cf https://github.com/docker-library/official-images/pull/12612#issuecomment-1158288299
    && echo '7dee2176a450a8be3a6b9b91dac603a0c3a7e807042626d3fe6c93d843f75610 */usr/local/bin/cpm' | sha256sum --strict --check - \
    && chmod +x /usr/local/bin/cpm \
    && true \
    && rm -fr /root/.cpanm /usr/src/perl /usr/src/App-cpanminus-1.7046* /tmp/* \
    && cpanm --version && cpm --version

WORKDIR /

CMD ["perl${BASE}","-de0"]

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY cpanfile /tmp/

RUN perl -V

RUN apt-get update && apt-get -y install apt-utils && \
    apt-get dist-upgrade -y

RUN apt-get -y install build-essential git pyzor razor subversion libdb-dev libdbi-dev libidn11-dev \
    libssl-dev zlib1g-dev poppler-utils tesseract-ocr
    
RUN apt-get -y install libmaxminddb-dev || /bin/true 

RUN apt-get -y install libidn2-dev || /bin/true 

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

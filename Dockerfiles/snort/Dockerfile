FROM public.ecr.aws/amazonlinux/amazonlinux:latest

RUN dnf -y install yum-utils
#https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-37&arch=aarch64
RUN yum-config-manager --add-repo='http://fedora.mirror.root.lu/releases/37/Everything/aarch64/os/'
RUN dnf -y install fedora-gpg-keys --nogpgcheck
RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-37-aarch64
RUN dnf update -y

RUN dnf -y  install git
RUN echo " /usr/local/lib" >> "/etc/ld.so.conf.d/local.conf"
RUN echo " /usr/local/lib64" >> "/etc/ld.so.conf.d/local.conf"
RUN ldconfig
RUN mkdir /work
RUN mkdir /packages
RUN dnf -y  install flex bison gcc gcc-c++ make cmake3 automake autoconf libtool diffutils check check-devel
RUN dnf -y install libdnet-devel libdnet
RUN dnf -y  install libpcap-devel pcre-devel hwloc-devel openssl-devel zlib-devel pkgconf libmnl-devel libunwind-devel
RUN dnf -y install g++ hwloc openssl libpcap pcre libuuid uuid-devel pkgconf-pkg-config zlib luajit luajit-devel

RUN cd /work && git clone https://github.com/snort3/libdaq.git libdaq
RUN cd /work/libdaq && ./bootstrap && ./configure && make && make install && ldconfig

RUN dnf -y install xz-devel libuuid-devel
RUN dnf -y install cmake3
RUN dnf -y install dnf-plugins-core
RUN dnf -y install wget
RUN dnf -y install libsafec
RUN dnf -y  install gperftools-devel

RUN cd /work && git clone https://github.com/snort3/snort3.git snort3_latest
RUN export CFLAGS="-O3"
RUN export CXXFLAGS="-O3 -fno-rtti"
RUN export PKG_CONFIG_PATH=/usr/local/lib/:$PKG_CONFIG_PATH
RUN export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH
RUN export PKG_CONFIG_PATH=/usr/local/lib64/pkgconfig:$PKG_CONFIG_PATH

RUN cd /work/snort3_latest && export my_path=/usr/local && ./configure_cmake.sh --with-daq-libraries=/usr/local/lib/daq/ --prefix=$my_path --enable-tcmalloc --enable-shell --enable-debug  --enable-debug-msgs
RUN cd /work/snort3_latest/build && make -j$(nproc) install

RUN cd /work && git clone https://github.com/snort3/snort3_extra.git snort3_extra
RUN cd /work/snort3_extra && export PKG_CONFIG_PATH=/usr/local/snort/lib64/pkgconfig:$PKG_CONFIG_PATH
RUN cd /work/snort3_extra && ./configure_cmake.sh --prefix=/usr/local/snort/extra
RUN cd /work/snort3_extra/build && make -j$(nproc) && make -j$(nproc) install

RUN cd /work  && git clone https://github.com/LuaJIT/LuaJIT.git luajit
RUN cd /work/luajit && make && make install
RUN export LD_LIBRARY_PATH=/usr/local/lib/:$LD_LIBRARY
RUN export LUAJIT_INCLUDE_DIR=/usr/local/lib/
RUN ln -sf /usr/local/bin/luajit-2.1.0-beta3 /usr/local/bin/luajit

RUN groupadd --gid 1001 snort
RUN useradd snort -r -M -g 1001 -u 1001 -s  /sbin/nologin -c SNORT_SERVICE_ACCOUNT
RUN mkdir /var/log/snort
RUN touch /var/log/snort/snort.pid
RUN chown -R snort:snort /var/log/snort
RUN chmod -R 5700 /var/log/snort


COPY pulledpork.conf /usr/local/etc/pulledpork3/

RUN dnf -y install https://kojipkgs.fedoraproject.org/packages/supervisor/4.2.2/3.el9/noarch/supervisor-4.2.2-3.el9.noarch.rpm


RUN mkdir -p /usr/local/etc/snort/{builtin_rules,rules,appid,intel,lists}
RUN cd /work && curl -Lo snort-openappid.tar.gz https://www.snort.org/downloads/openappid/26425
RUN cd /work && tar xf snort-openappid.tar.gz
RUN cd /work && mv odp/ /usr/local/etc/snort/appid/

RUN touch /usr/local/etc/snort/rules/snort.rules
RUN touch /usr/local/etc/snort/lists/reputation.blacklist

RUN dnf -y install pip
RUN pip install requests

RUN cd /work && git clone https://github.com/shirkdog/pulledpork3.git
RUN cd /work/pulledpork3 && mkdir /usr/local/bin/pulledpork3 && cp pulledpork.py /usr/local/bin/pulledpork3/
RUN cd /work/pulledpork3 && cp -r lib/ /usr/local/bin/pulledpork3
RUN chmod +x /usr/local/bin/pulledpork3/pulledpork.py
COPY snort.lua snort_defaults.lua /usr/local/etc/snort/
COPY docker-entrypoint.sh supervisord.conf update-config.sh /
COPY local.rules /usr/local/etc/snort/rules/

RUN ["chmod", "+x", "/docker-entrypoint.sh"]
RUN ["chown", "-R", "snort:snort", "/var/log/snort"]
ENTRYPOINT ["bash", "/docker-entrypoint.sh"]
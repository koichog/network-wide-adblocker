echo "Installing necessary packages"
sudo apt-get remove -y squid
sudo apt-get install -y build-essential libssl-dev
SQUID_VERSION=4.17

echo "Retrieving squid fro squid-cache.org"
wget http://www.squid-cache.org/Versions/v4/squid-4.17.tar.gz
tar xzf squid-${SQUID_VERSION}.tar.gz
cd squid-${SQUID_VERSION}

echo "Configuring Squid"
./configure --prefix=/usr --localstatedir=/var --libexecdir=${prefix}/lib/squid --datadir=${prefix}/share/squid --build=arm-linux-gnueabihf' '--prefix=/usr' '--includedir=${prefix}/include' '--mandir=${prefix}/share/man' '--infodir=${prefix}/share/info' '--sysconfdir=/etc' '--localstatedir=/var' '--libexecdir=${prefix}/lib/squid' '--srcdir=.' '--disable-maintainer-mode' '--disable-dependency-tracking' '--disable-silent-rules' 'BUILDCXXFLAGS=-g -O2 -fdebug-prefix-map=/home/pi/squid-4.6=. -fstack-protector-strong -Wformat -Werror=format-security -Wdate-time -D_FORTIFY_SOURCE=2 -Wl,-z,relro -Wl,-z,now -Wl,--as-needed -latomic' 'BUILDCXX=arm-linux-gnueabihf-g++' '--with-build-environment=default' '--enable-build-info=Raspbian linux' '--datadir=/usr/share/squid' '--sysconfdir=/etc/squid' '--libexecdir=/usr/lib/squid' '--mandir=/usr/share/man' '--enable-inline' '--disable-arch-native' '--enable-async-io=8' '--enable-storeio=ufs,aufs,diskd,rock' '--enable-removal-policies=lru,heap' '--enable-delay-pools' '--enable-cache-digests' '--enable-icap-client' '--enable-follow-x-forwarded-for' '--enable-auth-basic=DB,fake,getpwnam,LDAP,NCSA,NIS,PAM,POP3,RADIUS,SASL,SMB' '--enable-auth-digest=file,LDAP' '--enable-auth-negotiate=kerberos,wrapper' '--enable-auth-ntlm=fake,SMB_LM' '--enable-external-acl-helpers=file_userip,kerberos_ldap_group,LDAP_group,session,SQL_session,time_quota,unix_group,wbinfo_group' '--enable-security-cert-validators=fake' '--enable-storeid-rewrite-helpers=file' '--enable-url-rewrite-helpers=fake' '--enable-eui' '--enable-esi' '--enable-icmp' '--enable-zph-qos' '--enable-ecap' '--disable-translation' '--with-swapdir=/var/spool/squid' '--with-logdir=/var/log/squid' '--with-pidfile=/var/run/squid.pid' '--with-filedescriptors=65536' '--with-large-files' '--with-default-user=proxy' '--without-gnutls' '--enable-ssl' '--with-openssl' '--enable-ssl-crtd' '--enable-linux-netfilter' 'build_alias=arm-linux-gnueabihf' 'CC=arm-linux-gnueabihf-gcc' 'CFLAGS=-g -O2 -fdebug-prefix-map=/home/pi/squid-4.6=. -fstack-protector-strong -Wformat -Werror=format-security -Wall' 'LDFLAGS=-Wl,-z,relro -Wl,-z,now -Wl,--as-needed -latomic' 'CPPFLAGS=-Wdate-time -D_FORTIFY_SOURCE=2' 'CXX=arm-linux-gnueabihf-g++' 'CXXFLAGS=-g -O2 -fdebug-prefix-map=/home/pi/squid-4.6=. -fstack-protector-strong -Wformat -Werror=format-security --sysconfdir=/etc/squid --with-logdir=/var/log/squid --with-pidfile=/var/run/squid.pid --enable-ssl --with-openssl --enable-ssl-crtd

echo "Installing it - this will take time so take a deep breath and come back later :)"
sleep 5
make -j$(nproc)
sudo make install

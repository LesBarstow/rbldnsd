#! /usr/bin/make -rf
#
# $Id$
# Makefile for rbldnsd

CC = cc
CFLAGS = -O
LD = $(CC)
LDFLAGS = $(CFLAGS)
AR = ar
ARFLAGS = rv
RANLIB = :

# Disable statistic counters
#DEFS = -DNOSTATS
# Disable memory info logging (mallinfo)
#DEFS = -DNOMEMINFO
# Disable printing zone (re)load time using utimes()
#DEFS = -DNOTIMES
# If your system lacks <stdint.h> header but uint32_t is in sys/types.h
#DEFS = -DNOSTDINT_H
# For FreeBSD 4.4 use DEFS="-DNOMEMINFO -DNOSTDINT_H"

SOCKET_LIBS = `[ -f /usr/lib/libsocket.so ] && echo -lsocket -lnsl || :`

LIBDNS_SRCS = dns_ptodn.c dns_dntop.c dns_dntol.c dns_dnlen.c dns_dnlabels.c dns_dnreverse.c
LIBDNS_HDRS = dns.h

LIBIP4_SRCS = ip4parse.c ip4atos.c ip4mask.c
LIBIP4_HDRS = ip4addr.h

LIB_SRCS = $(LIBDNS_SRCS) $(LIBIP4_SRCS) mempool.c
LIB_HDRS = $(LIBDNS_HDRS) $(LIBIP4_HDRS) mempool.h
LIB_OBJS = $(LIB_SRCS:.c=.o)

RBLDNSD_SRCS = rbldnsd.c rbldnsd_zones.c rbldnsd_packet.c \
  rbldnsd_generic.c \
  rbldnsd_ip4set.c rbldnsd_ip4vset.c \
  rbldnsd_dnset.c rbldnsd_dnvset.c \
  rbldnsd_util.c
RBLDNSD_HDRS = rbldnsd.h rbldnsd_zones.h
RBLDNSD_OBJS = $(RBLDNSD_SRCS:.c=.o) librbldnsd.a

MISC = rbldnsd.8 qsort.c Makefile NEWS CHANGES WirehubDynablock2rbldnsd.pl

SRCS = $(LIB_SRCS) $(RBLDNSD_SRCS) ip4rangetest.c
HDRS = $(LIB_HDRS) $(RBLDNSD_HDRS)

VERSION = 0.84p1
VERSION_DATE = 2003-04-20

all: rbldnsd

rbldnsd: $(RBLDNSD_OBJS)
	$(LD) $(LDFLAGS) -o $@ $(RBLDNSD_OBJS) $(SOCKET_LIBS)

librbldnsd.a: $(LIB_OBJS)
	-rm -f $@
	$(AR) $(ARFLAGS) $@ $(LIB_OBJS)
	$(RANLIB) $@

ip4rangetest: ip4rangetest.o ip4parse.o
	$(LD) $(LDFLAGS) -o $@ ip4rangetest.o ip4parse.o

.SUFFIXES: .c .o

COMPILE = $(CC) $(CFLAGS) $(DEFS) -c $<

.c.o:
	$(COMPILE)

rbldnsd.o: rbldnsd.c
	$(COMPILE) -DVERSION='"$(VERSION) $(VERSION_DATE)"'

clean:
	-rm -f $(RBLDNSD_OBJS) $(LIB_OBJS) librbldnsd.a ip4rangetest
distclean: clean
	-rm -f rbldnsd

depend dep deps: $(SRCS)
	@echo Generating deps for:
	@echo \ $(SRCS)
	@sed '/^# depend/q' Makefile > Makefile.tmp
	@$(CC) $(CFLAGS) -MM $(SRCS) >> Makefile.tmp
	@if cmp Makefile.tmp Makefile ; then \
	  echo Makefile unchanged; \
	  rm -f Makefile.tmp; \
	else \
	  echo Updating Makfile; \
	  mv -f Makefile.tmp Makefile ; \
	fi

# depend
dns_ptodn.o: dns_ptodn.c dns.h
dns_dntop.o: dns_dntop.c dns.h
dns_dntol.o: dns_dntol.c dns.h
dns_dnlen.o: dns_dnlen.c dns.h
dns_dnlabels.o: dns_dnlabels.c dns.h
dns_dnreverse.o: dns_dnreverse.c dns.h
ip4parse.o: ip4parse.c ip4addr.h
ip4atos.o: ip4atos.c ip4addr.h
ip4mask.o: ip4mask.c ip4addr.h
mempool.o: mempool.c mempool.h
rbldnsd.o: rbldnsd.c rbldnsd.h ip4addr.h dns.h mempool.h
rbldnsd_zones.o: rbldnsd_zones.c dns.h rbldnsd.h ip4addr.h \
 rbldnsd_zones.h
rbldnsd_packet.o: rbldnsd_packet.c rbldnsd.h ip4addr.h dns.h \
 rbldnsd_zones.h
rbldnsd_generic.o: rbldnsd_generic.c rbldnsd.h ip4addr.h dns.h \
 mempool.h qsort.c
rbldnsd_ip4set.o: rbldnsd_ip4set.c rbldnsd.h ip4addr.h dns.h qsort.c
rbldnsd_ip4vset.o: rbldnsd_ip4vset.c rbldnsd.h ip4addr.h dns.h \
 mempool.h qsort.c
rbldnsd_dnset.o: rbldnsd_dnset.c rbldnsd.h ip4addr.h dns.h mempool.h \
 qsort.c
rbldnsd_dnvset.o: rbldnsd_dnvset.c rbldnsd.h ip4addr.h dns.h mempool.h \
 qsort.c
rbldnsd_util.o: rbldnsd_util.c rbldnsd.h ip4addr.h dns.h mempool.h
ip4rangetest.o: ip4rangetest.c ip4addr.h rbldnsd.h dns.h

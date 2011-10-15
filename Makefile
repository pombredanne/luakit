# Include makefile config
include config.mk

# Token lib generation
TLIST = common/tokenize.list
THEAD = common/tokenize.h
TSRC  = common/tokenize.c

SRCS  = $(filter-out $(TSRC),$(wildcard *.c) $(wildcard common/*.c) $(wildcard clib/*.c) $(wildcard clib/soup/*.c) $(wildcard widgets/*.c)) $(TSRC)
HEADS = $(wildcard *.h) $(wildcard common/*.h) $(wildcard widgets/*.h) $(wildcard clib/*.h) $(wildcard clib/soup/*.h) $(THEAD) globalconf.h
OBJS  = $(foreach obj,$(SRCS:.c=.o),$(obj))

all: options newline $(APP_NAME) $(APP_NAME).1

options:
	@echo $(APP_NAME) build options:
	@echo "CC           = $(CC)"
	@echo "LUA_PKG_NAME = $(LUA_PKG_NAME)"
	@echo "CFLAGS       = $(CFLAGS)"
	@echo "CPPFLAGS     = $(CPPFLAGS)"
	@echo "LDFLAGS      = $(LDFLAGS)"
	@echo "INSTALLDIR   = $(INSTALLDIR)"
	@echo "MANPREFIX    = $(MANPREFIX)"
	@echo "DOCDIR       = $(DOCDIR)"
	@echo
	@echo build targets:
	@echo "SRCS  = $(SRCS)"
	@echo "HEADS = $(HEADS)"
	@echo "OBJS  = $(OBJS)"

$(THEAD) $(TSRC): $(TLIST)
	./build-utils/gentokens.lua $(TLIST) $@

globalconf.h: globalconf.h.in
	sed 's#LUAKIT_INSTALL_PATH .*#LUAKIT_INSTALL_PATH "$(PREFIX)/share/$(APP_NAME)"#' globalconf.h.in > globalconf.h

$(OBJS): $(HEADS) config.mk

.c.o:
	@echo $(CC) -c $< -o $@
	@$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

widgets/webview.o: $(wildcard widgets/webview/*.c)

$(APP_NAME): $(OBJS)
	@echo $(CC) -o $@ $(OBJS)
	@$(CC) -o $@ $(OBJS) $(LDFLAGS)

$(APP_NAME).1: $(APP_NAME)
	help2man -N -o $@ ./$<

apidoc: luadoc/luakit.lua
	mkdir -p apidocs
	luadoc --nofiles -d apidocs luadoc/* lib/*

doc: globalconf.h $(THEAD) $(TSRC)
	doxygen -s luakit.doxygen

clean:
	rm -rf apidocs doc $(APP_NAME) $(OBJS) $(TSRC) $(THEAD) globalconf.h $(APP_NAME).1

install:
	install -d $(INSTALLDIR)/share/$(APP_NAME)/
	install -d $(DOCDIR)
	install -m644 README.md AUTHORS COPYING* $(DOCDIR)
	cp -r lib $(INSTALLDIR)/share/$(APP_NAME)/
	chmod 755 $(INSTALLDIR)/share/$(APP_NAME)/lib/
	chmod 755 $(INSTALLDIR)/share/$(APP_NAME)/lib/lousy/
	chmod 755 $(INSTALLDIR)/share/$(APP_NAME)/lib/lousy/widget/
	chmod 644 $(INSTALLDIR)/share/$(APP_NAME)/lib/*.lua
	chmod 644 $(INSTALLDIR)/share/$(APP_NAME)/lib/lousy/*.lua
	chmod 644 $(INSTALLDIR)/share/$(APP_NAME)/lib/lousy/widget/*.lua
	install -d $(INSTALLDIR)/bin
	install $(APP_NAME) $(INSTALLDIR)/bin/$(APP_NAME)
	install -d $(DESTDIR)/etc/xdg/$(APP_NAME)/
	install config/*.lua $(DESTDIR)/etc/xdg/$(APP_NAME)/
	chmod 644 $(DESTDIR)/etc/xdg/$(APP_NAME)/*.lua
	install -d $(DESTDIR)/usr/share/pixmaps
	install extras/$(APP_NAME).png $(DESTDIR)/usr/share/pixmaps/
	install -d $(DESTDIR)/usr/share/applications
	install extras/$(APP_NAME).desktop $(DESTDIR)/usr/share/applications/
	install -d $(MANPREFIX)/man1/
	install -m644 $(APP_NAME).1 $(MANPREFIX)/man1/

uninstall:
	rm -rf $(INSTALLDIR)/bin/$(APP_NAME) $(INSTALLDIR)/share/$(APP_NAME) $(MANPREFIX)/man1/$(APP_NAME).1
	rm -rf /usr/share/applications/$(APP_NAME).desktop /usr/share/pixmaps/$(APP_NAME).png

newline: options;@echo
.PHONY: all clean options install newline apidoc doc

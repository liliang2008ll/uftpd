# Top directory for building complete system, fall back to this directory
ROOTDIR    ?= $(TOPDIR)

# Some junk files we always want to be removed when doing a make clean.
JUNK        = *~ *.bak *.aux *.dvi *.idx *.ind *.log *.ps *.map .*.d DEADJOE semantic.cache *.gdb *.elf core core.*

# Tools
RM         ?= rm -f
CC         ?= $(CROSS)gcc
MAKE       := @$(MAKE)
MAKEFLAGS   = --no-print-directory --silent
CHECK      := cppcheck $(CPPFLAGS) --quiet --enable=all
INSTALL    := install --backup=off
STRIPINST  := $(INSTALL) -s --strip-program=$(CROSS)strip -m 0755

# Smart autodependecy generation via GCC -M.
.%.d: %.c
	@$(SHELL) -ec "$(CC) -MM $(CFLAGS) $(CPPFLAGS) $< \
		| sed 's,.*: ,$*.o $@ : ,g' > $@; \
                [ -s $@ ] || rm -f $@"

# Override default implicit rules
%.o: %.c
	@printf "  CC      $(subst $(ROOTDIR)/,,$(shell pwd)/$@)\n"
	@$(CC) $(CFLAGS) $(CPPFLAGS) -c -o $@ $<

%: %.o
	@printf "  LINK    $(subst $(ROOTDIR)/,,$(shell pwd)/$@)\n"
	@$(CC) $(CFLAGS) $(LDFLAGS) -Wl,-Map,$@.map -o $@ $^ $(LDLIBS$(LDLIBS-$(@)))

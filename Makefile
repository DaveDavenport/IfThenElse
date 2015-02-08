PROGRAM=ifthenelse
SOURCES=$(wildcard *.vala Actions/*.vala Base/*.vala Checks/*.vala Triggers/*.vala)
PACKAGES=glib-2.0
EMPTY=
PREFIX?=/usr



PACKAGE_CHECK=.pkgcheck
# VALAC magic.
VALAC?=valac
VALAC_PACKAGES=$(foreach PKG, $(PACKAGES), --pkg=$(PKG))
VALAC_FLAGS=-g $(VALAC_PACKAGES) --vapidir=./Vapi/ --pkg=posix --pkg=fix --save-temps
VALADOC_DRIVER?=$(shell valac --version | awk -F' ' '{c= split($$2,B,"\."); printf "%s.%s.x", B[1], B[2]}')




all: $(PROGRAM)

# Check pkg-config dependencies.
$(PACKAGE_CHECK): Makefile
	$(info == Checking dependencies: $(PACKAGES))
	@pkg-config --exists $(PACKAGES) &&  touch $@



$(PROGRAM): $(SOURCES) | $(PACKAGE_CHECK)
	$(VALAC) -o $@  $^ $(VALAC_FLAGS)

clean:
	$(info == Cleaning)
	@rm -rf $(PROGRAM) $(PACKAGE_CHECK)

install:
	install -Dm 755 $(PROGRAM) $(PREFIX)/bin/


doc:
	valadoc --vapidir=./Vapi/ --pkg=fix --pkg=posix --private --driver $(VALADOC_DRIVER) -b ../  --verbose --force $(SOURCES) --pkg=posix -o ./Documentation/html --package-name=$(PROGRAM)

test:
	make -C Test/ test

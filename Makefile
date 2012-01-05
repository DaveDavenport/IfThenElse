PROGRAM=ifthenelse
SOURCES=$(wildcard *.vala **/*.vala)
PACKAGES=glib-2.0
EMPTY=
PREFIX?=~/.local/



PACKAGE_CHECK=.pkgcheck
# VALAC magic.
VALAC=valac
VALAC_PACKAGES=$(foreach PKG, $(PACKAGES), --pkg=$(PKG))
VALAC_FLAGS=-g $(VALAC_PACKAGES) --vapidir=./Vapi/ --pkg=posix
VALADOC_DRIVER?=$(shell valac --version | awk -F' ' '{c= split($$2,B,"\."); printf "%s.%s.x", B[1], B[2]}') 




all: $(PROGRAM)

# Check pkg-config dependencies.
$(PACKAGE_CHECK): 
	$(info == Checking dependencies: $(PACKAGES))
	@pkg-config --exists $(PACKAGES) &&  touch $@



$(PROGRAM): $(SOURCES) | $(PACKAGE_CHECK)
	$(VALAC) -o $@  $^ $(VALAC_FLAGS)

clean:
	$(info == Cleaning)
	@rm -rf $(PROGRAM) $(PACKAGE_CHECK)

install:
	install $(PROGRAM) $(PREFIX)/bin/


doc:
	valadoc --private --driver $(VALADOC_DRIVER) -b ../  --verbose --force $(SOURCES) --pkg=posix -o ./Documentation/html --package-name=$(PROGRAM)

PROGRAM=ifthenelse-test
SOURCES=$(wildcard *.vala **/*.vala ../Base/BaseClass.vala)
PACKAGES=glib-2.0
EMPTY=
PREFIX?=/usr



PACKAGE_CHECK=.pkgcheck
# VALAC magic.
VALAC=valac
VALAC_PACKAGES=$(foreach PKG, $(PACKAGES), --pkg=$(PKG))
VALAC_FLAGS=-g $(VALAC_PACKAGES) --vapidir=./Vapi/ --pkg=posix
VALADOC_DRIVER?=$(shell valac --version | awk -F' ' '{c= split($$2,B,"\."); printf "%s.%s.x", B[1], B[2]}')




all: $(PROGRAM)

test: $(PROGRAM)
	./$(PROGRAM) --verbose

# Check pkg-config dependencies.
$(PACKAGE_CHECK): Makefile
	$(info == Checking dependencies: $(PACKAGES))
	@pkg-config --exists $(PACKAGES) &&  touch $@



$(PROGRAM): $(SOURCES) | $(PACKAGE_CHECK)
	$(VALAC) -o $@  $^ $(VALAC_FLAGS)

clean:
	$(info == Cleaning)
	@rm -rf $(PROGRAM) $(PACKAGE_CHECK)

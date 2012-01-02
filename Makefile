PROGRAM=ifthenelse
SOURCES=$(wildcard *.vala **/*.vala)
PACKAGES=glib-2.0
EMPTY=



PACKAGE_CHECK=.pkgcheck
# VALAC magic.
VALAC=valac
VALAC_PACKAGES=$(foreach PKG, $(PACKAGES), --pkg=$(PKG))
VALAC_FLAGS=-g $(VALAC_PACKAGES) --vapidir=./Vapi/ --pkg=posix




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

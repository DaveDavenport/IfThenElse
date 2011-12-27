PROGRAM=ifthenelse
SOURCES=$(wildcard *.vala **/*.vala)

VALAC=valac
VALAC_FLAGS=-g --pkg=glib-2.0 --pkg=gtk+-3.0 --vapidir=./Vapi/ --pkg=fix

all: $(PROGRAM)

$(PROGRAM): $(SOURCES)
	$(VALAC) -o $@  $^ $(VALAC_FLAGS)

clean:
	$(info Cleaning)
	rm $(PROGRAM)

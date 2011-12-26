PROGRAM=ifthenelse
SOURCES=$(wildcard *.vala **/*.vala)

VALAC=valac
VALAC_FLAGS=-g --pkg=glib-2.0

all: $(PROGRAM)

$(PROGRAM): $(SOURCES)
	$(VALAC) -o $@  $^ $(VALAC_FLAGS)

clean:
	rm $(PROGRAM)

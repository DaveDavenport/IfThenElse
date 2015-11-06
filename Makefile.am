# Specify automake version.
AUTOMAKE_OPTIONS  = 1.11.3

##
# Rofi the program
##
bin_PROGRAMS=ifthenelse

LIBS=\
	@glib_LIBS@\
	@microhttpd_LIBS@\
	@graphviz_LIBS@

AM_CFLAGS=\
	@EXTRA_CFLAGS@\
	@glib_CFLAGS@\
	@microhttpd_CFLAGS@\
	@graphviz_CFLAGS@
	-I$(top_srcdir)/include/\
	-I$(top_srcdir)/config/\
	-I$(top_builddir)/\
	-Werror=missing-prototypes

ifthenelse_VALAFLAGS=\
	--pkg=glib-2.0\
	--vapidir=$(top_srcdir)/Vapi/\
	--pkg=posix\
	--pkg=fix\
	--pkg=libgvc\
	--pkg=libmicrohttpd\
	--target-glib=2.32

ifthenelse_SOURCES=\
	src/main.vala\
	src/Actions/MultiAction.vala\
	src/Actions/ExternalTool.vala\
	src/Actions/SplitAction.vala\
	src/Actions/Single.vala\
	src/Actions/BaseAction.vala\
	src/Triggers/MultiOutputWatch.vala\
	src/Triggers/ExternalToolTrigger.vala\
	src/Triggers/InitTrigger.vala\
	src/Triggers/BetweenTrigger.vala\
	src/Triggers/OutputWatch.vala\
	src/Triggers/Timer.vala\
	src/Triggers/TimeTrigger.vala\
	src/Triggers/BaseTrigger.vala\
	src/Base/BaseClass.vala\
	src/Base/AndCombine.vala\
	src/Base/Combine.vala\
	src/Base/Parser.vala\
	src/Checks/ExternalToolCheck.vala\
	src/Checks/TimeCheck.vala\
	src/Checks/BaseCheck.vala


.PHONY: indent
indent: ${ifthenelse_SOURCES} ${top_srcdir}/config/config.def.c ${helper_test_SOURCES} ${textbox_test_SOURCES} ${ifthenelse_test_SOURCES}
	uncrustify -c ${top_srcdir}/data/uncrustify.cfg --replace $^

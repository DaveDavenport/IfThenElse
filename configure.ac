AC_INIT([ifthenelse], [0.15.10-devel], [https://github.com/DaveDavenport/ifthenelse/])

##
# Setup automake to be silent and in foreign mode.
##
AM_INIT_AUTOMAKE([-Wall -Werror foreign subdir-objects dist-xz])
AM_SILENT_RULES([yes])

##
# Check for compiler
##
AM_PROG_VALAC([0.23.0])

AC_USE_SYSTEM_EXTENSIONS

##
# Check dependencies
##
PKG_PROG_PKG_CONFIG

PKG_CHECK_MODULES([glib],      [glib-2.0 gobject-2.0])
PKG_CHECK_MODULES([graphviz],  [libcgraph libgvc])
PKG_CHECK_MODULES([microhttpd],[libmicrohttpd])

AC_SUBST([EXTRA_CFLAGS], ["-Wall -Wextra -Wparentheses -Winline -pedantic"])

AC_CONFIG_FILES([Makefile ])
AC_OUTPUT

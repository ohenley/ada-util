dnl Autoconf configure script for Ada Util
dnl Copyright (C) 2001 - 2018 Stephane Carrez
dnl Written by Stephane Carrez (Stephane.Carrez@gmail.com)
dnl
dnl  Licensed under the Apache License, Version 2.0 (the "License");
dnl  you may not use this file except in compliance with the License.
dnl  You may obtain a copy of the License at
dnl
dnl     http://www.apache.org/licenses/LICENSE-2.0
dnl
dnl  Unless required by applicable law or agreed to in writing, software
dnl  distributed under the License is distributed on an "AS IS" BASIS,
dnl  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
dnl  See the License for the specific language governing permissions and
dnl  limitations under the License.
dnl 
dnl Process this file with autoconf to produce a configure script.

AC_INIT(src/util.ads)

AC_CANONICAL_SYSTEM
dnl AM_MAINTAINER_MODE

# Current release settings
UTIL_MAJOR_VERSION=1
UTIL_MINOR_VERSION=9
UTIL_MICRO_VERSION=0b
UTIL_VERSION=$UTIL_MAJOR_VERSION.$UTIL_MINOR_VERSION.$UTIL_MICRO_VERSION

AM_GNAT_CHECK_GPRBUILD

# checking for local tools
AC_PROG_CC
AC_PROG_MAKE_SET
AC_PROG_INSTALL
AC_PROG_LN_S

# Set the version number of Ada Util
AC_SUBST(UTIL_VERSION)
AC_SUBST(UTIL_MAJOR_VERSION)
AC_SUBST(UTIL_MINOR_VERSION)
AC_SUBST(UTIL_MICRO_VERSION)

EXEC_PREFIX="$prefix"
AC_SUBST(EXEC_PREFIX)

UTIL_LIBDIR="lib"
AC_SUBST(UTIL_LIBDIR)

AC_MSG_CHECKING([number of processors])
NR_CPUS=`getconf _NPROCESSORS_CONF 2>/dev/null || getconf NPROCESSORS_CONF 2>/dev/null || echo 1`
AC_MSG_RESULT($NR_CPUS)
AC_SUBST(NR_CPUS)

AC_CHECK_PROG(HAVE_PANDOC,pandoc,yes)
AC_CHECK_PROG(HAVE_DYNAMO,dynamo,yes)

os_version='os-none'
AC_MSG_CHECKING([specific operating system sources])
case "${target_os}" in
     linux|linux-*|solaris*|sysv-*)
	src_os='src/os-linux'
	os_version='os-linux'
	;;

     netbsdelf*|openbsd*|dragonfly*|freebsd*)
	src_os='src/os-linux'
	os_version='os-linux'
	;;

     macos*|darwin*)
	src_os='src/os-linux'
	os_version='os-linux'
	;;

     mingw32*|cygwin*|mingw64*)
	src_os='src/os-win32'
	os_version='os-win32'
	;;

     *)
	src_os='src/os-none'
	;;
esac
AC_MSG_RESULT(using $src_os)
UTIL_OS_DIR=$src_os
UTIL_OS_VERSION=$os_version
AC_SUBST(UTIL_OS_DIR)
AC_SUBST(UTIL_OS_VERSION)

AC_MSG_CHECKING([hardware platform])
HARDWARE_PLATFORM=`uname -i || uname -m || echo "unknown"`
AC_MSG_RESULT($HARDWARE_PLATFORM)
AC_SUBST(HARDWARE_PLATFORM)

# Check for gcc intrinsics
AM_HAS_INTRINSIC_SYNC_COUNTERS(src_asm='src/asm-intrinsic',src_asm='')
AC_MSG_CHECKING([specific processor support])
if test T$src_asm = T; then
   case "${target}" in
   ## Intel 386 machines where we don't care about the manufacturer
     i[[34567]]86-*-* | x86_* | x86-*)
       src_asm='src/asm-x86'
       ;;

     *)
       src_asm='src/asm-none'
       ;;

   esac
fi
AC_MSG_RESULT(using $src_asm)
UTIL_ASM_DIR="$src_asm"
AC_SUBST(UTIL_ASM_DIR)

UTIL_HAS_LIBDL="no"
AC_CHECK_HEADERS(dlfcn.h)
AC_CHECK_LIB(dl,dlopen,[
  CFLAGS="$CFLAGS -DHAVE_DLOPEN=1"
  UTIL_HAS_LIBDL="yes"
])
AC_SUBST(UTIL_HAS_LIBDL)

# directories GNAT project gives the installation paths
AM_GNAT_CHECK_PROJECT([directories],[directories])
UTIL_HAVE_PRJ_DIRECTORIES=${gnat_project_directories}
AC_SUBST(UTIL_HAVE_PRJ_DIRECTORIES)

##########################################
# XMLAda library
##########################################

gnat_xml_ada=xmlada-config
AC_MSG_CHECKING([xmlada library])
AC_ARG_WITH(xmlada,
AS_HELP_STRING([--with-xmlada=], [Enable XML serialization]),
[
  if test T${withval} = Tno ; then
    UTIL_HAVE_XML=no;
  else
    gnat_xml_ada=${withval}/xmlada-config;
    WITH_XML_ADA="with \"${withval}\";";
    UTIL_XML_DIR='src/xml';
    UTIL_HAVE_XML='yes';
  fi
],
[
  WITH_XML_ADA='';
  UTIL_XML_DIR='src';
  UTIL_HAVE_XML='yes';
])

if test T$UTIL_HAVE_XML = Tyes ; then
  ac_xml_version=`$gnat_xml_ada --version 2>/dev/null | sed -e 's, ,-,g'`
else
  ac_xml_version=none
fi
case $ac_xml_version in
  XmlAda-3.2*)
      AC_MSG_RESULT($ac_xml_version)
      WITH_XML_ADA="with \"xmlada\";";
      UTIL_XML_DIR='src/xml';
      UTIL_XML_VERSION='3';
      UTIL_HAVE_XML='yes';
      ;;

  XmlAda-4.*|XmlAda-2013|XmlAda-2014)
      AC_MSG_RESULT($ac_xml_version)
      WITH_XML_ADA="with \"xmlada\";";
      UTIL_XML_DIR='src/xml';
      UTIL_XML_VERSION='4';
      UTIL_HAVE_XML='yes';
      ;;

  *)
      AC_MSG_RESULT(no)
      ;;

esac
if test T$UTIL_HAVE_XML = Tyes ; then
  AM_GNAT_CHECK_PROJECT([xmlada_sax],[xmlada_sax])
  if test T$gnat_project_xmlada_sax = Tno; then
    AM_GNAT_CHECK_PROJECT([xmlada],[xmlada])
    if test T$gnat_project_xmlada != Tno; then
      WITH_XML_ADA="with \"xmlada\";";
    else
      UTIL_HAVE_XML=no
    fi
  else
    WITH_XML_ADA="with \"xmlada_sax\";";
    UTIL_XML_VERSION='4'
    UTIL_XML_DIR='src/xml'
  fi
else
  gnat_project_xmlada_sax='no'
fi

if test T$UTIL_HAVE_XML = Tno; then
  WITH_XML_ADA='';
  UTIL_XML_DIR='src';
  UTIL_XML_VERSION='none';
  UTIL_HAVE_XML='no';
fi

AC_SUBST(WITH_XML_ADA)
AC_SUBST(UTIL_XML_DIR)
AC_SUBST(UTIL_XML_VERSION)
AC_SUBST(UTIL_HAVE_XML)

##########################################
# Ada/LZMA library
##########################################
AC_ARG_WITH(lzma,
AS_HELP_STRING([--with-ada-lzma=], [Enable LZMA streams with Ada LZMA]),
[
  if test T${withval} = Tno ; then
    UTIL_HAVE_LZMA=no;
  else
    WITH_LZMA_ADA="with \"${withval}\";";
    UTIL_LZMA_DIR='src/lzma';
    UTIL_HAVE_LZMA='yes';
  fi
],
[
  WITH_LZMA_ADA='';
  UTIL_LZMA_DIR='src';
  UTIL_HAVE_LZMA='yes';
])

AM_GNAT_CHECK_PROJECT([lzma],[lzma])
if test T$gnat_project_lzma = Tno; then
  WITH_LZMA_ADA="";
  UTIL_LZMA_DIR=''
  UTIL_HAVE_LZMA='no'
else
  WITH_LZMA_ADA="with \"lzma\";";
  UTIL_LZMA_DIR='src/lzma'
  UTIL_HAVE_LZMA='yes'
fi

AC_SUBST(WITH_LZMA_ADA)
AC_SUBST(UTIL_LZMA_DIR)
AC_SUBST(UTIL_HAVE_LZMA)

##########################################
# Check to enable/disable shared library
##########################################
AM_SHARED_LIBRARY_SUPPORT
AM_DISTRIB_SUPPORT
AM_COVERAGE_SUPPORT

##########################################
# Check for GNAT traceback in Util.Log.Loggers
##########################################

AC_MSG_CHECKING([traceback in log exceptions])
ac_enable_traceback=yes
AC_ARG_ENABLE(traceback,
[  --enable-traceback      Enable the symbolic traceback dump in logged exceptions (enabled)],
[case "${enableval}" in
  no|none)  ac_enable_traceback=no ;;
  *)        ac_enable_traceback=yes ;;
esac])dnl

AC_MSG_RESULT(${ac_enable_traceback})
UTIL_GNAT_TRACEBACK=$ac_enable_traceback
AC_SUBST(UTIL_GNAT_TRACEBACK)

##########################################
# Test framework selection: aunit or ahven
##########################################

ac_enable_aunit=no

ac_enable_ahven=yes
AC_ARG_ENABLE(ahven,
[  --enable-ahven          Enable internal Ahven support for testutil library and Ada util unit tests (enabled)],
[case "${enableval}" in
  no|none)  ac_enable_ahven= ;;
  *)        ac_enable_ahven=yes
            ac_enable_aunit=no ;;
esac])dnl

AC_ARG_ENABLE(aunit,
[  --enable-aunit          Enable AUnit support for testutil library and Ada util unit tests (disabled)],
[case "${enableval}" in
  no|none)  ac_enable_aunit=no ;;
  *)        ac_enable_aunit=yes ;;
esac])dnl

AC_MSG_CHECKING(whether AUnit support is enabled)
AC_MSG_RESULT($ac_enable_aunit)

AC_MSG_CHECKING(whether Ahven internal support is enabled)
AC_MSG_RESULT($ac_enable_ahven)

if test T$ac_enable_aunit = Tyes; then
   AM_GNAT_CHECK_PROJECT([aunit],[aunit])
   if test T$gnat_project_aunit = Tno; then
	  if test T$ac_enable_ahven = Tno; then
	     AC_MSG_WARN(AUnit is not installed and Ahven is not enabled.)
	     AC_MSG_ERROR(Please install AUnit or enable Ahven with --enable-ahven.)
	  fi
   fi
fi

if test x$ac_enable_ahven = 'xyes' -a x$ac_enable_aunit = 'xyes'; then
   AC_MSG_ERROR(Both Ahven and AUnit testing framework are selected.  Please, choose one of them.)
fi

UTIL_XUNIT_DIR=
UTIL_AUNIT_DIR=
UTIL_AHVEN_DIR=
WITH_AUNIT=

if test x$ac_enable_aunit = 'xyes'; then
  UTIL_AUNIT_DIR=testutil/aunit
  UTIL_XUNIT_DIR='"testutil/aunit"'
  WITH_AUNIT="with \"aunit\";"
fi
if test x$ac_enable_ahven = 'xyes'; then
  UTIL_AHVEN_DIR=testutil/ahven
  case "${target_os}" in
     linux|linux-*|solaris*|sysv-*)
        UTIL_XUNIT_DIR='"testutil/ahven", "testutil/ahven/unix"'
	UTIL_AHVEN_OS_DIR="testutil/ahven/unix"
	;;

     mingw32*|cygwin*|mingw64*)
        UTIL_XUNIT_DIR='"testutil/ahven", "testutil/ahven/windows"'
	UTIL_AHVEN_OS_DIR="testutil/ahven/windows"
	;;

     *)
        UTIL_XUNIT_DIR='"testutil/ahven", "testutil/ahven/unix"'
	UTIL_AHVEN_OS_DIR="testutil/ahven/unix"
	;;
  esac
fi

##########################################
# Check for libcurl
##########################################

UTIL_HAVE_CURL=no
WITH_UTIL_CURL=""
UTIL_CURL_LIB=curl

AC_MSG_CHECKING([curl HTTP client support in Ada Util])
ac_enable_curl=yes
AC_ARG_ENABLE(curl,
[  --enable-curl           Enable the CURL HTTP client support in Ada Util (enabled)],
[case "${enableval}" in
  no|none)  ac_enable_curl=no ;;
  *)        ac_enable_curl=yes ;;
esac])dnl

AC_MSG_RESULT(${ac_enable_curl})
if test T$ac_enable_curl = Tyes; then
  AC_CHECK_LIB($UTIL_CURL_LIB,curl_easy_perform,[
    UTIL_HAVE_CURL=yes
    CFLAGS="$CFLAGS -DHAVE_CURL"
    WITH_UTIL_CURL="with \"util_http_curl\";";
  ])
fi

##########################################
# Check for Ada Web Server
##########################################
AM_GNAT_CHECK_AWS(
  [
    UTIL_HAVE_AWS=no
    WITH_SERVER="";
    WITH_UTIL_AWS="";
  ], [
    UTIL_HAVE_AWS=yes
    WITH_UTIL_AWS="with \"util_http_aws\";";
    WITH_SERVER="with \"$gnat_project_name\";";
  ])

##########################################
# Check for Util.Serialize.Mappers.Vector_Mappers support
##########################################

ac_enable_vector_mappers=yes
AC_MSG_CHECKING([for gcc bug compiling Util.Serialize.Mappers.Vector_Mappers (Bug 53737)])
version=`$GNATMAKE --version | grep GNATMAKE | sed -e 's,GNATMAKE ,,'`
case "$version" in
   4.7.0*|4.7.1*|4.7.2*|4.7.3*)
      AC_MSG_RESULT(yes)
      AC_MSG_WARN(Your compiler is known to fail when compiling a generic package.)
      AC_MSG_WARN(See Bug 53737: Assert_Failure on a generic package with a package as parameter)
      AC_MSG_WARN(The Util.Serialize.Mappers.Vector_Mappers and Util.Http.Rest packages are excluded.)
      ac_enable_vector_mappers=no
      ;;

   *)
      AC_MSG_RESULT(no)
      ac_enable_vector_mappers=yes
      ;;
esac

AC_MSG_CHECKING([whether the Util.Serialize.Mappers.Vector_Mappers package must be compiled])
AC_ARG_ENABLE(vector-mappers,
[  --enable-vector-mappers Enable the Util.Serialize.Mappers.Vector_Mappers package (enabled)],
[case "${enableval}" in
  no|none)  ac_enable_vector_mappers=no ;;
  *)        ac_enable_vector_mappers=yes ;;
esac])dnl

AC_MSG_RESULT(${ac_enable_vector_mappers})
UTIL_HAVE_VECTOR_MAPPERS=$ac_enable_vector_mappers

AC_ARG_ENABLE(link-options-util,
[  --enable-link-options-util=opts
                          Add some linker options when building the Ada Util shared library (disabled)],
[
  UTIL_LIBRARY_OPTIONS=${enableval}
])
AC_MSG_CHECKING([for additional linker options for libada_util])
if test "T${UTIL_LIBRARY_OPTIONS}" != T; then
    UTIL_LIBRARY_OPTIONS="\"-Wl,${UTIL_LIBRARY_OPTIONS}\""
    opts=${UTIL_LIBRARY_OPTIONS}
else
    opts=none
fi
AC_MSG_RESULT($opts)
AC_SUBST(UTIL_LIBRARY_OPTIONS)

AC_ARG_ENABLE(link-options-curl,
[  --enable-link-options-curl=opts
                          Add some linker options when building the Ada Util Curl shared library (disabled)],
[
  UTIL_CURL_LIBRARY_OPTIONS=${enableval}
])
AC_MSG_CHECKING([for additional linker options for libada_util_curl])
if test "T${UTIL_CURL_LIBRARY_OPTIONS}" != T; then
    UTIL_CURL_LIBRARY_OPTIONS="\"-Wl,${UTIL_CURL_LIBRARY_OPTIONS}\""
    opts=${UTIL_CURL_LIBRARY_OPTIONS}
else
    opts=none
fi
AC_MSG_RESULT($opts)
AC_SUBST(UTIL_CURL_LIBRARY_OPTIONS)

AC_SUBST(UTIL_HAVE_VECTOR_MAPPERS)
AC_SUBST(UTIL_HAVE_AWS)
AC_SUBST(WITH_UTIL_AWS)
AC_SUBST(WITH_SERVER)

AC_SUBST(UTIL_HAVE_CURL)
AC_SUBST(WITH_UTIL_CURL)
AC_SUBST(WITH_AUNIT)
AC_SUBST(UTIL_AUNIT_DIR)
AC_SUBST(UTIL_AHVEN_DIR)
AC_SUBST(UTIL_AHVEN_OS_DIR)
AC_SUBST(UTIL_XUNIT_DIR)

AM_GNAT_CHECK_INSTALL

dnl AC_MSG_NOTICE(  XML support:   $WITH_XML_ADA)
dnl AC_MSG_NOTICE(  CURL support:  $WITH_UTIL_CURL)
dnl AC_MSG_NOTICE(  AWS support:   $WITH_UTIL_AWS)
dnl AC_MSG_NOTICE(  XUnit support: $UTIL_XUNIT_DIR)

AC_OUTPUT(
Makefile util.gpr util_http.gpr util_unit.gpr util_http_curl.gpr util_http_aws.gpr
distrib/util_unit.gpr distrib/util.gpr distrib/util_http.gpr distrib/util_http_curl.gpr
distrib/util_http_aws.gpr
)

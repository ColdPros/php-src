PHP_ARG_WITH([sqlite3],
  [whether to enable the SQLite3 extension],
  [AS_HELP_STRING([--without-sqlite3],
    [Do not include SQLite3 support.])],
  [yes])

if test $PHP_SQLITE3 != "no"; then

  dnl when running phpize enable_zts is not available
  if test -z "$enable_zts"; then
    if test -f "$phpincludedir/main/php_config.h"; then
      ZTS=`grep '#define ZTS' $phpincludedir/main/php_config.h|$SED 's/#define ZTS//'`
      if test "$ZTS" -eq "1"; then
        enable_zts="yes"
      fi
    fi
  fi

  PKG_CHECK_MODULES([SQLITE], [sqlite3 > 3.7.4])

  PHP_CHECK_LIBRARY(sqlite3, sqlite3_stmt_readonly,
  [
    PHP_EVAL_INCLINE($SQLITE_CFLAGS)
    PHP_EVAL_LIBLINE($SQLITE_LIBS, SQLITE_SHARED_LIBADD)
    AC_DEFINE(HAVE_SQLITE3, 1, [Define to 1 if you have the sqlite3 extension enabled.])
  ], [
    AC_MSG_ERROR([Please install SQLite 3.7.4 first or check libsqlite3 is present])
  ])

  PHP_CHECK_LIBRARY(sqlite3, sqlite3_key, [
    AC_DEFINE(HAVE_SQLITE3_KEY, 1, [have commercial sqlite3 with crypto support])
  ])

  PHP_CHECK_LIBRARY(sqlite3, sqlite3_column_table_name, [
    AC_DEFINE(SQLITE_ENABLE_COLUMN_METADATA, 1, [have sqlite3 with column metadata enabled])
  ])

  PHP_CHECK_LIBRARY(sqlite3, sqlite3_errstr, [
    AC_DEFINE(HAVE_SQLITE3_ERRSTR, 1, [have sqlite3_errstr function])
  ])

  PHP_CHECK_LIBRARY(sqlite3,sqlite3_load_extension,
    [],
    [AC_DEFINE(SQLITE_OMIT_LOAD_EXTENSION, 1, [have sqlite3 with extension support])
  ])

  PHP_NEW_EXTENSION(sqlite3, sqlite3.c, $ext_shared,,-DZEND_ENABLE_STATIC_TSRMLS_CACHE=1)
  PHP_SUBST(SQLITE3_SHARED_LIBADD)
fi

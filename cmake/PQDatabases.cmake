#
OPTION(STATIC_SSL   "Build OpenSSL statically into ${PROJECT}"    OFF)
OPTION(STATIC_MYSQL "Build MySQL statically into ${PROJECT}"      OFF)
OPTION(STATIC_PGSQL "Build PostgreSQL statically into ${PROJECT}" OFF)
#
# FOR macOS+HomeBrew
IF(APPLE)
  IF(NOT OPENSSL_ROOT_DIR)
    SET(OPENSSL_ROOT_DIR "/usr/local/opt/openssl/")
    IF(NOT EXISTS ${OPENSSL_ROOT_DIR})
      MESSAGE(FATAL_ERROR "Please specify OpenSSL root directory with -DOPENSSL_ROOT_DIR=<PATH> ")
    ENDIF(NOT EXISTS ${OPENSSL_ROOT_DIR})
  ENDIF(NOT OPENSSL_ROOT_DIR)
ENDIF(APPLE)
#
IF(STATIC_SSL)
  SET(OPENSSL_USE_STATIC_LIBS ON)
ENDIF(STATIC_SSL)
#
FIND_PACKAGE(Threads REQUIRED)
SET (LIBS_TO_LINK ${LIBS_TO_LINK} ${CMAKE_THREAD_LIBS_INIT})
#
FIND_PACKAGE(OpenSSL REQUIRED)
SET(LIBS_TO_LINK ${LIBS_TO_LINK} ${OPENSSL_LIBRARIES})
#
FIND_PACKAGE(ZLIB REQUIRED)
SET (LIBS_TO_LINK ${LIBS_TO_LINK} ${ZLIB_LIBRARIES})
#
IF(LINUX)
  SET (LIBS_TO_LINK ${LIBS_TO_LINK} dl rt)
ENDIF(LINUX)
##
#
# MySQL part
# provides WITH_MYSQL, it may be ON, OFF, PATH_TO_MYSQL
IF(WITH_MYSQL)
#
  SET(MYSQL_BASEDIR "" CACHE PATH "Custom MySQL location, use to point to extracted tarball")
  SET(MYSQL_FORK "MYSQL" CACHE STRING "MySQL fork to build with. May be Oracle MySQL, MariaDB, WebScaleSQL, Percona Server or Percona XtraDB Cluster")
  SET_PROPERTY(CACHE MYSQL_FORK PROPERTY STRINGS MYSQL MARIADB WEBSCALESQL PERCONASERVER PERCONACLUSTER)
#
  FIND_PACKAGE(MySQLFork REQUIRED)
  IF(MYSQL_FOUND)
    ADD_DEFINITIONS(-DHAVE_MYSQL)
  ENDIF(MYSQL_FOUND)
  INCLUDE_DIRECTORIES( ${MYSQL_INCLUDE_DIR} )
  IF (MYSQL_FORK STREQUAL "MARIADB")
    INCLUDE_DIRECTORIES( ${MYSQL_INCLUDE_DIR}/.. )
  ENDIF(MYSQL_FORK STREQUAL "MARIADB")
  SET (LIBS_TO_LINK ${LIBS_TO_LINK} ${MYSQL_LIBRARY})
ENDIF(WITH_MYSQL)
#
# PostgreSQL
IF(WITH_PGSQL)
  #
  SET(PGSQL_BASEDIR "" CACHE PATH "Custom PostgreSQL location, use to point to extracted tarball")
  #
  FIND_PACKAGE(PostgreSQL REQUIRED)
  IF(PostgreSQL_FOUND)
    ADD_DEFINITIONS(-DHAVE_PGSQL)
  ENDIF(PostgreSQL_FOUND)
  INCLUDE_DIRECTORIES(${PostgreSQL_INCLUDE_DIRS})
  SET(LIBS_TO_LINK ${LIBS_TO_LINK} ${PostgreSQL_LIBRARIES})
ENDIF(WITH_PGSQL)

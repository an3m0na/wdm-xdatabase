#!/bin/bash

basedir=/Applications/eXist-db.app/Contents/Resources/eXist-db
version=2.0-tech-preview

# manually install jars into local maven repository
#mvn install:install-file -Dfile=$basedir/exist.jar -DgroupId=org.exist-db -DartifactId=exist -Dversion=$version -Dpackaging=jar
#mvn install:install-file -Dfile=$basedir/exist-optional.jar -DgroupId=org.exist-db -DartifactId=exist-optional -Dversion=$version -Dpackaging=jar
#mvn install:install-file -Dfile=$basedir/lib/core/xmldb.jar -DgroupId=org.exist-db -DartifactId=exist-xmldb -Dversion=$version -Dpackaging=jar
#mvn install:install-file -Dfile=$basedir/lib/extensions/exist-versioning.jar -DgroupId=org.exist-db -DartifactId=exist-versioning -Dversion=$version -Dpackaging=jar

#mvn install:install-file -Dfile=$basedir/lib/core/ws-commons-util-1.0.2.jar -DgroupId=org.exist-db -DartifactId=ws-commons-util -Dversion=$version -Dpackaging=jar
#mvn install:install-file -Dfile=$basedir/lib/core/xmlrpc-common-3.1.3.jar -DgroupId=org.exist-db -DartifactId=xmlrpc-common -Dversion=$version -Dpackaging=jar
#mvn install:install-file -Dfile=$basedir/lib/core/xmlrpc-client-3.1.3.jar -DgroupId=org.exist-db -DartifactId=xmlrpc-client -Dversion=$version -Dpackaging=jar

mvn install:install-file -Dfile=$basedir/lib/core/commons-io-2.4.jar -DgroupId=org.exist-db -DartifactId=commons-io -Dversion=$version -Dpackaging=jar

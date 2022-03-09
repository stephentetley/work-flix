# S4 Loader

This app is a `sub project` hence the `HISTORY.md` and `LICENSE.md` files
that are needed by the Flix packager.

~~~ .{cmd}

> java -jar ..\..\..\..\flix\bin\flix-working.jar check
> java -jar ..\..\..\..\flix\bin\flix-working.jar build
> java -jar ..\..\..\..\flix\bin\flix-working.jar build-jar

~~~

To run (currently) after building an executable jar - note `Main` is at the toplevel:

~~~ .{cmd}

java -cp "./S4Loader.jar;./lib/*;../../../../flix/bin/flix-working.jar" Main "help"

~~~

Or 

~~~ .{cmd}

java -cp "./S4Loader.jar;./lib/commons-collections4-4.4.jar;./lib/commons-compress-1.20.jar;./lib/commons-csv-1.8.jar;./lib/commons-dbutils-1.7.jar;./lib/commons-io-2.6.jar;./lib/commons-math3-3.6.1.jar;./lib/csviojava-1.0.jar;./lib/excel-streaming-reader-3.1.1.jar;flix-basicdbjava-1.0.jar;./lib/flix-sandboxjava-1.0.jar;./lib/poi-5.0.0.jar;./lib/poi-ooxml-5.0.0.jar;./lib/poi-ooxml-full-5.0.0.jar;./lib/sheetiojava-1.0.jar;./lib/sqlite-jdbc-3.36.0.3.jar;./lib/xmlbeans-4.0.0.jar;../../../../flix/bin/flix-working.jar" Main

~~~

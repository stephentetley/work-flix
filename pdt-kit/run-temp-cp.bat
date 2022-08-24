
java -jar ..\..\..\flix\bin\flix-working.jar build-pkg

java -cp "./lib/*;../../../flix/bin/flix-working.jar" ca.uwaterloo.flix.Main ./temp/run-read.flix ^
    ./pdt-kit.fpkg ^
    ./lib/interop-json.fpkg ^
    ./lib/basis-base.fpkg ^
    ./lib/flix-time.fpkg ^
    ./lib/interop-base.fpkg ^
    ./lib/monad-lib.fpkg ^
    ./lib/sheetio.fpkg ^
    ./lib/withindex-classes.fpkg


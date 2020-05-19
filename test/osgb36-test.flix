use S4Lib/Osgb36.{EastingNorthing};

@test
def test01(): Unit & Impure = 
    S4Lib/Osgb36.parse("SE2233466778") 
        |> Result.flatMap(S4Lib/Osgb36.toEastingNorthing) 
        |> x1 -> Result.getWithDefault(x1, {easting=0, northing = 0})
        |> x2 -> Console.printLine("{easting: " + Int32.toString(x2.easting) + ", northing: " + Int32.toString(x2.northing) + "}")

@test
def test02(): Result[Unit, System.Error] & Impure = 
    use Result.flatMap;
    let* ngr = S4Lib/Osgb36.toNGR({easting = 422334, northing = 466778});
    let _ = Console.printLine(S4Lib/Osgb36.toString(ngr));
    Ok()
/*
 * Copyright 2020 Stephen Tetley
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

namespace AutoLifting/Phase2/AibAttributeReader {
        
    use SheetIO.SheetReader;
    use SheetIO.NamedRowEvaluator;
    use SheetIO.DataFormatter;

    use AutoLifting/Datatypes.AibAttributeRow;
    use AutoLifting.ReportMonad;
    


    /// Must be a *.xlsx (OO-XML) file.
    pub def getAibAttributeRows(path: System.FilePath): ReportMonad[List[AibAttributeRow]] =
        use AutoLifting/ReportMonad.{liftActionResult};
        liftActionResult(_ -> SheetIO/SheetReader.runXlsx(readAibAttributeRows(), path))
        

    def readAibAttributeRows() : SheetReader[List[AibAttributeRow]] =
        use SheetIO/SheetReader.{flatMap, return, getSheetAt, liftAction, maximalNamedRows}; 
        let* s1 = getSheetAt(0); 
        let* dfmt = liftAction(_ -> SheetIO/DataFormatter.new()); 
        maximalNamedRows(s1, 0, 1, evalAibAttributeRow(dfmt))

    def evalAibAttributeRow(dfmt: DataFormatter): NamedRowEvaluator[AibAttributeRow] = 
        use SheetIO/NamedRowEvaluator.{flatMap, return, map, alt, getStringNamed, 
                getFloat64Named, getStringNamedWithDefault, optional, getStringNamedWithDataFormatter};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11) ->
                { pliReference      = x1
                , installedFrom     = x2
                , manufacturer      = x3
                , model             = x4
                , specificModel     = x5
                , serialNumber      = x6
                , osgb36            = x7
                , workLoad          = x8
                , workLoadUnits     = x9
                , statutoryRef      = x10
                , testCertNum       = x11
                })
            <&> logEval(getStringNamed("Reference"))
            <*> getLocalDateNamed("Installed From")
            <*> getStringNamed("Manufacturer")
            <*> getStringNamed("Model")
            <*> getStringNamedWithDefault("Specific Model/Frame", "")
            <*> getCouldBeNumericalNamed("Serial No", dfmt)
            <*> getStringNamed("Loc.Ref.")
            <*> optional(getFloat64Named("Work Load"))
            <*> getStringNamedWithDefault("Work Load Units", "")
            /// Need to use DataFormatter as the string might actually be seen as a numeric to Excel
            <*> getCouldBeNumericalNamed("YWRef", dfmt)
            <*> getCouldBeNumericalNamed("Test Cert No", dfmt)

    def getLocalDateNamed(label: String): NamedRowEvaluator[Time.LocalDate] = 
        use SheetIO/NamedRowEvaluator.{map, getLocalDateTimeNamed};
        map(Time/LocalDateTime.toLocalDate,  getLocalDateTimeNamed(label))
        
    /// TODO - this works for the sample data but ideally we would use getStringNamedWithDataFormatter...
    def getCouldBeNumericalNamed(label: String, _dfmt: DataFormatter): NamedRowEvaluator[String] = 
        use SheetIO/NamedRowEvaluator.{map, alt, getStringNamedWithDefault, getInt64Named};
        alt(getStringNamedWithDefault(label, ""), map(Int64.toString, getInt64Named(label)))
        


    def logEval(ma: NamedRowEvaluator[String]): NamedRowEvaluator[String] = 
        use SheetIO/NamedRowEvaluator.{flatMap, return, liftAction};
        let* ans = ma;
        let* _ = liftAction(_ -> Console.printLine(ans));
        return(ans)
  

}
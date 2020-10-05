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

    use AutoLifting.ReportMonad;


    type alias AibAttributeRow = 
        { pliReference: String
        , installedFrom: Time.LocalDate
        , manufacturer: String
        , model: String
        , osgb36: String
        , workLoad: Option[Float64]
        , workLoadUnits: String
        , statutoryRef: String
        , testCertNum: String
        }

    /// Must be a *.xlsx (OO-XML) file.
    pub def getAibAttributeRows(path: System.FilePath): ReportMonad[List[AibAttributeRow]] =
        use AutoLifting/ReportMonad.{liftActionResult};
        liftActionResult(_ -> SheetIO/SheetReader.runXlsx(readAibAttributeRows(), path))
        

    def readAibAttributeRows() : SheetReader[List[AibAttributeRow]] =
        use SheetIO/SheetReader.{flatMap, return, getSheetAt, maximalNamedRows}; 
        let* s1 = getSheetAt(0); 
        maximalNamedRows(s1, 0, 1, evalAibAttributeRow())

    def evalAibAttributeRow(): NamedRowEvaluator[AibAttributeRow] = 
        use SheetIO/NamedRowEvaluator.{flatMap, return, map, alt, getStringNamed, 
                getFloat64Named, getStringNamedWithDefault, optional, getInt64Named};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5, x6, x7, x8, x9) ->
                { pliReference      = x1
                , installedFrom     = x2
                , manufacturer      = x3
                , model             = x4
                , osgb36            = x5
                , workLoad          = x6
                , workLoadUnits     = x7
                , statutoryRef      = x8
                , testCertNum       = x9
                })
            <&> logEval(getStringNamed("Reference"))
            <*> getLocalDateNamed("Installed From")
            <*> getStringNamed("Manufacturer")
            <*> getStringNamed("Model")
            <*> getStringNamed("Loc.Ref.")
            <*> optional(getFloat64Named("Work Load"))
            <*> getStringNamedWithDefault("Work Load Units", "")
            /// TODO need to use DataFormatter to read int as string...
            <*> alt(getStringNamedWithDefault("YWRef", ""), map(Int64.toString, getInt64Named("YWRef")))
            <*> alt(getStringNamedWithDefault("Test Cert No", ""), map(Int64.toString, getInt64Named("Test Cert No")))

    def getLocalDateNamed(label: String): NamedRowEvaluator[Time.LocalDate] = 
        use SheetIO/NamedRowEvaluator.{map, getLocalDateTimeNamed};
        map(Time/LocalDateTime.toLocalDate,  getLocalDateTimeNamed(label))
        
    def logEval(ma: NamedRowEvaluator[String]): NamedRowEvaluator[String] = 
        use SheetIO/NamedRowEvaluator.{flatMap, return, liftAction};
        let* ans = ma;
        let* _ = liftAction(_ -> Console.printLine(ans));
        return(ans)
  

}
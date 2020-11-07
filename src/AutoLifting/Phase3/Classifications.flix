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

namespace AutoLifting/Phase3/LiftingClassifications {

    use SheetIO.SheetReader;
    use SheetIO.NamedRowEvaluator;

    use AssetLib/S4/Simple/Datatypes.{Classification};
    use AutoLifting/Common/Datatypes.{S4CharAttributes};
    use AutoLifting/Common.ReportMonad;

    type alias LiftingMapping = 
        { objectClass: String
        , workingLoadField: String
        , workingLoadUnitField: String
        }


    pub def getFixedClassifications[r](x: { pliReference: String
                                          , parentSaiReference: String
                                          , s4Class: String
                                          , longText: Option[String]
                                          , charAttributes: S4CharAttributes | r}): ReportMonad[List[Classification]] = 
        use AutoLifting/Common/ReportMonad.{flatMap, return};
        let c1   = {className = "EAST_NORTH", charName = "EASTING", datatype = "Int", value = Int32.toString(x.charAttributes.easting)};
        let c2   = {className = "EAST_NORTH", charName = "NORTHING", datatype = "Int", value = Int32.toString(x.charAttributes.northing)};
        let c3   = {className = "AIB_REFERENCE", charName = "AI2_AIB_REFERENCE", datatype = "Text", value = x.pliReference};
        let c4   = {className = "AIB_REFERENCE", charName = "AI2_AIB_REFERENCE", datatype = "Text", value = x.parentSaiReference};
        let c5   = {className = "AIB_REFERENCE", charName = "S4_AIB_REFERENCE", datatype = "Text", value = ""};
        let c6   = {className = x.s4Class, charName = "UNICLASS_CODE", datatype = "Text", value = ""};
        let c7   = {className = x.s4Class, charName = "UNICLASS_DESC", datatype = "Text", value = ""};
        let rest = match x.longText {
            case Some(s) => { 
                if (String.length(s) >= 30) 
                    {className = x.s4Class, charName = "LOCATION_ON_SITE", datatype = "Text", value = "SEE LONG TEXT"} :: Nil
                else 
                    {className = x.s4Class, charName = "LOCATION_ON_SITE", datatype = "Text", value = s} :: Nil
            }
            case None => Nil
        };
        return(c1 :: c2 :: c3 :: c4 :: c5 :: c6 :: c7 :: rest)

    pub def getWorkLoadClassifications[r](m: Map[String, (String, String)], 
                                          x: { s4Class: String
                                             , charAttributes: S4CharAttributes | r}): ReportMonad[List[Classification]] = 
        use AutoLifting/Common/ReportMonad.{flatMap, return, throwError};
        match (x.charAttributes.workLoad, x.charAttributes.workLoadUnits) {
            case (Some(d), s) if !(String.isEmpty(s)) => match Map.get(x.s4Class, m) {
                case None => throwError("getLiftingClassifications - No mapping for class ${x.s4Class}")
                case Some(pair) => { 
                    let (loadField, unitField) = pair;
                    let v1 = {className = x.s4Class, charName = loadField, datatype = "Decimal", value = Float64.toString(d)};
                    let v2 = {className = x.s4Class, charName = unitField, datatype = "Int", value = s};
                    return(v1 :: v2 :: Nil)
                }
            }
            case (_, _) => return(Nil)
        }
       



    pub def loadLiftingMapping(path: System.FilePath): ReportMonad[Map[String, (String, String)]] =
        use AutoLifting/Common/ReportMonad.{liftActionResult};
        liftActionResult(_ -> SheetIO/SheetReader.runXlsx(readLiftingMapping(), path))


    def readLiftingMapping() : SheetReader[Map[String, (String, String)]] =
        use SheetIO/SheetReader.{flatMap, return, getSheetAt, namedRowsFrom}; 
        let* s1     = getSheetAt(0); 
        let* xs     = namedRowsFrom(s1, 0, 1, evalLiftingMappingRow());
        let m1      = buildLiftingMap(xs);
        return(m1)


    def buildLiftingMap(xs: List[LiftingMapping]): Map[String, (String, String)] = 
        let add1 = (ac, r1) -> Map.insert(r1.objectClass, (r1.workingLoadField, r1.workingLoadUnitField), ac);
        List.foldLeft(add1, Map.empty(), xs)


    def evalLiftingMappingRow(): NamedRowEvaluator[LiftingMapping] = 
        use SheetIO/NamedRowEvaluator.{flatMap, return, getStringNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        use String.{trim};
        ((x1, x2, x3) ->
                { objectClass           = x1
                , workingLoadField      = x2
                , workingLoadUnitField  = x3
                })
            <&> getStringNamed("Object Classification")
            <*> getStringNamed("Working Load")
            <*> getStringNamed("Working Load Units")

}
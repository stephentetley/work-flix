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

namespace AutoLifting/Phase2/AddAttributes {
    
    use SheetIO.DataFormatter;
    use SheetIO.NamedRowEvaluator;
    use SheetIO.SheetReader;

    use AssetLib/Common/Osgb36.EastingNorthing;

    use AutoLifting/Datatypes.{AibAttributeRow, S4CharAttributes, EquiAttributes};
    use AutoLifting.ReportMonad;

        
    /// The records here can be simplified...
    pub def getAttributes(attribsMap: Map[String, AibAttributeRow], 
                          pliReference: String): ReportMonad[{charAttributes: S4CharAttributes, equiAttributes: EquiAttributes}] = 
        use AutoLifting/ReportMonad.{flatMap, return, throwError};
        match Map.get(pliReference, attribsMap) {
            case None => throwError("updateAttributes - No attributes for ${pliReference}")
            case Some(attrs) => { 
                let eattrs      = attrs.equiAttributes;
                let* eastNorth  = getEastingNorthing(attrs.charAttributes.osgb36);
                let cattrs       = {+easting = eastNorth.easting, +northing = eastNorth.northing, -osgb36 | attrs.charAttributes}; 
                return({equiAttributes = eattrs, charAttributes = cattrs})
            }
        }



    def getEastingNorthing(ngr: String): ReportMonad[EastingNorthing] = 
        use AssetLib/Common/Osgb36.{parse, toEastingNorthing};
        use AutoLifting/ReportMonad.{flatMap, liftActionResult};
        let* ngr1 = liftActionResult(_ -> parse(ngr) as & Impure);
        liftActionResult(_ -> toEastingNorthing(ngr1) as & Impure)


    pub def loadAttributeLookups(path: System.FilePath): ReportMonad[Map[String, AibAttributeRow]] =
        use AutoLifting/ReportMonad.{map}; 
        map(buildAttributeLookups, getAibAttributeRows(path))
        

    def buildAttributeLookups(xs: List[AibAttributeRow]): Map[String, AibAttributeRow] = 
        List.foldLeft((ac, x) ->  Map.insert(x.pliReference, x, ac), Map.empty(), xs)


    /// Must be a *.xlsx (OO-XML) file.
    def getAibAttributeRows(path: System.FilePath): ReportMonad[List[AibAttributeRow]] =
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
        use String.{trim};
        ((x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13) ->
                { pliReference      = x1
                , equiAttributes = 
                    { assetStatus       = x2
                    , installedFrom     = x3
                    , manufacturer      = x4.trim()
                    , model             = x5.trim()
                    , partNumber        = x6.trim()
                    , serialNumber      = x7.trim()
                    }
                , charAttributes = 
                    { osgb36            = x8
                    , locationOnSite    = x9.trim()
                    , workLoad          = x10
                    , workLoadUnits     = x11
                    , statutoryRef      = x12.trim()
                    , testCertNum       = x13.trim()
                    }
                })
            <&> getStringNamed("Reference")
            <*> logEval(getStringNamed("AssetStatus"))
            <*> getLocalDateNamed("Installed From")
            <*> getStringNamed("Manufacturer")
            <*> getStringNamed("Model")
            <*> getStringNamedWithDefault("Specific Model/Frame", "")            
            <*> getCouldBeNumericalNamed("Serial No", dfmt)
            <*> getStringNamed("Loc.Ref.")
            <*> getStringNamedWithDefault("Location On Site", "")
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
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
    
    use AssetLib/Common/Osgb36.EastingNorthing;

    use AutoLifting/Datatypes.{AibAttributeRow, S4CharAttributes, EquiAttributes};
    use AutoLifting.ReportMonad;

    pub def loadAttributeLookups(path: System.FilePath): ReportMonad[Map[String, AibAttributeRow]] =
        use AutoLifting/ReportMonad.{map}; 
        map(buildAttributeLookups, 
            AutoLifting/Phase2/AibAttributeReader.getAibAttributeRows(path)
        )
        

    pub def updateAttributes[r](m: Map[String, AibAttributeRow], 
                                xs: List[{pliReference: String | r}]): ReportMonad[List[{charAttributes: S4CharAttributes, equiAttributes: EquiAttributes, pliReference: String | r}]] = 
        AutoLifting/ReportMonad.mapM(updateAttributes1(m), xs)

    pub def updateAttributes1[r](m: Map[String, AibAttributeRow], 
                                 x: {pliReference: String | r}): ReportMonad[{charAttributes: S4CharAttributes, equiAttributes: EquiAttributes, pliReference: String | r}] = 
        use AutoLifting/ReportMonad.{flatMap, return, throwError};
        match Map.get(x.pliReference, m) {
            case None => throwError("updateAttributes - No attributes for ${x.pliReference}")
            case Some(attrs) => { 
                let eattrs = attrs.equiAttributes;
                let* eastNorth = getEastingNorthing(attrs.charAttributes.osgb36);
                let cattrs  = {+easting = eastNorth.easting, +northing = eastNorth.northing, -osgb36 | attrs.charAttributes}; 
                let x1  = { +equiAttributes = eattrs, +charAttributes = cattrs | x }; 
                return(x1)
            }
        }
        

    def buildAttributeLookups(xs: List[AibAttributeRow]): Map[String, AibAttributeRow] = 
        List.foldLeft((ac, x) ->  Map.insert(x.pliReference, x, ac), Map.empty(), xs)

    def getEastingNorthing(ngr: String): ReportMonad[EastingNorthing] = 
        use AssetLib/Common/Osgb36.{parse, toEastingNorthing};
        use AutoLifting/ReportMonad.{flatMap, liftActionResult};
        let* ngr1 = liftActionResult(_ -> parse(ngr) as & Impure);
        liftActionResult(_ -> toEastingNorthing(ngr1) as & Impure)
        

}
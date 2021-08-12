/*
 * Copyright 2021 Stephen Tetley
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


namespace AssetLib/GenS4/AibFacts/Attributes/Equipment {

    use SheetIO.NamedRowEvaluator;
    use SheetIO.SheetReader;
    use SheetIO/Reader.{XlsxSource};


    /// This reads a record not a relation!


    /// P AND I Tag No
    /// Serial No	
    /// Specific Model/Frame	
    /// Location On Site * 
    /// Weight kg
    ///
    /// Location On Site becomes an S4 Characteristic not an equipment
    /// attribute so we treat it differently.


    type alias EquipmentAttributes = 
        { aibref: String
        , installedFrom: Time.LocalDate
        , manufacturer: String
        , model: String
        , status: String
        , pandiTag: String
        , serialNumber: String
        , specificModelFrame: String
        , weightKg: Option[Float64]
        }


    /// Read from Aib file...

    /// Reads `Location On Site` at same time...
    pub def readEquipmentData(src: XlsxSource): Result[List[EquipmentAttributes], String] & Impure =
        SheetIO/Reader.readAllNamedRows(src, getEquipmentAttibutes())
            


    pub def getEquipmentAttibutes(): NamedRowEvaluator[EquipmentAttributes] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, optional, getNonEmptyContentNamed, getContentNamed, 
            getFloat64Named, getLocalDateNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5, x6, x7, x8, x9) -> 
            { aibref                = x1
            , installedFrom         = x2 
            , manufacturer          = x3
            , model                 = x4
            , status                = x5
            , pandiTag              = x6
            , serialNumber          = x7
            , specificModelFrame    = x8
            , weightKg              = x9
            })
            <&> getNonEmptyContentNamed("Reference")            
            <*> getLocalDateNamed("Installed From")
            <*> getContentNamed("Manufacturer")
            <*> getContentNamed("Model")
            <*> getContentNamed("AssetStatus")
            <*> getContentNamed("P AND I Tag No")
            <*> getContentNamed("Serial No")
            <*> getContentNamed("Specific Model/Frame")
            <*> optional(getFloat64Named("Weight kg"))

}

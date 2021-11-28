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

    use AssetLib/GenS4.{GenMonad};


    /// This reads a record not a relation.


    /// P AND I Tag No
    /// Serial No	
    /// Specific Model/Frame	
    /// Location On Site * 
    /// Weight kg
    ///
    /// Location On Site becomes an S4 Characteristic not an equipment
    /// attribute so we treat it differently.


    pub type alias EquipmentAttributes = 
        { aibref :: String
        , installedFrom :: Time.LocalDate
        , status :: String
        , pandiTag :: String
        , serialNumber :: String
        , specificModelFrame :: String
        , weightKg :: Option[Float64]
        }


    /// Read from Aib file...

    /// Reads `Location On Site` at same time...
    pub def readEquipmentData(src: XlsxSource): GenMonad[List[EquipmentAttributes]] =
        AssetLib/GenS4/GenMonad.liftActionResult(_ -> SheetIO/Reader.allNamedRows(getEquipmentAttibutes(), src))
            


    def getEquipmentAttibutes(): NamedRowEvaluator[EquipmentAttributes] =
        use SheetIO/NamedRowEvaluator.{optional, getNonEmptyContentNamed, getContentNamed, 
            getFloat64Named, getLocalDateNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5, x6, x7) -> 
            { aibref                = x1
            , installedFrom         = x2 
            , status                = x3
            , pandiTag              = x4
            , serialNumber          = x5
            , specificModelFrame    = x6
            , weightKg              = x7
            })
            <&> getNonEmptyContentNamed("Reference")            
            <*> getLocalDateNamed("Installed From")
            <*> getContentNamed("AssetStatus")
            <*> getContentNamed("P AND I Tag No")
            <*> getContentNamed("Serial No")
            <*> getContentNamed("Specific Model/Frame")
            <*> optional(getFloat64Named("Weight kg"))

}

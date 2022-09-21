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

    use Functor.{<$>};
    use Applicative.{<*>};

    use SheetIO.NamedRowEvaluator;
    use SheetIO.SheetReader;
    use Compatibility.{XlsxSource};

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
        ((x1, x2, x3, x4, x5, x6, x7) -> 
            { aibref                = x1
            , installedFrom         = x2 
            , status                = x3
            , pandiTag              = x4
            , serialNumber          = x5
            , specificModelFrame    = x6
            , weightKg              = x7
            })
            <$> getNonEmptyContentNamed("Reference")
            <*> getLocalDateNamed("Installed From")
            <*> getContentNamed("AssetStatus")
            <*> getContentNamed("P AND I Tag No")
            <*> getSerialNumberNamed("Serial No")
            <*> getContentNamed("Specific Model/Frame")
            <*> optional(getFloat64Named("Weight kg"))

    /// Excel may convert serial numbers to exponential format e.g "9.60121E+12" when read as a String.
    /// Try to read as a number first...
    def getSerialNumberNamed(label: String): NamedRowEvaluator[String] =
        use SheetIO/NamedRowEvaluator.{flatMap, map, optional, alt, getCellTypeNamed, getContentNamed, getInt64Named};
        let* celltype = optional(getCellTypeNamed(label));
        match celltype {
            case Some(SheetIO/CellType.TyNumeric) => alt(map(Int64.toString, getInt64Named(label)), serialNumberFallBack(label))
            case _                                => getContentNamed(label)
        }


    /// If we need this we will have lost precision...
    def serialNumberFallBack(label: String): NamedRowEvaluator[String] =
        use SheetIO/NamedRowEvaluator.{flatMap, point, getContentNamed};
        let* s  = getContentNamed(label);
        match AssetLib/Base/Utils.readExponentInt64(s) {
            case Ok(d) if d >= 99999i64 => point("${d}")        /// TODO don't want to rely on ToString
            case _                      => point(s)
        }


}

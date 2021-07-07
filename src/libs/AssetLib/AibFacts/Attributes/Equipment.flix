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


namespace AssetLib/AibFacts/Attributes/Equipment {

    use SheetIO.NamedRowEvaluator;
    use SheetIO.SheetReader;
    use SheetIO/Reader.{XlsxSource};

    use AssetLib/AibFacts/Utils.{getStringValuedFact};


    /// P AND I Tag No
    /// Serial No	
    /// Specific Model/Frame	
    /// Location On Site * 
    /// Weight kg
    ///
    /// Location On Site becomes an S4 Characteristic not an equipment
    /// attribute so we treat it differently.


    pub rel EquipmentAttributes(aibref: String,
                                installedFrom: Time.LocalDate,
                                manufacturer: String,
                                model: String,
                                status: String, 
                                pandiTag: String,
                                serialNumber: String,
                                specificModelFrame: String,
                                weightKg: Option[Float64])

    pub rel LocationOnSite(aibref: String, text: String)
    pub rel Osgb36GridRef(aibref: String, gridRef: String)

    /// Read from Aib file...

    /// Reads `Location On Site` at same time...
    pub def readEquipmentData(src: XlsxSource): Result[#{EquipmentAttributes, LocationOnSite | r}, String] & Impure =
        AssetLib/AibFacts/Utils.readAibFacts(equipmentFacts(), true, src)
        
    /// Just reads `Location On Site`...
    pub def readLocationOnSiteData(src: XlsxSource): Result[#{LocationOnSite | r}, String] & Impure =
        AssetLib/AibFacts/Utils.readAibFacts(getLocationOnSite(), true, src)

    /// Just reads `Osgb36GridRef`...
    pub def readOsgb36GridRefData(src: XlsxSource): Result[#{Osgb36GridRef | r}, String] & Impure =
        AssetLib/AibFacts/Utils.readAibFacts(getOsgb36GridRef(), true, src)


    pub def equipmentFacts(): NamedRowEvaluator[#{EquipmentAttributes, LocationOnSite | r}] =    
        use SheetIO/NamedRowEvaluator.{flatMap, return, withDefault};
        let* c1 = withDefault(getEquipmentAttibutes(), #{});  
        let* c2 = withDefault(getLocationOnSite(), #{});
        return(c1 <+> c2)


    pub def getLocationOnSite(): NamedRowEvaluator[#{LocationOnSite | r}] =
        getStringValuedFact("Location On Site",  (aibref, ans) -> #{ LocationOnSite(aibref, ans). })
        
   pub def getOsgb36GridRef(): NamedRowEvaluator[#{Osgb36GridRef | r}] =
        getStringValuedFact("Loc.Ref.",  (aibref, ans) -> #{ Osgb36GridRef(aibref, ans). })        


    pub def getEquipmentAttibutes(): NamedRowEvaluator[#{EquipmentAttributes | r}] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, optional, getNonEmptyContentNamed, getContentNamed, 
            getFloat64Named, getLocalDateNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5, x6, x7, x8, x9) -> 
            #{ EquipmentAttributes(x1,x2, x3, x4, x5, x6, x7, x8, x9). })
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

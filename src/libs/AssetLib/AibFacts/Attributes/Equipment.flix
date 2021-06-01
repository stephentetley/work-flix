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

    use AssetLib/AibFacts/Utils.{getStringValuedFact};


    /// P AND I Tag No
    /// Serial No	
    /// Specific Model/Frame	
    /// Location On Site * 
    /// Weight kg
    ///
    /// Location On Site becomes an S4 Characteristic not an equipment
    /// attribute so we treat it differently.


    pub rel EquipmentAttibutes(aibref: String,
                                pandiTag: String,
                                specificModelFrame: String,
                                serialNumber: String,
                                weightKg: Option[Float64])

    pub rel LocationOnSite(aibref: String, text: String)


    /// Read from Aib file...

    /// Reads `Location On Site` at same time...
    pub def readEquipmentData(sheetName: String, 
                                path: System.FilePath): Result[#{EquipmentAttibutes, LocationOnSite | r}, String] & Impure =
        AssetLib/AibFacts/Utils.readAibFacts(equipmentFacts(), true, sheetName, path)
        
    /// Just reads `Location On Site`...
    pub def readLocationOnSiteData(sheetName: String, 
                                path: System.FilePath): Result[#{LocationOnSite | r}, String] & Impure =
        AssetLib/AibFacts/Utils.readAibFacts(getLocationOnSite(), true, sheetName, path)


    pub def equipmentFacts(): NamedRowEvaluator[#{EquipmentAttibutes, LocationOnSite | r}] =    
        use SheetIO/NamedRowEvaluator.{flatMap, return, withDefault};  
        let* c1 = withDefault(getLocationOnSite(), #{});
        let* c2 = withDefault(getEquipmentAttibutes(), #{});
        return(c1 <+> c2)


    pub def getLocationOnSite(): NamedRowEvaluator[#{LocationOnSite | r}] =
        getStringValuedFact("Location On Site",  (aibref, ans) -> #{ LocationOnSite(aibref, ans). })
        

    pub def getEquipmentAttibutes(): NamedRowEvaluator[#{EquipmentAttibutes | r}] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, optional, getContentNamed, getFloat64Named}; 
        let* aibref     = getContentNamed("Reference");
        let* pandi      = getContentNamed("P AND I Tag No");
        let* model      = getContentNamed("Specific Model/Frame");
        let* serialNum  = getContentNamed("Serial No");
        let* weightKg   = optional(getFloat64Named("Weight kg"));
        return(#{ EquipmentAttibutes(aibref, pandi, model, serialNum, weightKg). })


}

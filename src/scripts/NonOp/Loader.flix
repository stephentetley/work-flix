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


namespace AssetScripts/NonOp/Loader {

    use SheetIO.NamedRowEvaluator;
    use SheetIO.RowEvaluator;
    use SheetIO/Reader.{XlsxSource};
    
    use AssetScripts/NonOp/Relations.{AchFlocWorkItem, PlantEquipWorkItem, 
        InstallationMapping, SiteEastNorth, 
        EquipmentMapping, PlantAssetType, GrandParentParentNames, PandITag, 
        AssetTypeDescription, EquipProperties};




    /// Read from Aib xlsx export file...
    pub def readPlantEquipWorkItems(src: XlsxSource): Result[List[PlantEquipWorkItem], String] & Impure =
        SheetIO/Reader.readSomeRows(src, evalPlantEquipWorkItem())
            |> Result.map(List.distinctWith((x, y) -> x.plinum == y.plinum))


    /// Excel file has duplicate names so use alphabetical index ...
    /// Must filter that ProcessAssetTypeDescription(AH) is not "CATCHMENT"  
    def evalPlantEquipWorkItem(): RowEvaluator[Option[PlantEquipWorkItem]] =
        use SheetIO/RowEvaluator.{getColumnIndex, getTrimmedContentAt};
        use SheetIO/RowEvaluator.{<&>, <*>, >>=};
        ((ah1, av1, aw1, am1, az1, ba1, be1, ay1, aa1, ak1, e1) -> 
            if (String.startsWith(av1, "PLI") and aw1 == false and ah1 != "CATCHMENT")
                Some({ plinum               = av1
                    , commonName            = am1
                    , manufacturer          = az1
                    , model                 = ba1
                    , assetType             = be1
                    , installedFromDate     = ay1
                    , processGroupName      = aa1
                    , processName           = ah1
                    , parentSainum          = ak1
                    , installationSainum    = e1
                    })
            else
                None)
            <&> (getColumnIndex("AH") >>= getTrimmedContentAt)      /// ProcessAssetTypeDescription (could be NULL)
            <*> (getColumnIndex("AV") >>= getTrimmedContentAt)      /// PlantEquipReference
            <*> (getColumnIndex("AW") >>= getYesNoAt)               /// InS4_Y
            <*> (getColumnIndex("AM") >>= getTrimmedContentAt)      /// CommonName
            <*> (getColumnIndex("AZ") >>= getTrimmedContentAt)      /// Manufacturer
            <*> (getColumnIndex("BA") >>= getTrimmedContentAt)      /// Model
            <*> (getColumnIndex("BE") >>= getTrimmedContentAt)      /// AssetType
            <*> (getColumnIndex("AY") >>= getOptionalDateAt)        /// InstalledFromDate
            <*> (getColumnIndex("AA") >>= getTrimmedContentAt)      /// ProcessGroupName
            <*> (getColumnIndex("AK") >>= getTrimmedContentAt)      /// ParentReference
            <*> (getColumnIndex("E") >>= getTrimmedContentAt)       /// InstallationReference


    /// Read from Aib xlsx export file...
    pub def readInstallationMappings(src: XlsxSource): Result[#{InstallationMapping | r}, String] & Impure =
        SheetIO/Reader.allNamedRelations(src, evalInstallationMapping())


    def evalInstallationMapping(): NamedRowEvaluator[#{InstallationMapping | r}] =
        use SheetIO/NamedRowEvaluator.{getTrimmedContentNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2) -> #{ InstallationMapping(x1, x2). })
            <&> getTrimmedContentNamed("AI2_InstallationReference")
            <*> getTrimmedContentNamed("S/4 Hana Floc Lvl1_Code")
            
    /// Read from Aib xlsx export file...
    pub def readSiteEastNorth(src: XlsxSource): Result[#{SiteEastNorth | r}, String] & Impure =
        SheetIO/Reader.allNamedRelations(src, evalSiteEastNorth())

    def evalSiteEastNorth(): NamedRowEvaluator[#{SiteEastNorth | r}] =
        use SheetIO/NamedRowEvaluator.{getTrimmedContentNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3) -> #{ SiteEastNorth(x1, x2, x3). })
            <&> getTrimmedContentNamed("Functional Loc.")
            <*> int32AsTextNamed("Easting")
            <*> int32AsTextNamed("Northing")

    /// TODO add an equivalent function to SheetIO...
    def int32AsTextNamed(label: String): NamedRowEvaluator[Int32] =
        use SheetIO/NamedRowEvaluator.{flatMap, getTrimmedContentNamed, liftResult};
        let* s1 = getTrimmedContentNamed(label);
        liftResult(Int32.fromString(s1), _ -> "int32AsTextNamed - not an integer")



    /// Need to partition worklists so the output files are manageable
    /// So we read records rather than relations.
    pub def readAchFlocWorkItems(src: XlsxSource): Result[List[AchFlocWorkItem], String] & Impure =
        SheetIO/Reader.readSomeRows(src, evalAchFlocWorkItem())
            |> Result.map(List.distinctWith((x, y) -> x.instAibRef == y.instAibRef))
            
    /// Must filter that ProcessAssetTypeDescription(AH) is not "CATCHMENT"            
    def evalAchFlocWorkItem(): RowEvaluator[Option[AchFlocWorkItem]] =
        use SheetIO/RowEvaluator.{getColumnIndex, getTrimmedContentAt};
        use SheetIO/RowEvaluator.{<&>, <*>, >>=};
        ((b1, e1, ah1) -> 
            if (String.startsWith(b1, "SAI") and String.startsWith(e1, "SAI") and ah1 != "CATCHMENT")
                Some({siteAibRef = b1, instAibRef = e1})
            else 
                None)
            <&> (getColumnIndex("B") >>= getTrimmedContentAt)       /// Site Reference
            <*> (getColumnIndex("E") >>= getTrimmedContentAt)       /// InstallationReference
            <*> (getColumnIndex("AH") >>= getTrimmedContentAt)      /// ProcessAssetTypeDescription



    pub def readPlantAssetTypes(src: XlsxSource): Result[#{PlantAssetType | r}, String] & Impure =
        use SheetIO/RowEvaluator.{withDefault};
        SheetIO/Reader.allRelations(src, withDefault(evalPlantAssetType(), #{}))
            


    def evalPlantAssetType(): RowEvaluator[#{PlantAssetType | r}] =
        use SheetIO/RowEvaluator.{getColumnIndex, getTrimmedContentAt};
        use SheetIO/RowEvaluator.{<&>, <*>, >>=};
        ((x1, x2) -> #{ PlantAssetType(x1, x2). })
            <&> (getColumnIndex("AR") >>= getTrimmedContentAt)
            <*> (getColumnIndex("AS") >>= getTrimmedContentAt)


    pub def readEquipmentMapping(src: XlsxSource): Result[#{EquipmentMapping | r}, String] & Impure =
        SheetIO/Reader.allNamedRelations(src, evalEquipmentMappingRow())


    def evalEquipmentMappingRow(): NamedRowEvaluator[#{EquipmentMapping | r}] =
        use SheetIO/NamedRowEvaluator.{getTrimmedContentNamed, getInt32Named, optional};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5) -> #{ EquipmentMapping(x1, x2, x3, x4, x5). })
            <&> getTrimmedContentNamed("PlantAssetTypeDescription")
            <*> getTrimmedContentNamed("PlantEquipAssetTypeDescription")
            <*> getTrimmedContentNamed("ObjectType")
            <*> getTrimmedContentNamed("ObjectClass")
            <*> getTrimmedContentNamed("Category")





    pub def readSuperEquipFacts(src: XlsxSource): Result[#{GrandParentParentNames, 
                                                            AssetTypeDescription,
                                                            EquipProperties | r}, String] & Impure =
        let evalMultiFacts =
            SheetIO/RowEvaluator.lift3((x1, x2, x3 ) -> x1 <+> x2 <+> x3, 
                evalGrandParentParentNames(), 
                evalAssetTypeDescription(),
                evalEquipProperties()
            );
        SheetIO/Reader.allRelations(src, evalMultiFacts)




    /// Excel file has duplicate names so use alphabetical index ...
    def evalGrandParentParentNames(): RowEvaluator[#{GrandParentParentNames | r}] =
        use SheetIO/RowEvaluator.{getColumnIndex, getTrimmedContentAt};
        use SheetIO/RowEvaluator.{<&>, <*>, >>=};
        ((ah1, av1, aw1, aa1) -> 
            if (String.startsWith(av1, "PLI") and aw1 == false and ah1 != "CATCHMENT")
                #{ GrandParentParentNames(av1, aa1, ah1). }
            else
                #{})
            <&> (getColumnIndex("AH") >>= getTrimmedContentAt)      /// ProcessAssetTypeDescription (could be "NULL")
            <*> (getColumnIndex("AV") >>= getTrimmedContentAt)      /// PlantEquipReference
            <*> (getColumnIndex("AW") >>= getYesNoAt)               /// InS4_Y
            <*> (getColumnIndex("AA") >>= getTrimmedContentAt)      /// ProcessGroupAssetTypeDescription (could be "NULL")
            

    def evalAssetTypeDescription(): RowEvaluator[#{AssetTypeDescription | r}] =
        use SheetIO/RowEvaluator.{getColumnIndex, getTrimmedContentAt};
        use SheetIO/RowEvaluator.{<&>, <*>, >>=};
        ((ah1, av1, aw1, as1, be1) -> 
            if (String.startsWith(av1, "PLI") and aw1 == false and ah1 != "CATCHMENT")
                #{ AssetTypeDescription(av1, as1, be1). }
            else
                #{})
            <&> (getColumnIndex("AH") >>= getTrimmedContentAt)      /// ProcessAssetTypeDescription (could be "NULL")
            <*> (getColumnIndex("AV") >>= getTrimmedContentAt)      /// PlantEquipReference
            <*> (getColumnIndex("AW") >>= getYesNoAt)               /// InS4_Y
            <*> (getColumnIndex("AS") >>= getTrimmedContentAt)      /// PlantAssetTypeDescription (could be "NULL")
            <*> (getColumnIndex("BE") >>= getTrimmedContentAt)      /// PlantEquipAssetTypeDescription (could be "NULL")



    def evalEquipProperties(): RowEvaluator[#{EquipProperties | r}] =
        use SheetIO/RowEvaluator.{getColumnIndex, getTrimmedContentAt};
        use SheetIO/RowEvaluator.{<&>, <*>, >>=};
        ((ah1, av1, aw1, az1, ba1, ay1) -> 
            if (String.startsWith(av1, "PLI") and aw1 == false and ah1 != "CATCHMENT")
                #{ EquipProperties(av1, az1, ba1, ay1). }
            else
                #{})
            <&> (getColumnIndex("AH") >>= getTrimmedContentAt)      /// ProcessAssetTypeDescription (could be "NULL")
            <*> (getColumnIndex("AV") >>= getTrimmedContentAt)      /// PlantEquipReference
            <*> (getColumnIndex("AW") >>= getYesNoAt)               /// InS4_Y
            <*> (getColumnIndex("AZ") >>= getTrimmedContentAt)      /// PlantEquipManufacturer (could be "NULL")
            <*> (getColumnIndex("BA") >>= getTrimmedContentAt)      /// PlantEquipModel (could be "NULL")
            <*> (getColumnIndex("AY") >>= getOptionalDateAt)        /// PlantEquipInstalledFromDate



    /// Specific export file...
    pub def readPandITags(src: XlsxSource): Result[#{PandITag | r}, String] & Impure =
        SheetIO/Reader.allNamedRelations(src, evalPandITag())

    /// This is from a separte sheet...
    def evalPandITag(): NamedRowEvaluator[#{PandITag | r}] =
        use SheetIO/NamedRowEvaluator.{getTrimmedContentNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2) -> 
            if (not String.isEmpty(x1))
                #{ PandITag(x1, x2). }
            else
                #{})
            <&> getTrimmedContentNamed("Reference")
            <*> getTrimmedContentNamed("P AND I Tag No")
            

    /// Might need improvement...
    def getOptionalDateAt(ix: Int32): RowEvaluator[Option[Time.LocalDate]] =
        use SheetIO/RowEvaluator.{optional, getLocalDateAt};
        optional(getLocalDateAt(ix))


    /// Has duplicate names so use index...
    def getYesNoAt(ix: Int32): RowEvaluator[Bool] =
        use SheetIO/RowEvaluator.{getTrimmedContentAt};
        use SheetIO/RowEvaluator.{<&>};
        (x1 -> x1 == "Y" or x1 == "y")  <&> getTrimmedContentAt(ix)

}

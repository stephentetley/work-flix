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
    
    use AssetScripts/NonOp/Relations.{AchFlocWorkItem, EquiWorkItem, 
        InstallationMapping, SiteEastNorth, 
        EquipmentMapping, PlantAssetType, GrandParentParentNames, PandITag, 
        AssetTypeDescription, EquipProperties, IH08Mapping};




    /// Read from Aib xlsx export file...
    pub def readPlantEquipWorkItems(src: XlsxSource): Result[List[EquiWorkItem], String] & Impure =
        SheetIO/Reader.readSomeRows(src, evalPlantEquipWorkItem(shortenName))
            |> Result.map(List.distinctWith((x, y) -> x.plinum == y.plinum))


    def shortenName(s: String): String = String.takeLeft(40, s)
    def childName(s: String): String = 
        if (s `String.contains` "/") {
            let s1 = snd(String.breakOnRight("/", s));
            AssetLib/Base/Utils.properCaseName(s1)
        } else s



    /// Excel file has duplicate names so use alphabetical index ...
    /// Must filter that ProcessAssetTypeDescription(AH) is not "CATCHMENT"  
    def evalPlantEquipWorkItem(makeDesc: String -> String): RowEvaluator[Option[EquiWorkItem]] =
        use SheetIO/RowEvaluator.{getColumnIndex, getTrimmedContentAt};
        use SheetIO/RowEvaluator.{<&>, <*>, >>=};
        ((ah1, av1, aw1, am1, az1, ba1, as1, be1, ay1, aa1, ak1, e1, m1) -> 
            if (String.startsWith(av1, "PLI") and aw1 == false and ah1 != "CATCHMENT")
                Some({ plinum               = av1
                    , commonName            = am1
                    , manufacturer          = az1
                    , model                 = ba1
                    , plantAssetType        = as1
                    , plantEquipAssetType   = be1
                    , installedFromDate     = ay1
                    , processGroupName      = aa1
                    , processName           = ah1
                    , parentSainum          = ak1
                    , installationSainum    = e1
                    , subinstallationSainum = m1
                    , description           = makeDesc(AssetScripts/NonOp/Utils.getDescription(aa1, ah1, am1))
                    })
            else
                None)
            <&> (getColumnIndex("AH") >>= getTrimmedContentAt)      /// ProcessAssetTypeDescription (could be NULL)
            <*> (getColumnIndex("AV") >>= getTrimmedContentAt)      /// PlantEquipReference
            <*> (getColumnIndex("AW") >>= getYesNoAt)               /// InS4_Y
            <*> (getColumnIndex("AM") >>= getTrimmedContentAt)      /// CommonName
            <*> (getColumnIndex("AZ") >>= getTrimmedContentAt)      /// Manufacturer
            <*> (getColumnIndex("BA") >>= getTrimmedContentAt)      /// Model
            <*> (getColumnIndex("AS") >>= getTrimmedContentAt)      /// PlantAssetType
            <*> (getColumnIndex("BE") >>= getTrimmedContentAt)      /// PlantEquipAssetType
            <*> (getColumnIndex("AY") >>= getOptionalDateAt)        /// InstalledFromDate
            <*> (getColumnIndex("AA") >>= getTrimmedContentAt)      /// ProcessGroupName
            <*> (getColumnIndex("AK") >>= getTrimmedContentAt)      /// ParentReference
            <*> (getColumnIndex("E") >>= getTrimmedContentAt)       /// InstallationReference
            <*> (getColumnIndex("M") >>= getTrimmedContentAt)       /// SubInstallationReference


    pub def readPlantItemNoParentWorkItems(src: XlsxSource): Result[List[EquiWorkItem], String] & Impure =
        SheetIO/Reader.readSomeRows(src, evalPlantItem(shortenName, s -> s == "NULL"))
            |> Result.map(List.distinctWith((x, y) -> x.plinum == y.plinum))
            |> Result.map(List.filter(validEqui))

    pub def readPlantItemChildren(src: XlsxSource): Result[List[EquiWorkItem], String] & Impure =
        SheetIO/Reader.readSomeRows(src, evalPlantItem(childName, s -> s `String.startsWith` "PLI"))
            |> Result.map(List.distinctWith((x, y) -> x.plinum == y.plinum))
            |> Result.map(List.filter(validEqui))


    def validEqui(x: EquiWorkItem): Bool = 
        let bads = "EQUIPMENT: PUMP LIFTING CHAIN" :: "EQUIPMENT: MISC MECHANICAL PLANT(MYAA)"  
                    :: "EQUIPMENT: MISCELLANEOUS ELECTRICAL PLANT" :: "EQUIPMENT: LAND AND GROUNDS" :: Nil;
        not List.memberOf(x.plantEquipAssetType, bads)



    
    /// Returns both PlantItemEquip_Super (not a child) and PlantItemEquip_Child (is a child of PlantEqui)
    def evalPlantItem(makeDesc: String -> String, test: String -> Bool): RowEvaluator[Option[EquiWorkItem]] =
        use SheetIO/RowEvaluator.{getColumnIndex, getTrimmedContentAt};
        use SheetIO/RowEvaluator.{<&>, <*>, >>=};
        ((ah1, cm1, cn1, cd1, cq1, cr1, cj1, cv1, cp1, aa1, cb1, e1, m1, av1) -> 
            if (String.startsWith(cm1, "PLI") and cn1 == false and ah1 != "CATCHMENT" and test(av1)
                    and cv1 != "EQUIPMENT: BUILDINGS + STRUCTURES" 
                    and cv1 != "EQUIPMENT: MISCELLANEOUS ELECTRICAL PLANT"
                    and cv1 != "EQUIPMENT: LAND AND GROUNDS")
                Some({ plinum               = cm1
                    , commonName            = cd1
                    , manufacturer          = cq1
                    , model                 = cr1
                    , plantAssetType        = cj1
                    , plantEquipAssetType   = cv1
                    , installedFromDate     = cp1
                    , processGroupName      = aa1
                    , processName           = ah1
                    , parentSainum          = cb1
                    , installationSainum    = e1
                    , subinstallationSainum = m1
                    , description           = makeDesc(AssetScripts/NonOp/Utils.getDescription(aa1, ah1, cd1))
                    })
            else
                None)
            <&> (getColumnIndex("AH") >>= getTrimmedContentAt)      /// ProcessAssetTypeDescription (could be NULL)
            <*> (getColumnIndex("CM") >>= getTrimmedContentAt)      /// PlantEquipReference
            <*> (getColumnIndex("CN") >>= getYesNoAt)               /// InS4_Y
            <*> (getColumnIndex("CD") >>= getTrimmedContentAt)      /// CommonName
            <*> (getColumnIndex("CQ") >>= getTrimmedContentAt)      /// Manufacturer
            <*> (getColumnIndex("CR") >>= getTrimmedContentAt)      /// Model
            <*> (getColumnIndex("CJ") >>= getTrimmedContentAt)      /// PlantAssetType
            <*> (getColumnIndex("CV") >>= getTrimmedContentAt)      /// PlantEquipAssetType
            <*> (getColumnIndex("CP") >>= getOptionalDateAt)        /// InstalledFromDate
            <*> (getColumnIndex("AA") >>= getTrimmedContentAt)      /// ProcessGroupName
            <*> (getColumnIndex("CB") >>= getTrimmedContentAt)      /// ParentReference
            <*> (getColumnIndex("E") >>= getTrimmedContentAt)       /// InstallationReference
            <*> (getColumnIndex("M") >>= getTrimmedContentAt)       /// SubInstallationReference
            <*> (getColumnIndex("AV") >>= getTrimmedContentAt)      /// SubInstallationReference


    /// Read from "InstllationsMapping_.xlsx" ...
    pub def readInstallationMapping(src: XlsxSource): Result[#{InstallationMapping | r}, String] & Impure =
        SheetIO/Reader.allNamedRelations(src, evalInstallationMapping())


    def evalInstallationMapping(): NamedRowEvaluator[#{InstallationMapping | r}] =
        use SheetIO/NamedRowEvaluator.{getTrimmedContentNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2) -> #{ InstallationMapping(x1, x2). })
            <&> getTrimmedContentNamed("AI2_InstallationReference")
            <*> getTrimmedContentNamed("S/4 Hana Floc Lvl1_Code")
            


    /// Read from "sitelist-ih06-east_north.xlsx" ...
    pub def readSiteEastNorth(src: XlsxSource): Result[#{SiteEastNorth | r}, String] & Impure =
        SheetIO/Reader.allNamedRelations(src, evalSiteEastNorth())

    def evalSiteEastNorth(): NamedRowEvaluator[#{SiteEastNorth | r}] =
        use SheetIO/NamedRowEvaluator.{getTrimmedContentNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3) -> #{ SiteEastNorth(x1, x2, x3). })
            <&> getTrimmedContentNamed("Functional Loc.")
            <*> int32AsTextNamed("Easting")
            <*> int32AsTextNamed("Northing")

    /// Read from "equipment-mapping2.xlsx" ...
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
            RelLib/Relation.when(String.startsWith(av1, "PLI") and aw1 == false and ah1 != "CATCHMENT", 
                            #{ GrandParentParentNames(av1, aa1, ah1). }))
            <&> (getColumnIndex("AH") >>= getTrimmedContentAt)      /// ProcessAssetTypeDescription (could be "NULL")
            <*> (getColumnIndex("AV") >>= getTrimmedContentAt)      /// PlantEquipReference
            <*> (getColumnIndex("AW") >>= getYesNoAt)               /// InS4_Y
            <*> (getColumnIndex("AA") >>= getTrimmedContentAt)      /// ProcessGroupAssetTypeDescription (could be "NULL")
            

    def evalAssetTypeDescription(): RowEvaluator[#{AssetTypeDescription | r}] =
        use SheetIO/RowEvaluator.{getColumnIndex, getTrimmedContentAt};
        use SheetIO/RowEvaluator.{<&>, <*>, >>=};
        ((ah1, av1, aw1, as1, be1) -> 
            RelLib/Relation.when(String.startsWith(av1, "PLI") and aw1 == false and ah1 != "CATCHMENT", 
                            #{ AssetTypeDescription(av1, as1, be1). }))
            <&> (getColumnIndex("AH") >>= getTrimmedContentAt)      /// ProcessAssetTypeDescription (could be "NULL")
            <*> (getColumnIndex("AV") >>= getTrimmedContentAt)      /// PlantEquipReference
            <*> (getColumnIndex("AW") >>= getYesNoAt)               /// InS4_Y
            <*> (getColumnIndex("AS") >>= getTrimmedContentAt)      /// PlantAssetTypeDescription (could be "NULL")
            <*> (getColumnIndex("BE") >>= getTrimmedContentAt)      /// PlantEquipAssetTypeDescription (could be "NULL")



    def evalEquipProperties(): RowEvaluator[#{EquipProperties | r}] =
        use SheetIO/RowEvaluator.{getColumnIndex, getTrimmedContentAt};
        use SheetIO/RowEvaluator.{<&>, <*>, >>=};
        ((ah1, av1, aw1, az1, ba1, ay1) -> 
            RelLib/Relation.when(String.startsWith(av1, "PLI") and aw1 == false and ah1 != "CATCHMENT",
                            #{ EquipProperties(av1, az1, ba1, ay1). }))
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
        ((x1, x2) -> RelLib/Relation.whenNot(String.isEmpty(x1), #{ PandITag(x1, x2). }))
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
        (x1 -> x1 == "Y" or x1 == "y") <&> getTrimmedContentAt(ix)

    /// IH08 export file...
    pub def readIH08Mappings(src: XlsxSource): Result[#{IH08Mapping | r}, String] & Impure =
        SheetIO/Reader.allNamedRelations(src, evalIH08Mapping())

    /// This is from a separte sheet...
    def evalIH08Mapping(): NamedRowEvaluator[#{IH08Mapping | r}] =
        use SheetIO/NamedRowEvaluator.{getTrimmedContentNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2) -> RelLib/Relation.when(String.startsWith(x1, "PLI"), #{ IH08Mapping(x1, x2). }))
            <&> getTrimmedContentNamed("AI2 AIB Reference")
            <*> getTrimmedContentNamed("Equipment")

}

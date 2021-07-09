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
    
    use AssetScripts/NonOp/Relations.{SecondOrderFlocWorkItem, SiteFloc, SiteEastNorth, 
        EquipmentMapping, PlantAssetType, GrandParentParentNames};

    /// Read from Aib xlsx export file...
    pub def readSiteFlocs(src: XlsxSource): Result[#{SiteFloc | r}, String] & Impure =
        SheetIO/Reader.allNamedRelations(src, evalSiteFloc())


    def evalSiteFloc(): NamedRowEvaluator[#{SiteFloc | r}] =
        use SheetIO/NamedRowEvaluator.{getTrimmedContentNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2) -> #{ SiteFloc(x1, x2). })
            <&> getTrimmedContentNamed("AI2 AIB Reference")
            <*> getTrimmedContentNamed("Functional Loc.")
            
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

    type alias SecondOrderFlocWorkItem1 = 
        { siteAibRef: String
        }
    
    pub def readSecondOrderFlocWorkItem1s(src: XlsxSource): Result[List[SecondOrderFlocWorkItem1], String] & Impure =
        SheetIO/Reader.readSomeRows(src, evalSecondOrderFlocWorkItem1())
            |> Result.map(List.distinctWith((x, y) -> x.siteAibRef == y.siteAibRef))
            
    /// Must filter that ProcessAssetTypeDescription(AH) is not "CATCHMENT"            
    def evalSecondOrderFlocWorkItem1(): RowEvaluator[Option[SecondOrderFlocWorkItem1]] =
        use SheetIO/RowEvaluator.{getColumnIndex, getTrimmedContentAt};
        use SheetIO/RowEvaluator.{<&>, <*>, >>=};
        ((x1, x2) -> 
            if (String.startsWith(x1, "SAI") and x2 != "CATCHMENT")
                Some({siteAibRef = x1})
            else 
                None)
            <&> (getColumnIndex("B") >>= getTrimmedContentAt)       /// Site Reference
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



    type alias SuperEquipmentWorkItem1 = 
        { av_EquiId: String
        , am_PlantCommonName: String
        , b_SiteReference: String
        }

    /// Read from Aib xlsx export file...
    pub def readSuperEquipmentWorkItem1s(src: XlsxSource): Result[List[SuperEquipmentWorkItem1], String] & Impure =
        SheetIO/Reader.readSomeRows(src, evalSuperEquipmentWorkItem1())
            |> Result.map(List.distinctWith((x, y) -> x.av_EquiId == y.av_EquiId))


    /// Excel file has duplicate names so use alphabetical index ...
    /// Must filter that ProcessAssetTypeDescription(AH) is not "CATCHMENT"  
    def evalSuperEquipmentWorkItem1(): RowEvaluator[Option[SuperEquipmentWorkItem1]] =
        use SheetIO/RowEvaluator.{getColumnIndex, getTrimmedContentAt};
        use SheetIO/RowEvaluator.{<&>, <*>, >>=};
        ((ah1, av1, aw1, b1, am1) -> 
            if (String.startsWith(av1, "PLI") and aw1 == false and ah1 != "CATCHMENT")
                Some({ av_EquiId = av1
                    , am_PlantCommonName = am1
                    , b_SiteReference = b1
                    })
            else
                None)
            <&> (getColumnIndex("AH") >>= getTrimmedContentAt)      /// ProcessAssetTypeDescription (could be NULL)
            <*> (getColumnIndex("AV") >>= getTrimmedContentAt)      /// PlantEquipReference
            <*> (getColumnIndex("AW") >>= getYesNoAt)               /// InS4_Y
            <*> (getColumnIndex("B") >>= getTrimmedContentAt)      /// SiteReference
            <*> (getColumnIndex("AM") >>= getTrimmedContentAt)      /// CommonName


    pub def readSuperEquipFacts(src: XlsxSource): Result[#{GrandParentParentNames | r}, String] & Impure =
        SheetIO/Reader.allRelations(src, evalGrandParentParentNames())


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
            <*> (getColumnIndex("AA") >>= getTrimmedContentAt)      /// ProcessAssetTypeDescription (could be "NULL")
            



    /// Has duplicate names so use index...
    def getYesNoAt(ix: Int32): RowEvaluator[Bool] =
        use SheetIO/RowEvaluator.{getTrimmedContentAt};
        use SheetIO/RowEvaluator.{<&>};
        (x1 -> x1 == "Y" or x1 == "y")  <&> getTrimmedContentAt(ix)

}

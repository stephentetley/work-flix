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
    
    use AssetScripts/NonOp/Relations.{SecondOrderFlocWorkItem, SiteFloc, SiteEastNorth, EquipmentMapping, PlantAssetType};

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



    /// TODO - need to partition worklists so the output files are manageable...

    type alias SecondOrderFlocWorkItem1 = 
        { siteAibRef: String
        }
    
    pub def readSecondOrderFlocWorkItems(src: XlsxSource): Result[List[SecondOrderFlocWorkItem1], String] & Impure =
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


    /// /// Read from Aib xlsx export file...
    /// def readWorkList(sheetName: String, path: System.FilePath): Result[List[PlantEquip], String] & Impure =
    ///     SheetIO/Reader.readSomeRows(sheetName, path, evalPlantEquip())
    ///         |> Result.map(List.distinctWith((x, y) -> x.plantEquipReference == y.plantEquipReference))


    /// /// Excel file has duplicate names so use alphabetical index ...
    /// /// Because PlantEquip is a prefix (there is other data after the 'useful' data that makes the row unique), reading the file 
    /// /// as just PlantEquip will induce duplicates.
    /// def evalPlantEquip(): RowEvaluator[#{PlantEquip | r}] =
    ///     use SheetIO/RowEvaluator.{getColumnIndex, getTrimmedContentAt};
    ///     use SheetIO/RowEvaluator.{<&>, <*>, >>=};
    ///     ((x1, x2, x3, x4, x5, x6, x7) -> 
    ///         if (x1 `String.startsWith` "PLI" and x2 == false) {
    ///             let shortName = getShortName(x5, x6, x4);
    ///             #{ PlantEquip(x1, x3, x4, shortName, x7). }
    ///         }
    ///         else #{})
    ///         <&> (getColumnIndex("AV") >>= getTrimmedContentAt)      /// PlantEquipReference
    ///         <*> (getColumnIndex("AW") >>= getYesNoAt)
    ///         <*> (getColumnIndex("B") >>= getTrimmedContentAt)       /// SiteReference
    ///         <*> (getColumnIndex("AM") >>= getTrimmedContentAt)      /// CommonName
    ///         <*> (getColumnIndex("AA") >>= getTrimmedContentAt)      /// ProcessGroupAssetTypeDescription (could be NULL)
    ///         <*> (getColumnIndex("AH") >>= getTrimmedContentAt)      /// ProcessGroupAssetTypeDescription (could be NULL)
    ///         <*> (getColumnIndex("AK") >>= getTrimmedContentAt)      /// PlantReference

    /// def getShortName(pgdesc: String, pdesc: String, commonName: String): String = 
    ///     match (pgdesc, pdesc) {
    ///         case ("NULL", "NULL") => commonName
    ///         case ("NULL", _) => snd(String.breakOnRight("${pdesc}/", commonName))
    ///         case (_, "NULL") => snd(String.breakOnRight("${pgdesc}/", commonName))
    ///         case (_, _) => snd(String.breakOnRight("${pgdesc}/${pdesc}/", commonName))
    ///     }


    /// /// Has duplicate names so use index...
    /// def getYesNoAt(ix: Int32): RowEvaluator[Bool] =
    ///     use SheetIO/RowEvaluator.{getTrimmedContentAt};
    ///     use SheetIO/RowEvaluator.{<&>};
    ///     (x1 -> x1 == "Y" or x1 == "y")  <&> getTrimmedContentAt(ix)

}

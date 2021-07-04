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
    
    use AssetScripts/NonOp/Relations.{SecondOrderFlocWorkItem, SiteFloc};

    /// Read from Aib xlsx export file...
    pub def readSiteFlocs(sheetName: String, path: System.FilePath): Result[#{SiteFloc | r}, String] & Impure =
        SheetIO/Reader.foldAllNamedRows(sheetName, path, (ac, a) -> ac <+> a, #{}, evalSiteFloc())


    def evalSiteFloc(): NamedRowEvaluator[#{SiteFloc | r}] =
        use SheetIO/NamedRowEvaluator.{getTrimmedContentNamed, getInt32Named, optional};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2) -> #{ SiteFloc(x1, x2). })
            <&> getTrimmedContentNamed("AI2 AIB Reference")
            <*> getTrimmedContentNamed("Functional Loc.")
            

    pub def readSecondOrderFlocWorkItems(sheetName: String, path: System.FilePath): Result[#{SecondOrderFlocWorkItem | r}, String] & Impure =
        use SheetIO/RowEvaluator.{getColumnIndex, getTrimmedContentAt};
        use SheetIO/RowEvaluator.{>>=};
        let eval1 = getColumnIndex("B") >>= getTrimmedContentAt;
        SheetIO/Reader.readAllRows(sheetName, path, eval1)
            |> Result.map(List.distinct)
            |> Result.map(List.foldLeft((ac, x) -> ac <+> #{ SecondOrderFlocWorkItem(x). }, #{}))



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

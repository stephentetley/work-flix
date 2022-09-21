/*
 * Copyright 2022 Stephen Tetley
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

namespace PDTKit/BaseReports/Summary {

    use Basis/System.FilePath;
    use SheetIO.RowSetter;

    use PDTKit/PdtL/Datatypes.{PdtFile, DataSheetMultiAttribute};

    /// FileName / DataSheetName / Site / Function / ProcessGroup / Process / System / Floc / AssetName / AssetType / AssetStatus


    pub def processDirectory(path: FilePath): Result[Unit, String] \ IO = 
        use Result.flatMap;
        let* paths = allXlsxFiles(path);
        let* rows = Result.traverse(processFile, paths) |> Result.map(List.flatten);
        List.foreach(x -> println(print1(x)), rows);
        Ok()


    pub type alias SummaryRow = 
        { fileName :: String
        , dataSheetName :: String
        , site :: String
        , function :: String
        , processGroup :: String
        , process :: String
        , system :: String
        , floc :: String
        , index :: Int32
        , tag :: String
        , assetName :: String
        , assetType :: String
        , assetStatus :: String
        }

    def print1(row: SummaryRow): String = 
        String.intercalate(",", 
            row.fileName ::
            row.dataSheetName :: 
            row.site :: 
            row.function ::
            row.processGroup ::
            row.process :: 
            row.system ::
            row.floc :: 
            ToString.toString(row.index) ::
            row.tag ::
            row.assetName :: 
            row.assetType :: 
            row.assetStatus :: 
            Nil)


    def processFile(path: FilePath): Result[List[SummaryRow], String] \ IO =
        use Result.flatMap;
        let* src = PDTKit/PdtL/ReadPdt.readPdtFile(path);
        let* ans = summarizeFile(src);
        if (List.isEmpty(ans)) println("No results from: ${path}") else ();
        Ok(ans)

    def allXlsxFiles(path: FilePath): Result[List[FilePath], String] \ IO =
        use Result.flatMap;
        let* files = ToString.toString(path) |> File.list;
        let* paths = Result.traverse(Basis/System/FilePath.filePath, files);
        Ok(List.filter(Basis/System/FilePath.testExtension( s -> s == "xlsx"), paths))



    pub def summarizeFile(pdtL: PdtFile): Result[List[SummaryRow], String] = 
        use Result.flatMap;
        let* codes = getFlocCodes(pdtL.leadSheet.attributes);
        let xs     = getItems(pdtL.dataSheet.multiAttributes) 
                        |> List.map(summarize1(fileName = pdtL.fileName, sheetName = pdtL.dataSheet.sheetName, codes));
        Ok(xs)
        
    def getFlocCodes(leadAttributes: List[{name :: String, code :: String | rx}]): Result[(String, String, String, String, String), String] = 
        let db = leadAttributes |> List.map(x -> (x.name, x.code)) |> xs -> inject xs into Attrib2;
        let pr = #{
            Floc(site, func, procg, proc, sys) :- 
                Attrib2("Site", site),
                Attrib2("Function", func),
                Attrib2("Process Group", procg),
                Attrib2("Process", proc),
                Attrib2("System", sys).
        };
        match query db, pr select (v, w, x, y, z) from Floc(v, w, x, y, z) {
            case Nil       => Ok(("", "", "", "", ""))
            case x1 :: Nil => Ok(x1)
            case _         => Err("Invalid - multiple floc codes")
        }

    def getItems(multiAttributes: List[DataSheetMultiAttribute]): List[(Int32, String, String, String, String)] = 
        let db = multiAttributes |> List.flatMap(transposeDataSheetMultiAttribute) |> xs -> inject xs into Attrib3;
        let pr = #{

            /// "Tag reference" not always present...
            HasTag(column) :- Attrib3(column, "Tag reference", _).

            Item(column, name, atyp, status, tag) :- 
                HasTag(column),
                Attrib3(column, "Asset Name", name),
                Attrib3(column, "Asset Type", atyp),
                Attrib3(column, "Asset Status", status),
                Attrib3(column, "Tag reference", tag),
                if not String.isEmpty(name) or not String.isEmpty(atyp).


            Item(column, name, atyp, status, "") :-                 
                Attrib3(column, "Asset Name", name),
                Attrib3(column, "Asset Type", atyp),
                Attrib3(column, "Asset Status", status),
                not HasTag(column),
                if not String.isEmpty(name) or not String.isEmpty(atyp).

        };
        query db, pr select (v, w, x, y, z) from Item(v, w, x, y, z)

    def transposeDataSheetMultiAttribute(x: DataSheetMultiAttribute): List[(Int32, String, String)] = 
        List.mapWithIndex((s, ix) -> (ix+1, x.name, s), x.values)


    def summarize1(fileName: {fileName :: String}, 
                    sheetName: {sheetName :: String}, 
                    codes: (String, String, String, String, String),
                    item: (Int32, String, String, String, String)): SummaryRow = 
        let (site, function, processGroup, process, system) = codes;
        let (index, assetName, assetType, assetStatus, tag) = item;
        { fileName = fileName.fileName
        , dataSheetName = sheetName.sheetName
        , site = site
        , function = function
        , processGroup = processGroup
        , process = process
        , system = system
        , floc = String.intercalate("-", site :: function :: processGroup :: process :: system :: Nil)
        , index = index
        , tag = tag
        , assetName = assetName
        , assetType = assetType
        , assetStatus = assetStatus
        }
    
    // Change,Reference,Asset Name,OldParentName,NewParentName
    pub def writeRow(row: SummaryRow): RowSetter[r, Unit] \ Write(r) = 
        use Applicative.{*>};
        use SheetIO/RowSetter.{putStringAt!, putInt32At!};
        putStringAt!(0, row.fileName)       *>
        putStringAt!(1, row.dataSheetName)  *>
        putStringAt!(2, row.site)           *>
        putStringAt!(3, row.function)       *>
        putStringAt!(4, row.processGroup)   *>
        putStringAt!(5, row.process)        *>
        putStringAt!(6, row.system)         *>
        putStringAt!(7, row.floc)           *>
        putInt32At!( 8, row.index)          *>
        putStringAt!(9, row.assetName)      *>
        putStringAt!(10, row.assetType)      *>
        putStringAt!(11, row.assetStatus)


}

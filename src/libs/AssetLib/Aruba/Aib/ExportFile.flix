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



namespace AssetLib/Aruba/Aib/ExportFile {

    use Text/Regex.MatchEvaluator;

    use SheetIO/Reader.{XlsxSource};
    use SheetIO.NamedRowEvaluator;

    use AssetLib/Aruba/Base.{Floc, Equi, SubFloc, EquiLocation, SubEqui, FlocLevel};
    use AssetLib/Aruba/Aib/HierarchyNames.{AibParentName};

    type alias ExportRow = 
        { reference :: String
        , commonName :: String
        , installedFrom :: Time.LocalDate
        , hkey :: String
        , assetStatus :: String
        , gridref :: String
        }



    pub def readExportRelations(src: XlsxSource): Result[#{Equipment, AibParentName}, String] & Impure =         
        use Result.{flatMap};
        let* rows = SheetIO/Reader.readAllNamedRows(src, evalExportRow());
        buildExportFileRelations(rows)

    def evalExportRow(): NamedRowEvaluator[ExportRow] = 
        use SheetIO/NamedRowEvaluator.{getTrimmedContentNamed, getLocalDateNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5, x6) -> 
            { reference         = x1
            , commonName        = x2
            , installedFrom     = x3
            , hkey              = x4
            , assetStatus       = x5
            , gridref           = x6
            })
            <&> getTrimmedContentNamed("Reference")
            <*> getTrimmedContentNamed("Common Name")
            <*> getLocalDateNamed("Installed From")
            <*> getTrimmedContentNamed("Hierarchy Key")
            <*> getTrimmedContentNamed("AssetStatus")
            <*> getTrimmedContentNamed("Loc.Ref.")



    def buildExportFileRelations(rows: List[ExportRow]): Result[#{Equipment, AibParentName}, String] & Impure = 
        use Result.{flatMap};
        let parents = List.map(x1 -> {reference = x1.reference, commonName = x1.commonName}, rows) 
                        |> AssetLib/Aruba/Aib/HierarchyNames.getParentNames;
        let* equi = getEquipment(rows);
        Ok(equi <+> parents)

    pub def toBase(input: #{Equipment, AibParentName}): #{Equi |r} = 
        let rules = #{ 
            Equi(aibref, equiname) :- 
                Equipment(aibref, _, _), 
                AibParentName(aibref, equiname).
        };
        let input1 = input as #{Equipment, AibParentName, Equi};
        solve (input1 <+> rules) project Equi




    /// TODO - generate Base relations...
    pub rel Equipment(plinum: String, equiType: String, flocName: String)

    pub rel CommonName(refnum: String, name: String)

    pub rel InstalledDate(refnum: String, installDate: Time.LocalDate)

    pub rel FlocType(sainum: String, floctype: String)

    /// Note this can produce "PIPEWORK AND FITTINGS" and "MEDIA" which are not "true" equipment.
    def getEquipment(rows: List[ExportRow]): Result[#{Equipment |r}, String] & Impure = 
        use Result.flatMap;
        use RelLib/Relation.{optional};
        let* patt = Text/Regex/Pattern.compile("^(?<flocName>.+)/EQUIPMENT: (?<equiType>.+)$");
        RelLib/Relation.foldMapResult(x1 -> Text/Regex.evalMatchesOption(patt, evalEquipment(x1.reference), x1.commonName) |> Result.map(optional), rows)


    /// This should be pure?
    def evalEquipment(sainum: String): MatchEvaluator[#{Equipment |r}] & Impure = 
        use Text/Regex/MatchEvaluator.{getCaptureNamed, lift2};
        let eval1 = lift2((s1, s2) -> #{Equipment(sainum, String.trim(s1), s2). }, getCaptureNamed("equiType"), getCaptureNamed("flocName"));
        eval1



    pub def getCommonName(rows: List[ExportRow]): #{CommonName |r}  = 
        RelLib/Relation.foldMap(x1 -> #{ CommonName(x1.reference, x1.commonName). }, rows)

    pub def getFlocType(rows: List[ExportRow]): #{FlocType |r}  = 
        RelLib/Relation.foldMap(x1 -> #{ FlocType(x1.reference, flocType(x1.hkey)). }, rows)

    pub def flocType(hkey: String): String = match String.length(hkey) {
        case 1 => "Business_Unit"
        case 4 => "System"
        case 8 => "Function"
        case 13 => "Installation"
        case 20 => "Process_Group"
        case 24 => "Process"
        case 31 => "Assembly"
        case 36 => "Plant_Item"
        case _ => "Unknown"
    }


}

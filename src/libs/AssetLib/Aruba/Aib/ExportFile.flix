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

    use AssetLib/Aruba/Base.{Floc, Equi, SubFloc, EquiLocation, SubEqui, FlocLevel, EquiType};
    use AssetLib/Aruba/Aib/HierarchyNames.{AibParentName};

    pub type alias ExportRow = 
        { reference :: String
        , commonName :: String
        , hkey :: String
        , assetStatus :: String
        , gridref :: String
        }



    pub def readExportRelations(src: XlsxSource): Result[#{AibEquipment, AibCommonName, AibParentName, AibHKey}, String] & Impure =         
        use Result.{flatMap};
        let* rows = SheetIO/Reader.readAllNamedRows(src, evalExportRow());
        buildExportFileRelations(rows)

    def evalExportRow(): NamedRowEvaluator[ExportRow] = 
        use SheetIO/NamedRowEvaluator.{getTrimmedContentNamed, getLocalDateNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5) -> 
            { reference         = x1
            , commonName        = x2
            , hkey              = x3
            , assetStatus       = x4
            , gridref           = x5
            })
            <&> getTrimmedContentNamed("Reference")
            <*> getTrimmedContentNamed("Common Name")
            <*> getTrimmedContentNamed("Hierarchy Key")
            <*> getTrimmedContentNamed("AssetStatus")
            <*> getTrimmedContentNamed("Loc.Ref.")



    def buildExportFileRelations(rows: List[ExportRow]): Result[#{AibEquipment, AibCommonName, AibParentName, AibHKey | r}, String] & Impure = 
        use Result.{flatMap};
        let* equi           = getEquipment(rows);
        let commonNames     = getCommonNames(rows);
        let parents         = List.map(x1 -> {reference = x1.reference, commonName = x1.commonName}, rows) 
                                |> AssetLib/Aruba/Aib/HierarchyNames.getParentNames;
        let hkeys           = getAibHKeys(rows);                                
        Ok(equi <+> commonNames <+> parents <+> hkeys)

    /// No SubEqui - this is not a represented it Aib.
    pub def toBase(input: #{AibEquipment, AibCommonName, AibParentName, AibHKey | r}): #{Floc, Equi, EquiLocation, SubFloc, FlocLevel, EquiType | r1} = 
        let rules = #{ 
            Equi(aibref, equiname) :- 
                AibEquipment(aibref, _, _), 
                AibParentName(aibref, equiname).

            Floc(aibref, commonName, nameAfterNeedle({substr = parentName}, commonName)) :- 
                AibCommonName(aibref, commonName),
                AibParentName(aibref, parentName),
                if not String.contains(substr = "EQUIPMENT: ", commonName).

            EquiLocation(equiId, floc) :- 
                AibEquipment(equiId, _, floc).
            
            SubFloc(parent, child) :- 
                AibHKey(child, _, parentHKey), 
                AibHKey(parent, parentHKey, _).
            
            FlocLevel(aibref, flocLevel(hkey)) :- 
                AibHKey(aibref, hkey, _), 
                if flocLevel(hkey) > 0.

            EquiType(aibref, equitype) :- 
                AibEquipment(aibref, equitype, _).

        };
        let input1 = input as #{AibEquipment, AibParentName, AibCommonName, AibHKey, Floc, Equi, EquiLocation, SubFloc, FlocLevel, EquiType | r};
        solve (input1 <+> rules) project Floc, Equi, EquiLocation, SubFloc, FlocLevel, EquiType

    def nameAfterNeedle(substr: {substr :: String}, commonName: String): String = 
        match String.breakOnRight(substr = substr.substr + "/", commonName) {
            case (all, "") => all
            case (_, rs) => rs
        }


    /// Temporary relations to generate Base relations...
    pub rel AibEquipment(plinum: String, equiType: String, flocPath: String)

    pub rel AibCommonName(refnum: String, commonName: String)

    pub rel AibHKey(sainum: String, hkey: String, parentHKey: String)



    /// Note this can produce "PIPEWORK AND FITTINGS" and "MEDIA" which are not "true" equipment.
    def getEquipment(rows: List[ExportRow]): Result[#{AibEquipment |r}, String] & Impure = 
        use Result.flatMap;
        use RelLib/Relation.{optional};
        let* patt = Text/Regex/Pattern.compile("^(?<flocPath>.+)/EQUIPMENT: (?<equiType>.+)$");
        RelLib/Relation.foldMapResult(x1 -> Text/Regex.evalMatchesOption(patt, evalEquipment(x1.reference), x1.commonName) |> Result.map(optional), rows)


    /// This should be pure?
    def evalEquipment(sainum: String): MatchEvaluator[#{AibEquipment |r}] & Impure = 
        use Text/Regex/MatchEvaluator.{getCaptureNamed, lift2};
        let eval1 = lift2((s1, s2) -> #{AibEquipment(sainum, String.trim(s1), s2). }, getCaptureNamed("equiType"), getCaptureNamed("flocPath"));
        eval1

    def getCommonNames(rows: List[ExportRow]): #{AibCommonName |r}  = 
        RelLib/Relation.foldMap(x1 -> #{ AibCommonName(x1.reference, x1.commonName). }, rows)

    def getAibHKeys(rows: List[ExportRow]): #{AibHKey |r}  = 
        let step = x1 -> 
            RelLib/Relation.when(String.startsWith(prefix = "1", x1.hkey) or String.startsWith(prefix = "2", x1.hkey),
                                    #{ AibHKey(x1.reference, x1.hkey, decreaseHKey(x1.hkey)). });
        RelLib/Relation.foldMap(step, rows)


    def decreaseHKey(hkey: String): String = 
        if (hkey == "TODO" or String.isEmpty(hkey)) 
            "TODO"
        else
            match String.length(hkey) {
                case 1 => ""
                case 4 => String.takeLeft(1, hkey)
                case 8 => String.takeLeft(4, hkey)
                case 13 => String.takeLeft(8, hkey)
                case 20 => String.takeLeft(13, hkey)
                case 24 => String.takeLeft(20, hkey)
                case 31 => String.takeLeft(24, hkey)
                case 36 => String.takeLeft(31, hkey)
                case _ => ""
            }

    def flocLevel(hkey: String): Int32 =     
        if (hkey == "TODO" or String.isEmpty(hkey)) 
            -1
        else
            match String.length(hkey) {
                case 1 => 1
                case 4 => 2
                case 8 => 3
                case 13 => 4
                case 20 => 5
                case 24 => 5
                case 31 => 6
                case 36 => 7
                case _ => -1
            }

    pub rel AibFlocType(sainum: String, floctype: String)

    pub def getFlocType(rows: List[ExportRow]): #{AibFlocType |r}  = 
        RelLib/Relation.foldMap(x1 -> #{ AibFlocType(x1.reference, flocType(x1.hkey)). }, rows)

    def flocType(hkey: String): String = match String.length(hkey) {
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

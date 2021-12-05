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



namespace AssetLib/Aruba/Aib/Import/ExportFile {

    use Text/Regex.MatchEvaluator;

    use SheetIO/Reader.{XlsxSource};
    use SheetIO.NamedRowEvaluator;

    use AssetLib/Aruba/Aib/Base.{AibFloc, AibEqui, AibSubFloc, AibEquiLocation, AibSubEqui, AibFlocLevel, AibEquiType};
    use AssetLib/Aruba/Aib/Import/Internal/HierarchyNames.{AibParentName};

    pub type alias ExportRow = 
        { reference :: String
        , commonName :: String
        , hkey :: String
        , assetStatus :: String
        , gridref :: String
        }



    pub def readExportRelations(src: XlsxSource): Result[#{AibEquipment, AibCommonName, AibParentName, AibHKey}, String] & Impure =         
        use Result.{flatMap};
        let* rows = SheetIO/Reader.allNamedRows(evalExportRow(), src);
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
                                |> AssetLib/Aruba/Aib/Import/Internal/HierarchyNames.getParentNames;
        let hkeys           = getAibHKeys(rows);                                
        Ok(equi <+> commonNames <+> parents <+> hkeys)

    pub rel HasParent(aibref: String)

    /// No SubEqui - this is not represented in Aib.
    pub def toBase(input: #{AibEquipment, AibCommonName, AibParentName, AibHKey | r}): #{AibFloc, AibEqui, AibEquiLocation, AibSubFloc, AibFlocLevel, AibEquiType | r1} = 
        let rules = #{ 

            HasParent(aibref) :- AibParentName(aibref, _).

            AibEqui(aibref, equiname) :- 
                AibEquipment(aibref, _, _), 
                AibParentName(aibref, equiname).

            /// Root floc
            AibFloc(aibref, commonName, commonName) :- 
                AibCommonName(aibref, commonName),
                not HasParent(aibref),
                if not (String.contains(substr = "EQUIPMENT: ", commonName) or String.contains(substr = "EQPT: ", commonName)).

            AibFloc(aibref, commonName, nameAfterNeedle({substr = parentName}, commonName)) :- 
                AibCommonName(aibref, commonName),
                AibParentName(aibref, parentName),
                if not (String.contains(substr = "EQUIPMENT: ", commonName) or String.contains(substr = "EQPT: ", commonName)).

            AibEquiLocation(equiId, floc) :- 
                AibEquipment(equiId, _, floc).
            
            /// This is more complicated due to Installation / Sub Installation...
            /// Probably needs to be a longest prefix lattice.
            /// Or just don't generate...
            AibSubFloc(parent, child) :- 
                AibHKey(child, _, parentHKey), 
                AibHKey(parent, parentHKey, _).
            
            AibFlocLevel(aibref, flocLevel(hkey)) :- 
                AibHKey(aibref, hkey, _), 
                if String.length(hkey) > 0.

            AibEquiType(aibref, equitype) :- 
                AibEquipment(aibref, equitype, _).

        };
        let input1 = input as #{AibEquipment, AibParentName, AibCommonName, AibHKey, AibFloc, 
                                AibEqui, AibEquiLocation, AibSubFloc, AibFlocLevel, AibEquiType, HasParent | r};
        solve (input1 <+> rules) project AibFloc, AibEqui, AibEquiLocation, AibSubFloc, AibFlocLevel, AibEquiType

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
        let* patt = Text/Regex/Pattern.compile("^(?<flocPath>.+)/EQ(UI)?P(MEN)?T: (?<equiType>.+)$");
        RelLib/Relation.foldMapResult(x1 -> Text/Regex.evalMatchesOption(patt, evalEquipment(x1.reference), x1.commonName) |> Result.map(optional), rows)


    /// This should be pure?
    def evalEquipment(sainum: String): MatchEvaluator[#{AibEquipment |r}] = 
        use Text/Regex/MatchEvaluator.{getCaptureNamed, lift2};
        let eval1 = lift2((s1, s2) -> #{AibEquipment(sainum, String.trim(s1), s2). }, getCaptureNamed("equiType"), getCaptureNamed("flocPath"));
        eval1

    def getCommonNames(rows: List[ExportRow]): #{AibCommonName |r}  = 
        RelLib/Relation.foldMap(x1 -> #{ AibCommonName(x1.reference, x1.commonName). }, rows)

    def getAibHKeys(rows: List[ExportRow]): #{AibHKey |r}  = 
        let step = x1 -> 
            RelLib/Relation.whenTrue(String.startsWith(prefix = "1", x1.hkey) or String.startsWith(prefix = "2", x1.hkey),
                                    #{ AibHKey(x1.reference, x1.hkey, decreaseHKey(x1.hkey)). });
        RelLib/Relation.foldMap(step, rows)

    /// This is more complicated, currently doesn't account for "Installation" versus "Sub_Installation"...
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


    def flocLevel(hkey: String): String = match String.length(hkey) {
        case 1 => "Business_Unit"
        case 4 => "System"
        case 8 => "Function"
        case 13 => "Installation"
        case 18 => "Sub_Installation"
        case 20 => "Process_Group"
        case 24 => "Process"
        case 31 => "Plant"
        case 36 => "Plant_Item"
        case _ => "Unknown"
    }


}

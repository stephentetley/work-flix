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



namespace Hierarchy/Facts {

    use Text/Regex.MatchEvaluator;
    use RelLib.{RegexExtractor};
    use Hierarchy/Loader.{ExportRow};

    pub rel Equipment(plinum: String, equiType: String, flocName: String)

    pub rel CommonName(refnum: String, name: String)

    pub rel InstalledDate(refnum: String, installDate: Time.LocalDate)

    pub rel FlocType(sainum: String, floctype: String)

    pub def getEquipment(rows: List[ExportRow]): Result[#{Equipment |r}, String] & Impure = 
        let patt = "^(?<flocName>.+)/EQUIPMENT: (?<equiType>.+)$" |> RelLib/RegexExtractor.unsafeCompileRegex;
        RelLib/Relation.foldMapResult(x1 -> Text/Regex.evalMatches(x1.commonName, patt, getEquipment1(x1.reference)), rows)


    /// This should be pure?
    def getEquipment1(sainum: String): MatchEvaluator[#{Equipment |r}] & Impure = 
        use Text/Regex/MatchEvaluator.{getCaptureNamed, lift2, withDefault};
        let eval1 = lift2((s1, s2) -> #{Equipment(sainum, String.trim(s1), s2). }, getCaptureNamed("equiType"), getCaptureNamed("flocName"));
        withDefault(eval1, #{})



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

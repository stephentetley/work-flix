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

namespace FmpSkeleton/Main {
    
    use AssetLib/Facts/SiteMapping.{SiteMapping};
    use AssetLib/AibRel/HierarchicalRelations.{AibSite, AibFloc, AibEquipment};
    use AssetLib/S4Rel/Relations.{FlocDatum, FlocLongText, FlocCharacteristic, 
        EquiDatum, EquiLongText, EquiCharacteristic};
    use FmpSkeleton/Rules.{Status, EqRecognized};

    type alias Config = 
        { siteMappingFile: System.FilePath
        , uxlTemplate: System.FilePath
        , sourceDir: System.FilePath
        }

    pub def main1(config: Config): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        let* siteMapping    = AssetLib/Facts/SiteMapping.getSiteMapping(config.siteMappingFile);
        let _               = Console.printLine("Site map has been read...");
        let* xs             = Option.toOk(System/Directory.contents(config.sourceDir), "fail1");
        let files           = List.filterMap(checkIsSourceFile, xs);
        let* _              = Result.traverseX(processSiteFile(siteMapping, config.uxlTemplate), files);
        Ok()

    def checkIsSourceFile(x: System.FilePath): Option[System.FilePath] = 
        use Option.{flatMap};
        let* patt = Text/Regex/Pattern.compile("aib-export-(.*)\.xlsx");
        let* name1 = System/FilePath.getFileName(x) |> Option.map(ToString.toString);
        if (Text/Regex.matches(name1, patt)) 
            Some(x)
        else 
            None

    def processSiteFile[r](siteMapping: #{SiteMapping, AibSite, AibFloc, AibEquipment, 
                                            FlocDatum, FlocLongText, FlocCharacteristic,
                                            EquiDatum, EquiLongText, EquiCharacteristic, Status | r},
                            uxlTemplate: System.FilePath, 
                            src: System.FilePath): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        let* facts      = AssetLib/AibRel/HierarchicalRelations.readAibSiteFacts(src);
        let solns       = solve (FmpSkeleton/Rules.equiRules() <+> FmpSkeleton/Rules.status() <+> siteMapping <+> facts);        
        let siteName    = (x, _) -> {let (_, name, _) = x; name};
        let longname    = fold AibSite "temp" siteName solns;
        let name        = fst(String.breakOnLeft("/", longname)) |> String.replace(" ", "_");
        let outpath     = System/FilePath.replaceFileName(src, "${name}_uxl.xlsx");
        let _           = Console.printLine("Writing: ${outpath}");
        let* _          = AssetLib/S4Rel/EmitUxl.outputUxl("${longname} New FMP", solns, uxlTemplate, outpath);
        Ok()


}

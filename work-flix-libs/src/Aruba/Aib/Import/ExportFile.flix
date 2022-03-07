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



namespace Aruba/Aib/Import/ExportFile {

    use Functor.{<$>};
    use Applicative.{<*>};

    use Text/Regex.MatchEvaluator;

    use SheetIO/Reader.{XlsxSource};
    use SheetIO.NamedRowEvaluator;

    use Aruba/Aib/Base.{AibFloc, AibEqui, AibSubFloc, AibEquiLocation, AibSubEqui, AibFlocLevel, AibEquiType};
    use Aruba/Aib/Import/Internal/HierarchyNames.{AibParentName};

    pub type alias ExportRow = 
        { reference :: String
        , commonName :: String
        , hkey :: String
        , assetStatus :: String
        , gridref :: String
        }



    pub def readExportRelations(src: XlsxSource): Result[#{AibEqui, AibFloc | r}, String] & Impure =         
        use Result.{flatMap};
        let* rows = SheetIO/Reader.allNamedRows(evalExportRow(), src);
        buildExportFileRelations(rows)

    def evalExportRow(): NamedRowEvaluator[ExportRow] = 
        use SheetIO/NamedRowEvaluator.{getTrimmedContentNamed, getLocalDateNamed};
        ((x1, x2, x3, x4, x5) -> 
            { reference         = x1
            , commonName        = x2
            , hkey              = x3
            , assetStatus       = x4
            , gridref           = x5
            })
            <$> getTrimmedContentNamed("Reference")
            <*> getTrimmedContentNamed("Common Name")
            <*> getTrimmedContentNamed("Hierarchy Key")
            <*> getTrimmedContentNamed("AssetStatus")
            <*> getTrimmedContentNamed("Loc.Ref.")



    def buildExportFileRelations(rows: List[ExportRow]): Result[#{AibEqui, AibFloc | r}, String] & Impure = 
        use Result.{flatMap};
        let* equi           = getEquipment(rows);
        let* flocs          = getFuncloc(rows);
        Ok(equi <+> flocs)


    /// Note this can produce "PIPEWORK AND FITTINGS" and "MEDIA" which are not "true" equipment.
    def getEquipment(rows: List[ExportRow]): Result[#{AibEqui |r}, String] & Impure = 
        use Result.flatMap;
        let* patt = Text/Regex/Pattern.compile("^.+/EQ(UI)?P(MEN)?T: (?<equiType>.+)$");
        RelLib/Relation.foldMapResult(getEquipment1(patt), rows)

    def getEquipment1(patt: Text/Regex.Pattern, row: ExportRow): Result[#{AibEqui |r}, String] & Impure =
        use Result.flatMap;
        use Text/Regex/MatchEvaluator.{getCaptureNamed};        
        let* equiType = Text/Regex.evalMatchesOptional(patt, getCaptureNamed("equiType"), row.commonName);
        match equiType { 
            case None      => Ok(#{})
            case Some(ty1) => Ok(#{ AibEqui(row.reference, row.commonName, ty1). })
        }

    def getFuncloc(rows: List[ExportRow]): Result[#{AibFloc |r}, String] = 
        use Result.flatMap;
        let* patt = Text/Regex/Pattern.compile("^.+/EQ(UI)?P(MEN)?T: .+$");
        RelLib/Relation.foldMapResult(getFuncloc1(patt), rows)

    def getFuncloc1(patt: Text/Regex.Pattern, row: ExportRow): Result[#{AibFloc |r}, String] =     
        if (Text/Regex.isMatch(patt, row.commonName))
            Ok(#{})
        else 
            if (row.hkey != "TODO")
                Ok(#{ AibFloc(row.reference, row.commonName, row.hkey). })
            else
                Ok(#{})


}

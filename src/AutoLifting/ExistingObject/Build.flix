/*
 * Copyright 2020 Stephen Tetley
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

namespace AutoLifting/ExistingObject/Build {

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatement;

    use AssetLib/S4/FileIO/DownloadFile.RowEvaluator;
    use AssetLib/S4/FileIO/ZTable/ExportDb.ZTableSourcePaths;
    use AutoLifting/Common.ReportMonad;
    use AutoLifting/ExistingObject/Datatypes.{S4LiftingItem, EquiAttributes, equiRowEvaluator};

    type alias BuilderSource = 
        { equiFile: System.FilePath
        , classFile: System.FilePath
        , charFile: System.FilePath
        , mltextFile: System.FilePath
        , dbtempFile: System.FilePath
        }

    pub def setupFacts(classFacts: System.FilePath, zTablePaths: ZTableSourcePaths, dbout: System.FilePath): ReportMonad[Unit] = 
        use AutoLifting/Common/ReportMonad.{liftActionResult};
        use BasicDb/DbMonad.{runSQLite};
        liftActionResult(_ -> runSQLite(setupFactsHelper(classFacts, zTablePaths), dbout))
        


    def setupFactsHelper(classFacts: System.FilePath, zTablePaths: ZTableSourcePaths): DbMonad[Unit] = 
        use BasicDb/DbMonad.{flatMap, return};
        use AssetLib/S4/FileIO/ClassList/ExportDb.{defaultTableNames => classTableNames, storeEquiClassFile};
        use AssetLib/S4/FileIO/ZTable/ExportDb.{defaultTableNames => ztableNames, storeZTableFiles};
        let* _      = storeEquiClassFile(classTableNames(), true, classFacts, Text/Charset.iso_8859_1());
        let* _      = storeZTableFiles(ztableNames(), zTablePaths);
        return()


    pub def build(src: BuilderSource): ReportMonad[Unit] = 
        use AutoLifting/Common/ReportMonad.{flatMap, return, mapM, liftActionResult, liftAction};
        use AssetLib/S4/FileIO/DownloadFile/Evaluate.{allRows};
        use BasicDb/DbMonad.{runSQLite};
        let* _      = liftActionResult(_ -> runSQLite(buildSourceDb(src), src.dbtempFile));
        let* xs     = liftActionResult(_ -> allRows(equiRowEvaluator(), src.equiFile));
        let* ys     = liftActionResult(_ -> runSQLite(buildS4LiftingItems(xs), src.dbtempFile));
        let* _      = mapM(x -> liftAction(_ -> Console.printLine("${x.equi.equiId} ${Int32.toString(List.length(x.classifications))} classifications")), ys);
        return()

    def buildSourceDb(src: BuilderSource): DbMonad[Unit] = 
        use BasicDb/DbMonad.{flatMap, return};
        let* _      = AssetLib/S4/FileIO/DownloadFile/Builtins.storeEqmltxtFile("eqmltxt", true, src.mltextFile);
        let* _      = AssetLib/S4/FileIO/DownloadFile/Builtins.storeClassEquiFile("class_equi", true, src.classFile);
        let* _      = AssetLib/S4/FileIO/DownloadFile/Builtins.storeValuaEquiFile("valua_equi", true, src.charFile);
        return()

    pub def buildS4LiftingItems(xs: List[EquiAttributes]): DbMonad[List[S4LiftingItem]] = 
        use BasicDb/DbMonad.{flatMap, return, mapM};
        let* ltps   = AutoLifting/ExistingObject/GetLongText.prepareLongTextQuery();
        let* clps   = AutoLifting/ExistingObject/GetClassifications.prepareClassificationsQuery();
        let* ys     = mapM(buildS4LiftingItem(ltps, clps), xs);
        return(ys)

    def buildS4LiftingItem(ltps: PreparedStatement, clps: PreparedStatement, x: EquiAttributes): DbMonad[S4LiftingItem] = 
        use BasicDb/DbMonad.{flatMap, return};
        let* longText   = AutoLifting/ExistingObject/GetLongText.getLongText(ltps, x.equiId);
        let* cs         = AutoLifting/ExistingObject/GetClassifications.getClassifications(clps, x.equiId);
        return(
            { equi              = x
            , longText          = longText
            , classifications   = cs
            })


}
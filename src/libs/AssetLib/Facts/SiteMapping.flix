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

namespace AssetLib/Facts/SiteMapping {
    
    use BasicDb.DbMonad;
    use BasicDb.PreparedStatementSetter;

    use SheetIO.SheetReader;
    use SheetIO.NamedRowEvaluator;

    /// Set up DB

    type alias SiteMappingRow = 
        { installationCommonName: String
        , s4Level1Code: Option[String]
        }
        
    
    pub def storeSiteMapping(tableName: String, src: System.FilePath) : DbMonad[Unit] = 
        use BasicDb/DbMonad.{return, flatMap, liftActionResult, map};
        let* xs     = liftActionResult(_ -> SheetIO/SheetReader.runXlsx(readXlsSiteMappingTable(), src));
        let* _      = exportSiteMappingRows(tableName, xs);
        return()


    def readXlsSiteMappingTable(): SheetReader[List[SiteMappingRow]] = 
        use SheetIO/SheetReader.{flatMap, return, getSheetNamed, allNamedRows};      
        let* s1     = getSheetNamed("inst to SAP migration");
        let* xs     = allNamedRows(s1, evalXlsSiteMappingRow());
        return(xs)

    
    def evalXlsSiteMappingRow(): NamedRowEvaluator[SiteMappingRow] = 
        use SheetIO/NamedRowEvaluator.{flatMap, return, getStringNamed, optional};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        use String.{trim};
        ((x1, x2) ->
                { installationCommonName    = x1
                , s4Level1Code              = x2
                })
            <&> getStringNamed("AI2_InstallationCommonName")
            <*> optional(getStringNamed("L1 exists in S4 01/10/2019"))

    /// Always drop table (fresh new data)
    def exportSiteMappingRows(tableName: String, rows: List[SiteMappingRow]): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, return, execute, foldLeftM, prepareStatement, psExecuteUpdate, setAutoCommit, commit};
        let* _          = setAutoCommit(false);
        let* _          = execute("DROP TABLE IF EXISTS ${tableName};");
        let* _          = execute(createTableSql(tableName));
        let* stmt       = prepareStatement("INSERT INTO ${tableName} (installation_common_name, s4_level1_code) VALUES(?,?);");
        let* nrows      = foldLeftM((ac, x) -> { let* n = psExecuteUpdate(stmt, siteMappingRowSetter(x)); return(ac+n)}, 0, rows);
        let* _          = commit();
        return(nrows)

    /// A setter for SiteMappingRow
    def siteMappingRowSetter(x: SiteMappingRow): PreparedStatementSetter[Unit] = 
        use BasicDb/PreparedStatementSetter.{flatMap, return, putStringAt!, putOptionStringAt!};
        let* _ = putStringAt!(0, x.installationCommonName);
        let* _ = putOptionStringAt!(1, x.s4Level1Code);
        return()


    def createTableSql(tableName: String): String =
        String.unwords(
            "CREATE TABLE IF NOT EXISTS ${tableName} ("
                :: "installation_common_name    TEXT NOT NULL,"
                :: "s4_level1_code              TEXT"
                :: ")"
                :: Nil
        )

    /// Query Site Mapping...

    pub def cacheS4SiteCodeQuery(tableName: String): DbMonad[Unit] = 
        let sql = String.unlines(
                "SELECT"
                :: "    t.s4_level1_code"
                :: "FROM ${tableName} t"
                :: "WHERE "
                :: "    t.installation_common_name = ?"
                :: Nil
            );
        BasicDb/DbMonad.cachePreparedStatement("getS4SiteCode", sql)


    pub def getS4SiteCode(aibSiteName: String): DbMonad[Option[String]] = 
        use BasicDb/DbMonad.{flatMap, return, psExecuteCachedQuery, firstRow, optional, rsClose, map};
        let* rs     = psExecuteCachedQuery("getS4SiteCode", BasicDb/PreparedStatementSetter.putStringAt!(0,  aibSiteName));
        let* x1     = map(optionNotNull, optional(firstRow(rs, BasicDb/RowEvaluator.getStringNamed("s4_level1_code"))));
        let* _      = rsClose(rs);
        return(x1)

    def optionNotNull(x: Option[String]): Option[String] = match x { 
        case Some(s1) => if (Object.isNull(s1)) None else Some(s1)
        case None => None
    }


    /// Datalog

    pub rel SiteMapping(aibInst: String, s4Site: String)

    pub def getSiteMapping(src: System.FilePath) : Result[#{SiteMapping |r}, String] & Impure = 
        use Result.{flatMap};
        let* xs = SheetIO/SheetReader.runXlsx(readXlsSiteMappingTable(), src);
        let step = (ac, x) -> {
            let x1 = #{ SiteMapping(x.installationCommonName, Option.getWithDefault(x.s4Level1Code, "")). };
            x1 <+> ac
        };
        Ok(solve List.foldLeft(step, #{}, xs))   

}

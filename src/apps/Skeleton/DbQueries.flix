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


namespace Skeleton/DbQueries {

    use BasicDb.DbMonad;
    use Skeleton.S4Floc;

    /// Bactrack to the parent floc if the query fails...
    pub def flocBestMatch(floc: S4Floc, query: S4Floc -> DbMonad[a]): DbMonad[a] = 
        use BasicDb/DbMonad.{flatMap, return, alt};
        match Skeleton/S4Floc.parent(floc) {
            case Some(parent) => alt(query(floc), flocBestMatch(parent, query))
            case None => query(floc)
        }

    pub def getFlocStartupDate(floc: S4Floc): DbMonad[Time.LocalDate] = flocBestMatch(floc, getFlocStartupDateHelper)

    def getFlocStartupDateHelper(floc: S4Floc): DbMonad[Time.LocalDate] = 
        use BasicDb/DbMonad.{flatMap, return, psExecuteQueryAndCachePS, firstRow, rsClose, liftOption};
        use BasicDb/PreparedStatementSetter.{putStringAt!};
        let* rs     = psExecuteQueryAndCachePS("GetFlocStartupDate", getFlocAttributeFromFactsSql("installed_from"), putStringAt!(0, ToString.toString(floc)));
        let* x1     = firstRow(rs, BasicDb/RowEvaluator.getStringAt(0));
        let* t1     = liftOption(FromString.fromString(x1): Option[Time.LocalDate], "Invalid date - ${x1}");
        let* _      = rsClose(rs);
        return(t1)


    pub def getFlocGridRef(floc: S4Floc): DbMonad[String] = flocBestMatch(floc, getFlocGridRefHelper)

    def getFlocGridRefHelper(floc: S4Floc): DbMonad[String] =
        use BasicDb/DbMonad.{flatMap, return, psExecuteQueryAndCachePS, firstRow, rsClose, liftOption};
        use BasicDb/PreparedStatementSetter.{putStringAt!, seqRight};
        let* rs     = psExecuteQueryAndCachePS("GetFlocGridRef", getFlocAttributeFromFactsSql("loc_ref"), putStringAt!(0, ToString.toString(floc)));
        let* x1     = firstRow(rs, BasicDb/RowEvaluator.getStringAt(0));
        let* _      = rsClose(rs);
        return(x1)

    pub def getFlocReference(floc: S4Floc): DbMonad[String] = flocBestMatch(floc, getFlocReferenceHelper)

    def getFlocReferenceHelper(floc: S4Floc): DbMonad[String] =
        use BasicDb/DbMonad.{flatMap, return, psExecuteQueryAndCachePS, firstRow, rsClose, liftOption};
        use BasicDb/PreparedStatementSetter.{putStringAt!, seqRight};
        let* rs     = psExecuteQueryAndCachePS("GetFlocReference", getFlocAttributeFromFactsSql("reference"), putStringAt!(0, ToString.toString(floc)));
        let* x1     = firstRow(rs, BasicDb/RowEvaluator.getStringAt(0));
        let* _      = rsClose(rs);
        return(x1)


    def getFlocAttributeFromFactsSql(columnName: String): String = 
        String.unlines(
               "SELECT t2.${columnName}"
            :: "FROM floc_mapping t1"
            :: "LEFT OUTER JOIN aib_facts t2 ON t1.reference = t2.reference"
            :: "WHERE"
            :: "    t1.s4_floc = ?"
            :: Nil
        )

    pub def getParentReference(commonName: String): DbMonad[String] = 
        use BasicDb/DbMonad.{flatMap, return, psExecuteQueryAndCachePS, firstRow, rsClose, alt};
        use BasicDb/PreparedStatementSetter.{putStringAt!, seqRight};
        let* rs     = psExecuteQueryAndCachePS("GetParentReference", getParentReferenceSql(), seqRight(putStringAt!(0, commonName), putStringAt!(1, commonName)));
        let* x1     = firstRow(rs, BasicDb/RowEvaluator.getStringNamed("reference")) `alt` return("");
        let* _      = rsClose(rs);
        return(x1)


    def getParentReferenceSql(): String = 
        String.unlines(
                "SELECT t1.reference AS reference"
            :: "FROM"
            :: "    aib_facts t1"
            :: "WHERE t1.common_name IN ("
            :: "    SELECT DISTINCT(substr(?, 0, length(t2.common_name) + 1))"
            :: "    FROM aib_facts t2"
            :: "    WHERE"
            :: "        length(t2.common_name) < length(?)"
            :: ")"
            :: "ORDER BY length(t1.common_name) DESC"
            :: "LIMIT 1;"
            :: Nil
        )


    pub def getDescription(x: S4Floc): DbMonad[String] = 
        use BasicDb/DbMonad.{flatMap, return, psExecuteQueryAndCachePS, firstRow, rsClose, alt};
        use BasicDb/PreparedStatementSetter.{putStringAt!};
        match Skeleton/S4Floc.objectType(x) {
            case Some(objType) => {
                let* rs     = psExecuteQueryAndCachePS("GetS4FlocDescription", getDescriptionSql(), putStringAt!(0, objType));
                let* x1     = firstRow(rs, BasicDb/RowEvaluator.getStringNamed("description")) `alt` return("");
                let* _      = rsClose(rs);
                return(x1)
            } 
            case None => return("")
        }
        

    def getDescriptionSql(): String = 
        String.unlines(
               "SELECT"
            :: "    max(t1.description) AS description"
            :: "FROM ztable_flocdes t1"
            :: "WHERE "
            :: "    t1.object_type= ?"
            :: Nil
        )



}    
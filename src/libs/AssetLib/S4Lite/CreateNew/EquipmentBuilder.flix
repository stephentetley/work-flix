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


/// Build equipment from stored facts.
/// This is to replace `EquiDownloadBuilder`.

namespace AssetLib/S4Lite/CreateNew/EquipmentBuilder {

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatement;
    use BasicDb.PreparedStatementSetter;
    use BasicDb.RowEvaluator;

    
    use AssetLib/S4Lite/CreateNew/Datatypes.{EquiDatum, EquiAttributes, LongText, Classification};
    use AssetLib/S4Lite/CreateNew/Common.{evalClassification, evalLongText};


    type alias TableNames = 
        { simpleEqui: String
        , downloadfileMltxt: String
        , downloadfileClassequi: String
        , downloadfileValuaequi: String
        , classFactsMembers: String
        , classFactsCharDefs: String
        }

    type alias EquipmentPreparedStatements = 
        { selectAttributes: PreparedStatement
        , selectLongText: PreparedStatement
        , selectClassifications: PreparedStatement
        }

    pub def cachePreparedStatements(tableNames: TableNames): DbMonad[EquipmentPreparedStatements] = 
        use BasicDb/DbMonad.{flatMap, return};
        let* attrs      = prepareEquiAttributesQuery(tableNames.simpleEqui);
        let* longText   = prepareEquiLongTextQuery(tableNames.downloadfileMltxt);
        let* classes    = prepareEquiClassificationsQuery( tableNames.classFactsMembers
                                                        , tableNames.classFactsCharDefs
                                                        , tableNames.downloadfileClassequi
                                                        , tableNames.downloadfileValuaequi);
        return({ selectAttributes       = attrs
               , selectLongText         = longText
               , selectClassifications  = classes
            })

    pub def buildS4Equipment(cachedStmts: EquipmentPreparedStatements, equiId: String): DbMonad[EquiDatum] = 
        use BasicDb/DbMonad.{flatMap, return};
        let* attrs      = getEquiAttributes(cachedStmts.selectAttributes, equiId);
        let* longText   = getEquiLongText(cachedStmts.selectLongText, equiId);
        let* classes    = getEquiClassifications(cachedStmts.selectClassifications, equiId);
        return(
            { equiId            = equiId
            , attributes        = attrs
            , longText          = longText
            , classifications   = classes
            })

    def prepareEquiAttributesQuery(tableName: String): DbMonad[PreparedStatement] = 
        let sql = String.unlines(
                "SELECT"
                :: "    e.category,"
                :: "    e.description,"
                :: "    e.object_type,"
                :: "    e.startup_date,"
                :: "    e.manufacturer,"
                :: "    e.model,"
                :: "    e.part_number,"
                :: "    e.serial_number,"
                :: "    e.construction_year,"
                :: "    e.construction_month,"
                :: "    e.maintenance_plant,"
                :: "    e.company_code,"
                :: "    e.controlling_area,"
                :: "    e.planning_plant,"
                :: "    e.functional_location,"
                :: "    e.superordinate_equi_id,"                
                :: "    e.tech_indet_no,"
                :: "    e.status"
                :: "FROM ${tableName} e"
                :: "WHERE "
                :: "    e.equi_id = ?"
                :: Nil
            );
        BasicDb/DbMonad.prepareStatement(sql)

    def getEquiAttributes(pstmt: PreparedStatement, equiId: String): DbMonad[EquiAttributes] = 
        use BasicDb/DbMonad.{flatMap, return, psExecuteQuery, firstRow, rsClose};
        let* rs     = psExecuteQuery(pstmt, setEquiAttributesPStmt!(equiId));
        let* x1     = firstRow(rs, evalEquiAttributes());
        let* _      = rsClose(rs);
        return(x1)


    def evalEquiAttributes(): RowEvaluator[EquiAttributes] = 
        use BasicDb/RowEvaluator.{getStringNamed, getInt32Named};
        use BasicDb/RowEvaluator.{<&>, <*>};
        use AssetLib/Base/S4/BasicDbUtils.{getS4DateNamed};
        ((x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18) ->
                { category              = x1
                , description           = x2
                , objectType            = x3
                , startupDate           = x4
                , manufacturer          = x5
                , model                 = x6
                , partNumber            = x7
                , serialNumber          = x8
                , constructionYear      = x9
                , constructionMonth     = x10
                , maintPlant            = x11
                , companyCode           = x12
                , controllingArea       = x13
                , planningPlant         = x14
                , functionalLocation    = x15
                , superOrdinateEqui     = x16
                , techIdentNo           = x17
                , status                = x18
                })
            <&> getStringNamed("category")                  /// Equipment Category
            <*> getStringNamed("description")               /// Description (medium text)        
            <*> getStringNamed("object_type")               /// Object Type          
            <*> getS4DateNamed("startup_date")              /// Startup Date
            <*> getStringNamed("manufacturer")              /// Manufacturer
            <*> getStringNamed("model")                     /// Model 
            <*> getStringNamed("part_number")               /// Manufact Part No
            <*> getStringNamed("serial_number")             /// Manufact Serial Number
            <*> getInt32Named("construction_year")          /// Construction year
            <*> getInt32Named("construction_month")         /// Construction month
            <*> getInt32Named("maintenance_plant")          /// Maintenance Plant
            <*> getInt32Named("company_code")               /// Company Code
            <*> getInt32Named("controlling_area")           /// Controlling Area
            <*> getInt32Named("planning_plant")             /// Planning Plant
            <*> getStringNamed("functional_location")       /// Functional Location
            <*> getStringNamed("superordinate_equi_id")     /// Superord Equipment
            <*> getStringNamed("tech_ident_no")             /// Techinical IdentNo
            <*> getStringNamed("status")                    /// Status of an object


    
    def setEquiAttributesPStmt!(equiId: String): PreparedStatementSetter[Unit] = 
        BasicDb/PreparedStatementSetter.putStringAt!(0,  equiId)

    /// Long Text
    def prepareEquiLongTextQuery(tableName: String): DbMonad[PreparedStatement] = 
        let sql = String.unwords(
               "SELECT"
            :: "    t.short_text, t.long_text"
            :: "FROM"
            :: "    ${tableName} t"
            :: "WHERE"
            :: "    t.equi = ?;"
            :: Nil
        );
        BasicDb/DbMonad.prepareStatement(sql)

    def getEquiLongText(pstmt: PreparedStatement, equiId: String): DbMonad[Option[LongText]] = 
        use BasicDb/DbMonad.{flatMap, return, psExecuteQuery, optional, firstRow, rsClose};
        let* rs     = psExecuteQuery(pstmt, setEquiLongTextPStmt!(equiId));
        let* ans    = optional(firstRow(rs, evalLongText()));
        let* _      = rsClose(rs);
        return(ans)

    def setEquiLongTextPStmt!(equiId: String): PreparedStatementSetter[Unit] = 
        BasicDb/PreparedStatementSetter.putStringAt!(0,  equiId)



    /// Classification

    /// This query depends on two `fact tables` - cf_members and cf_char_defs. 
    def prepareEquiClassificationsQuery( classFactsMembers: String
                                       , classFactsCharDefs: String
                                       , classEquiTable: String
                                       , valuaEquiTable: String): DbMonad[PreparedStatement] = 
        let sql = String.unlines(
               "SELECT"
            :: "    c.class_name, cfm.charname, cfcd.datatype, v.value_description, v.value_from"
            :: "FROM"
            :: "    ${classEquiTable} c"
            :: "INNER JOIN  ${classFactsMembers} cfm        ON c.class_name = cfm.classname"
            :: "JOIN        ${classFactsCharDefs} cfcd      ON cfm.charname = cfcd.charname"
            :: "JOIN        ${valuaEquiTable} v             ON c.equi = v.equi AND cfm.charname = v.char_id"
            :: "WHERE"
            :: "    c.equi = ?"
            :: "AND cfm.classtype = 'equi'"
            :: "AND cfcd.classtype = 'equi'"
            :: "ORDER BY c.class_name;"
            :: Nil
        );
        BasicDb/DbMonad.prepareStatement(sql)

    def getEquiClassifications(pstmt: PreparedStatement, equiId: String): DbMonad[List[Classification]] = 
        use BasicDb/DbMonad.{flatMap, return, psExecuteQuery, allRows, rsClose};
        let* rs     = psExecuteQuery(pstmt, setEquiClassificationPStmt!(equiId));
        let* xs     = allRows(rs, evalClassification());
        let* _      = rsClose(rs);
        return(xs)


    def setEquiClassificationPStmt!(equiId: String): PreparedStatementSetter[Unit] = 
        BasicDb/PreparedStatementSetter.putStringAt!(0,  equiId)

}
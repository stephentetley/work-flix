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

namespace NewLiftingItems/MakeReport/BuildItems/AibAttributes {

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatement;
    use BasicDb.PreparedStatementSetter;
    use BasicDb.RowEvaluator;

 
    type alias AibAttributes = 
        { assetStatus: String
        , installedFrom: Time.LocalDate
        , manufacturer: String
        , model: String
        , partNumber: String
        , serialNumber: String
        , osgb36: String
        , locationOnSite: String
        , workLoad: Option[Float64]
        , workLoadUnits: String
        , statutoryRef: String
        , testCertNum: String
        }


    pub def getAibAttributes[r](pstmts: {selectAibAttributes: PreparedStatement | r}, reference: String): DbMonad[AibAttributes] = 
        use BasicDb/DbMonad.{flatMap, return, liftActionResult, psExecuteQuery, firstRow, rsClose};
        let* rs     = psExecuteQuery(pstmts.selectAibAttributes, BasicDb/PreparedStatementSetter.putStringAt!(0,  reference));
        let* x1     = firstRow(rs, evalAibAttributes());
        let* _      = rsClose(rs);
        return(x1)

    pub def prepareAibAttributesQuery(): DbMonad[PreparedStatement] = 
        let sql = String.unlines(
                "SELECT"
            :: "    t.asset_status,"
            :: "    t.installed_from,"
            :: "    t.manufacturer,"
            :: "    t.model,"
            :: "    t.part_number,"
            :: "    t.serial_number,"
            :: "    t.osgb36,"
            :: "    t.location_on_site,"
            :: "    t.work_load,"
            :: "    t.work_load_units,"
            :: "    t.statutory_ref,"
            :: "    t.test_cert_num"
            :: "FROM"
            :: "    wl_attributes t"
            :: "WHERE"
            :: "    t.reference = ?"
            :: Nil
            );
        BasicDb/DbMonad.prepareStatement(sql)

    def evalAibAttributes(): RowEvaluator[AibAttributes] = 
        use BasicDb/RowEvaluator.{getStringNamed, getFloat64Named, optional};
        use BasicDb/RowEvaluator.{<&>, <*>};
        use AssetLib/S4/Base/BasicDbUtils.{getS4DateNamed};
        ((x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12) ->
                { assetStatus       = x1
                , installedFrom     = x2
                , manufacturer      = x3
                , model             = x4
                , partNumber        = x5
                , serialNumber      = x6
                , osgb36            = x7
                , locationOnSite    = x8
                , workLoad          = x9
                , workLoadUnits     = x10
                , statutoryRef      = x11
                , testCertNum       = x12
                })
            <&> getStringNamed("asset_status")
            <*> getS4DateNamed("installed_from")
            <*> getStringNamed("manufacturer")
            <*> getStringNamed("model")
            <*> getStringNamed("part_number")
            <*> getStringNamed("serial_number")
            <*> getStringNamed("osgb36")
            <*> getStringNamed("location_on_site")            
            <*> optional(getFloat64Named("work_load"))
            <*> getStringNamed("work_load_units")
            <*> getStringNamed("statutory_ref")
            <*> getStringNamed("test_cert_num")

}

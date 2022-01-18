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


namespace AssetLib/FileIO/S4/ZTable/SQLite {

    use Functor.{<$>};
    use Applicative.{<*>};

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatementSetter;
    use BasicDb.RowEvaluator;

    use AssetLib/FileIO/S4/ZTable/Datatypes.{ManufacturerModel};

    // # Manufacturer Model

    pub def storeManufacturerModel(table: String, rows: List[ManufacturerModel]): DbMonad[Int32] =
        use BasicDb/DbMonad.{flatMap, point, foldLeftM, setAutoCommit, prepareStatement, psExecuteUpdate, commit};
        let* _          = setAutoCommit(false);
        let* stmt       = prepareStatement(insertManufacturerModelRowSql(table));
        let* nrows      = Foldable.foldLeftM((ac, x) -> 
                                {let* n = psExecuteUpdate(stmt, manufacturerModelSetter(x)); point(ac+n)}, 0, rows);
        let* _          = commit();
        point(nrows)


    def manufacturerModelSetter(x: ManufacturerModel): PreparedStatementSetter[Unit] =
        use BasicDb/PreparedStatementSetter.{flatMap, point, putStringAt!};
        let* _  = putStringAt!(0, x.manufacturer);
        let* _  = putStringAt!(1, x.model);
        point()


    def insertManufacturerModelRowSql(tableName: String): String =
        String.unwords(
            "INSERT OR IGNORE INTO ${tableName} "
                :: "(manufacturer, "
                :: "model) "
                :: "VALUES(?,?);"
                :: Nil
        )


    pub def readManufacturerModel(tableName: String): DbMonad[List[ManufacturerModel]] =         
        let sql = "SELECT manufacturer, model FROM ${tableName} ORDER BY manufacturer;";
        BasicDb/Reader.allRows(evalManufacturerModel(), sql)

    
    def evalManufacturerModel(): RowEvaluator[ManufacturerModel] = 
        use BasicDb/RowEvaluator.{getStringAt};
        ((x1, x2) -> {manufacturer = x1, model = x2})
            <$> getStringAt(0)
            <*> getStringAt(1)



}

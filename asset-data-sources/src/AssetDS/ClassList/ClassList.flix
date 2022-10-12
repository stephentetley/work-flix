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


namespace AssetDS/ClassList/ClassList {

    use Applicative.{*>}
    use Basis/NIO/File.Path;
    use BasicDb.DbMonad;

    pub def genFlocAndEquiData(flocData: {flocData :: Path}, 
                                equiData: {equiData :: Path}, 
                                dest: {dest :: Path}): Result[Unit, String] \ IO = region r {
        let actions = () -> {
            AssetDS/ClassList/SQLite.createTables() 
                *> genFlocData1(flocData)
                *> genEquiData1(equiData)
        };                     
        BasicDb/DbMonad.runSQLite(r, actions(), dest.dest)
    }       

    pub def genFlocData(flocData: {flocData :: Path}, dest: {dest :: Path}): Result[Unit, String] \ IO = region r {
        let actions = () -> {
            AssetDS/ClassList/SQLite.createTables() 
                *> genFlocData1(flocData)
        };                     
        BasicDb/DbMonad.runSQLite(r, actions(), dest.dest)
    }       

    pub def genEquiData(equiData: {equiData :: Path}, dest: {dest :: Path}): Result[Unit, String] \ IO = region r {
        let actions = () -> {
            AssetDS/ClassList/SQLite.createTables() 
                *> genEquiData1(equiData)
        };                     
        BasicDb/DbMonad.runSQLite(r, actions(), dest.dest)
    }       

    def genFlocData1(flocData: {flocData :: Path}): DbMonad[r, Unit, Unit] \ {IO, Write(r)} = 
        use BasicDb/DbMonad.{flatMap, point};
        let* x1 = BasicDb/DbMonad.liftActionResult(_ -> AssetDS/ClassList/Reader.readFlocClassRecords(flocData.flocData));
        let* _  = AssetDS/ClassList/SQLite.storeClassListData(x1);
        point()

    def genEquiData1(equiData: {equiData :: Path}): DbMonad[r, Unit, Unit] \ {IO, Write(r)} = 
        use BasicDb/DbMonad.{flatMap, point};
        let* x1 = BasicDb/DbMonad.liftActionResult(_ -> AssetDS/ClassList/Reader.readEquiClassRecords(equiData.equiData));
        let* _  = AssetDS/ClassList/SQLite.storeClassListData(x1);
        point()


}

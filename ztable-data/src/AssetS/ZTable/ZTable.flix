/*
 * Copyright 2022 Stephen Tetley
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


namespace AssetLib/ZTable/ZTable {

    use Applicative.{*>}
    use Basis/NIO/File.Path;


    pub def genZTableObj(obj: {obj :: Path}, dest: {dest :: Path}): Result[Unit, String] \ IO = region r {
        BasicDb/DbMonad.runSQLite(r, AssetLib/ZTable/SQLite.readAndStoreObjTypeManufacturer(obj.obj), dest.dest)
    }       


    pub def genZTableManuf(manuf: {manuf :: Path}, dest: {dest :: Path}): Result[Unit, String] \ IO = region r {
        BasicDb/DbMonad.runSQLite(r, AssetLib/ZTable/SQLite.readAndStoreManufacturerModel(manuf.manuf), dest.dest)
    }      


    pub def genZTableFloobjl(floobjl: {floobjl :: Path}, dest: {dest :: Path}): Result[Unit, String] \ IO = region r {
        BasicDb/DbMonad.runSQLite(r, AssetLib/ZTable/SQLite.readAndStoreFlocObject(floobjl.floobjl), dest.dest)
    }     
}

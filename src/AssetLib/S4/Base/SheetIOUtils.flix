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


namespace AssetLib/S4/Base/SheetIOUtils {


    use SheetIO.RowSetter;


    pub def putS4DateAt!(ix: Int32, dt: Time.LocalDate): RowSetter[Unit] = 
        use SheetIO/RowSetter.{flatMap, return, putStringAt!, liftActionResult};
        let* s = liftActionResult(_ -> AutoLifting/Common/Utils.formatDateForS4(dt) as & Impure);
        putStringAt!(ix, s)



}    
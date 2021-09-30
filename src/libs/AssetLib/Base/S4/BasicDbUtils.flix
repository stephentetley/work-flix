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


namespace AssetLib/Base/S4/BasicDbUtils {


    use BasicDb.DbMonad;
    use BasicDb.PreparedStatementSetter;
    use BasicDb.RowEvaluator;

    pub def putS4DateAt!(ix: Int32, dt: Time.LocalDate): PreparedStatementSetter[Unit] = 
        use BasicDb/PreparedStatementSetter.{flatMap, return, liftOption, putStringAt!};
        let* fmt    = liftOption(Time/Format/DateFormatter.ofPattern("dd.MM.yyyy"), "putS4DateAt!");
        let ans     = Time/LocalDate.format(fmt, dt);
        let* _      = putStringAt!(ix, ans);
        return()

     pub def getS4DateNamed(label: String): RowEvaluator[Time.LocalDate] = 
        use BasicDb/RowEvaluator.{flatMap, return, liftOption, getStringNamed};
        let* fmt    = liftOption(Time/Format/DateFormatter.ofPattern("dd.MM.yyyy"), "getS4DateNamed");
        let* s1     = getStringNamed(label); 
        let* ans    = liftOption(Time/LocalDate.parse(fmt, s1), "getS4DateNamed('${label}')");
        return(ans)


}    
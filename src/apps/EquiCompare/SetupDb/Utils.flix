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

/// This is almost common to Outstations and Ultrasonics. `P AND I Tag` is not available to Outstations

namespace EquiCompare/SetupDb/Utils {

    pub def getSheetIOLocalDateNamed(label: String): SheetIO.NamedRowEvaluator[Time.LocalDate] = 
        use SheetIO/NamedRowEvaluator.{map, getLocalDateTimeNamed};
        map(Time/LocalDateTime.toLocalDate,  getLocalDateTimeNamed(label))



    pub def putPreparedStatementDateAt!(ix: Int32, dt: Time.LocalDate): BasicDb.PreparedStatementSetter[Unit] = 
        use BasicDb/PreparedStatementSetter.{flatMap, return, liftOption, putStringAt!};
        let* fmt    = liftOption(Time/Format/DateFormatter.fromPattern("yyyy-MM-dd"), "putPreparedStatementDateAt!(${ix})");
        let ans     = Time/LocalDate.format(dt, fmt);
        let* _      = putStringAt!(ix, ans);
        return()


}

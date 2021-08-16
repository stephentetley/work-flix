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


namespace AssetLib/S4Lite/Utils {

    /// 9-digit
    pub def getStartUid(): Int32 & Impure = 
        let dt = Time/LocalDateTime.now();
        let x1  = Time/LocalDateTime.getMonthValue(dt) * 1000000;
        let x2  = Time/LocalDateTime.getDayOfMonth(dt) * 10000;
        let x3  = Time/LocalDateTime.getHour(dt) * 100;
        let x4  = Time/LocalDateTime.getMinute(dt);
        200000000 + x1 + x2 + x3 + x4

}

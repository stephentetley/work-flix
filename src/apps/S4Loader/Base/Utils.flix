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


namespace S4Loader/Base/Utils {

        

    /// Tolerant equals...
    pub def tEqual(threshold: Float64, x: Float64, y: Float64): Bool = 
        abs(x - y) < threshold

    pub def abs(x: Float64): Float64 = 
        import static java.lang.Math.abs(Float64);
        abs(x) as & Pure

    /// Call this only from Datalog...
    pub def isWholeFloat(x: Float64): Bool = 
        let x1 = Float64.round(x);
        tEqual(0.01f64, x, x1)

    /// This should only be called after `isWholeFloat` because otherwise we won't know whether
    /// `-1` is a valid answer or the out-of-band signal.
    pub def wholeFloat(x: Float64): Int32 = 
        let x1 = Float64.round(x);
        if (tEqual(0.01f64, x, x1))
            Float64.tryToInt32(x1) |> Option.getWithDefault(-1)
        else 
            -1

    pub def isIntValue(s: String): Bool = 
        Int32.fromString(s) |> Result.isOk

    pub def intValue(s: String): Int32 = 
        Int32.fromString(s) |> Result.getWithDefault(-1)

    pub def isFloatValue(s: String): Bool = 
        Float64.fromString(s) |> Result.isOk

    /// Should only be called after `isFloatValue` has confirmed it is okay to parse
    pub def floatValue(s: String): Float64 = 
        Float64.fromString(s) |> Result.getWithDefault(-1.0f64)

    // Stored as string e.g. "2020-03-31T16:28:56"
    pub def isIsoLocalDateTimeValue(s: String): Bool = 
        let fmt = Time/Format/DateTimeFormatter.iso_local_date_time();
        match Time/LocalDateTime.parse(fmt, s) {
            case Some(_) => true
            case None    => false
        }

    /// Should only be called after `isIsoLocalDateTimeValue` has confirmed it is okay to parse
    pub def dateFromIsoLocalDateTime(s: String): Time.LocalDate = 
        let fmt = Time/Format/DateTimeFormatter.iso_local_date_time();
        Time/LocalDateTime.parse(fmt, s) 
            |> Option.map(Time/LocalDateTime.toLocalDate)
            |> Option.getWithDefault(fallbackDate())

    /// Should only be called after `isIsoLocalDateTimeValue` has confirmed it is okay to parse
    pub def dateStringFromIsoLocalDateTime(s: String): String = 
        let fmt = Time/Format/DateFormatter.iso_local_date();
        dateFromIsoLocalDateTime(s) 
            |> Time/LocalDate.format(fmt)

    // Stored as string e.g. "4/29/21 17:47"
    pub def excelDate(s: String): Option[Time.LocalDate] =
        use Option.flatMap;
        let* fmt    = Time/Format/DateTimeFormatter.ofPattern("M/d/yy H:m");
        let* dt     = Time/LocalDateTime.parse(fmt, s);
        Some(Time/LocalDateTime.toLocalDate(dt))

    pub def fallbackDate(): Time.LocalDate = 
        Time/LocalDate.new({year=1970, month=1, dayOfMonth=1})

}

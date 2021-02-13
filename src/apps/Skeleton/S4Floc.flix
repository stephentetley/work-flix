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


namespace Skeleton {

    pub opaque type S4Floc = List[String]

    instance Eq[S4Floc] {
        def eq(x: S4Floc, y: S4Floc): Bool = Skeleton/S4Floc.equals(x, y)

        def neq(x: S4Floc, y: S4Floc): Bool = not (x == y)
    }

    instance ToString[S4Floc] {
        def toString(x: S4Floc): String = Skeleton/S4Floc.toString(x)
    }

    instance Hash[S4Floc] {
        def hash(x: S4Floc): Int32 = Hash.hash(Skeleton/S4Floc.toString(x))
    }

}    

namespace Skeleton/S4Floc {

    use BasicDb.DbMonad;

    use Skeleton.S4Floc;
    use Skeleton.S4Floc.{S4Floc};

    pub def new(s: String): S4Floc = S4Floc(String.splitOn(s, "-"))

    pub def equals(x: S4Floc, y: S4Floc): Bool = toString(x) == toString(y)

    pub def toString(x: S4Floc): String = 
        let S4Floc(xs) = x;
        String.intercalate("-", xs)

    /// level
    pub def level(x: S4Floc): Int32 = 
        let S4Floc(xs) = x;
        List.length(xs)



    /// parent
    pub def parent(x: S4Floc): Option[S4Floc] = 
        let S4Floc(xs) = x;
        List.init(xs) |> Option.map(S4Floc)

    pub def objectType(x: S4Floc): String = 
        let S4Floc(xs) = x;
        List.last(xs) |> ans -> Option.getWithDefault(ans, "")


    pub def getDescription(x: S4Floc): DbMonad[String] = 
        use BasicDb/DbMonad.{flatMap, return, psExecuteCachedQuery, firstRow, rsClose, alt};
        use BasicDb/PreparedStatementSetter.{putStringAt!};
        let* rs     = psExecuteCachedQuery("GetS4FlocDescription", putStringAt!(0, objectType(x)));
        let* x1     = firstRow(rs, BasicDb/RowEvaluator.getStringNamed("description")) `alt` return("");
        let* _      = rsClose(rs);
        return(x1)


    pub def cacheGetDescriptionQuery(): DbMonad[Unit] = 
        let sql = String.unlines(
               "SELECT"
            :: "    max(t1.int_counter_value) AS description"
            :: "FROM ztable_flocdes t1"
            :: "WHERE "
            :: "    t1.object_type= ?"
            :: Nil
        );
        BasicDb/DbMonad.cachePreparedStatement("GetS4FlocDescription", sql)


}    
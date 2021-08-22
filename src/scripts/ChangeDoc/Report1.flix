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


namespace ChangeDoc/Report1 {
    
    use SheetIO.RowSetter;

    use ChangeDoc/Relations.{Funcloc, Equipment, Attribute};

    type alias FlocRow = 
        { internalFloc: String
        , functionalLocation: String
        , description: String
        , attributes: Map[String, String]
        }

    type alias EquiRow = 
        { equiId: String
        , description: String
        , attributes: Map[String, String]
        }




    pub def buildFlocRows(db: #{Funcloc, Attribute | r}): List[FlocRow] & Impure = 
        let xs      = query db select (x1, x2, x3) from Funcloc(x1, x2, x3) |> Array.toList |> List.map(makeFlocRow1);
        let attrs   = makeAttributes(db);
        let updateAttrs = row -> match Map.get(row.internalFloc, attrs) { 
            case None => row
            case Some(attrs1) => {attributes = attrs1 | row}
        };
        List.map(updateAttrs, xs)
            |> List.sortBy(x1 -> x1.internalFloc)
        
    def makeFlocRow1(x: (String, String, String)): {FlocRow} = 
        let (x1, x2, x3) = x;
        { internalFloc          = x1
        , functionalLocation    = x2
        , description           = x3
        , attributes            = Map.empty()
        }


    pub def buildEquiRows(db: #{Equipment, Attribute | r}): List[EquiRow] & Impure = 
        let xs      = query db select (x1, x2) from Equipment(x1, x2) |> Array.toList |> List.map(makeEquiRow1);
        let attrs   = makeAttributes(db);
        let updateAttrs = row -> match Map.get(row.equiId, attrs) { 
            case None => row
            case Some(attrs1) => {attributes = attrs1 | row}
        };
        List.map(updateAttrs, xs)
            |> List.sortBy(x1 -> x1.equiId)
        
    def makeEquiRow1(x: (String, String)): EquiRow = 
        let (x1, x2) = x;
        { equiId        = x1
        , description   = x2
        , attributes    = Map.empty()
        }

    /// TODO simpler to insert into Map-of-Maps...
    def makeAttributes(db: #{Attribute |r}): Map[String, Map[String, String]] & Impure = 
        let fst3 = xyz -> {let (x1, _, _) = xyz; x1};
        let makeGroup = ys -> match ys {
            case Nil => bug!("makeAttributes - unlikely...")
            case yyy :: rs => { 
                let (y1, y2, y3) = yyy;
                let ac1 = Map.singleton(y2, y3);
                (y1, List.foldLeft((ac, zzz) -> {let (_, z2, z3) = zzz; Map.insert(z2, z3, ac)}, ac1, rs))
            }
        };
        query db select (x1, x2, x3) from Attribute(x1, x2, x3) 
            |> Array.toList 
            |> List.groupBy((x1, y1) -> fst3(x1) == fst3(y1))
            |> List.map(makeGroup)
            |> List.toMap


    pub def setFlocRow(x: FlocRow): RowSetter[Unit] = 
        use SheetIO/RowSetter.{flatMap, return, putStringAt!, putOptionStringAt!};
        let* _      = putStringAt!(0, x.internalFloc);
        let* _      = putStringAt!(1, x.functionalLocation);
        let* _      = putStringAt!(2, x.description);
        let* _      = putStringAt!(3, getAttr("Cost Center", x.attributes));
        let* _      = putStringAt!(3, getAttr("Installation allowed", x.attributes));
        return()


    pub def flocRowToString(x: FlocRow): String = 
        useStringBuilder(sb -> {
            StringBuilder.appendString!(sb, x.internalFloc + " ");
            StringBuilder.appendString!(sb, x.functionalLocation + " ");
            StringBuilder.appendString!(sb, x.description + " ");
            StringBuilder.appendString!(sb, getAttr("Cost Center", x.attributes) + " ");
            StringBuilder.appendString!(sb, getAttr("Installation allowed", x.attributes) + " ");
            StringBuilder.appendString!(sb, getAttr("Start-up date", x.attributes) + " ")

        })

    pub def equiRowToString(x: EquiRow): String = 
        useStringBuilder(sb -> {
            StringBuilder.appendString!(sb, x.equiId + " ");
            StringBuilder.appendString!(sb, x.description + " ");
            StringBuilder.appendString!(sb, getAttr("Cost Center", x.attributes) + " ");
            StringBuilder.appendString!(sb, getAttr("Manufacturer", x.attributes) + " ");
            StringBuilder.appendString!(sb, getAttr("Start-up date", x.attributes) + " ")

        })

    def useStringBuilder(f: StringBuilder ~> Unit): String = 
        useStringBuilderHelper(f) as & Pure

    def useStringBuilderHelper(f: StringBuilder ~> Unit): String & Impure = 
        let sb = StringBuilder.new();
        f(sb);
        StringBuilder.toString(sb)

        

    def getAttr(name: String, attrs: Map[String, String]): String = 
        Map.getWithDefault(name, "", attrs)

}
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

    use ChangeDoc/Relations.{Funcloc, Equipment, EquiLongText, 
        ClassFloc, ClassEqui, ValuaFloc, ValuaEqui, Attribute};
    
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

    type alias EquiLongTextRow =         
        { equiId: String
        , description: String
        , longText: String
        }

    type alias ClassFlocRow = 
        { internalFloc: String
        , name: String
        }

    type alias ClassEquiRow = 
        { equiId: String
        , name: String
        }

    type alias ValuaFlocRow = 
        { internalFloc: String
        , name: String
        , intCounter: Int32
        , value: String
        }

    type alias ValuaEquiRow = 
        { equiId: String
        , name: String
        , intCounter: Int32
        , value: String
        }


    /// Note - qjbrowser / TyRuBa-JQuery build relations differently - they build a single big
    /// jointable then recover the hierarchy with an organization criteria.
    /// 
    /// Currently (at least) we are building multiple tables of relations.



    /// ## Floc

    pub def buildFlocRows(db: #{Funcloc, Attribute | r}): Array[FlocRow] & Impure = 
        let attrs = makeAttributes(db);
        let updateAttrs = (row, attrs1) -> {attributes = attrs1 | row};
        query db select (x1, x2, x3) from Funcloc(x1, x2, x3)
            |> Array.map(makeFlocRow1)
            |> Relation/Organization.updateWithLookup(x1 -> x1.internalFloc, updateAttrs, attrs)


    def makeFlocRow1(x: (String, String, String)): FlocRow = 
        let (x1, x2, x3) = x;
        { internalFloc          = x1
        , functionalLocation    = x2
        , description           = x3
        , attributes            = Map.empty()
        }

    pub def writeFlocRows(path: System.FilePath, arr: Array[FlocRow]): Result[Unit, String] & Impure = 
        let writer = {sheetName = "Floc",
            headers = Some(["Int. Functional Location", "Functional Location", "Description", 
                "ABC indic. origin", "Address origin", "Asset no. origin", "AuthGroup origin", 
                "Business area orig.", "Company Code", "CompCode origin", 
                "ControlArea origin", "Controlling Area", "Cost Center", "Cost center origin", 
                "EquipInst. origin", "FunctLocCategory", "Installation allowed", "Location origin", 
                "MaintCatalog origin", "Maintenance Plant", "MaintPlant origin", "MaintPlGroup origin", 
                "Object Type", "Planning Plant", "Plant plant origin", "Plant Section Origin", 
                "PP WrkCenter origin", "Room number origin", "SalesOrg. origin", "SettlemntOrderOrigin", 
                "StandingOrderOrigin", "Start-up date", "Status of an object", "Structure indicator", 
                "Superior FL for CR Processing", "Superior FunctLoc.", "Valid To", 
                "WBS element origin", "Work Center", "Work center origin"
                ]),
            setter = setFlocRow,
            rows = Array.toList(arr)
        };
        SheetIO/Writer.writeWorkSheet(writer, path)

    def setFlocRow(x: FlocRow): RowSetter[Unit] = 
        use SheetIO/RowSetter.{flatMap, return, putStringAt! => putString!};
        use SheetIO/RowSetter.{*>};
            startingAt(0)
        ++> flip(putString!, x.internalFloc)
        ++> flip(putString!, x.functionalLocation)
        ++> flip(putString!, x.description)
        ++> flip(putString!, getAttr("ABC indic. origin", x.attributes))
        ++> flip(putString!, getAttr("Address origin", x.attributes))
        ++> flip(putString!, getAttr("Asset no. origin", x.attributes))
        ++> flip(putString!, getAttr("AuthGroup origin", x.attributes))
        ++> flip(putString!, getAttr("Business area orig.", x.attributes))
        ++> flip(putString!, getAttr("Company Code", x.attributes))
        ++> flip(putString!, getAttr("CompCode origin", x.attributes))
        ++> flip(putString!, getAttr("ControlArea origin", x.attributes))
        ++> flip(putString!, getAttr("Controlling Area", x.attributes))
        ++> flip(putString!, getAttr("Cost Center", x.attributes))
        ++> flip(putString!, getAttr("Cost center origin", x.attributes))
        ++> flip(putString!, getAttr("EquipInst. origin", x.attributes))
        ++> flip(putString!, getAttr("FunctLocCategory", x.attributes))
        ++> flip(putString!, getAttr("Installation allowed", x.attributes))
        ++> flip(putString!, getAttr("Location origin", x.attributes))
        ++> flip(putString!, getAttr("MaintCatalog origin", x.attributes))
        ++> flip(putString!, getAttr("Maintenance Plant", x.attributes))
        ++> flip(putString!, getAttr("MaintPlant origin", x.attributes))
        ++> flip(putString!, getAttr("MaintPlGroup origin", x.attributes))
        ++> flip(putString!, getAttr("Object Type", x.attributes))
        ++> flip(putString!, getAttr("Planning Plant", x.attributes))
        ++> flip(putString!, getAttr("Plant plant origin", x.attributes))
        ++> flip(putString!, getAttr("Plant Section Origin", x.attributes))
        ++> flip(putString!, getAttr("PP WrkCenter origin", x.attributes))
        ++> flip(putString!, getAttr("Room number origin", x.attributes))
        ++> flip(putString!, getAttr("SalesOrg. origin", x.attributes))
        ++> flip(putString!, getAttr("SettlemntOrderOrigin", x.attributes))
        ++> flip(putString!, getAttr("StandingOrderOrigin", x.attributes))
        ++> flip(putString!, getAttr("Start-up date", x.attributes))
        ++> flip(putString!, getAttr("Status of an object", x.attributes))
        ++> flip(putString!, getAttr("Structure indicator", x.attributes))
        ++> flip(putString!, getAttr("Superior FL for CR Processing", x.attributes))
        ++> flip(putString!, getAttr("Superior FunctLoc.", x.attributes))
        ++> flip(putString!, getAttr("Valid To", x.attributes))
        ++> flip(putString!, getAttr("WBS element origin", x.attributes))
        ++> flip(putString!, getAttr("Work Center", x.attributes))
        ++> flip(putString!, getAttr("Work center origin", x.attributes))
        *> return()


    /// ## Equi

    pub def extractEquiLongTextRows(db: #{EquiLongText | r}): Array[EquiLongTextRow] & Impure = 
        query db select (x1, x2, x3) from EquiLongText(x1, x2, x3) 
            |> Array.map(makeEquiLongTextRow1)


    def makeEquiLongTextRow1(x: (String, String, String)): EquiLongTextRow = 
        let (x1, x2, x3) = x;
        { equiId        = x1
        , description   = x2
        , longText      = x3
        }

    pub def buildEquiRows(db: #{Equipment, Attribute | r}): Array[EquiRow] & Impure = 
        let attrs = makeAttributes(db);
        let updateAttrs = (row, attrs1) -> {attributes = attrs1 | row};
        query db select (x1, x2) from Equipment(x1, x2) 
            |> Array.map(makeEquiRow1)
            |> Relation/Organization.updateWithLookup(x1 -> x1.equiId, updateAttrs, attrs)


    def makeEquiRow1(x: (String, String)): EquiRow = 
        let (x1, x2) = x;
        { equiId        = x1
        , description   = x2
        , attributes    = Map.empty()
        }

    pub def addEquiRows(path: System.FilePath, arr: Array[EquiRow]): Result[Unit, String] & Impure = 
        let writer = {sheetName = "Equi",
            headers = Some(["Equipment", "Description", 
                "ABC indic. origin", "ABC Indicator", "Address origin", "AuthGroup origin", 
                "Business area orig.", "Company Code", "CompCode origin", "Construction month", 
                "Construction year", "ControlArea origin", "Controlling Area", "Cost Center", 
                "Cost center origin", "Currency", "Equipment", "Equipment category", 
                "Functional Location", "FunctLoc. origin", "Inventory number", "Language Key", 
                "Location origin", "MaintCatalog origin", "Maintenance Plant", "MaintPlant origin", 
                "MaintPlGroup origin", "ManufactPartNo.", "Manufacturer", "ManufSerialNumber", 
                "Model number", "Object Type", "Planning Plant", "Plant plant origin", 
                "Plant Section Origin", "Position", "PP WrkCenter origin", "Room number origin", 
                "SalesOrg. origin", "SettlemntOrderOrigin", "Sort field origin", "StandingOrderOrigin", 
                "Start-up date", "Status of an object", "Superord. Equipment", "Technical IdentNo.", 
                "Unit of weight", "Valid From", "Valid To", "WBS element origin", 
                "Work Center"
                ]),
            setter = setEquiRow,
            rows = Array.toList(arr)
        };
        SheetIO/Writer.addWorkSheet(writer, path)


    def setEquiRow(x: EquiRow): RowSetter[Unit] = 
        use SheetIO/RowSetter.{flatMap, return, putStringAt! => putString!};
        use SheetIO/RowSetter.{*>};
            startingAt(0)
        ++> flip(putString!, x.equiId)
        ++> flip(putString!, x.description)
        ++> flip(putString!, getAttr("ABC indic. origin", x.attributes))
        ++> flip(putString!, getAttr("ABC Indicator", x.attributes))
        ++> flip(putString!, getAttr("Address origin", x.attributes))
        ++> flip(putString!, getAttr("AuthGroup origin", x.attributes))
        ++> flip(putString!, getAttr("Business area orig.", x.attributes))
        ++> flip(putString!, getAttr("Company Code", x.attributes))
        ++> flip(putString!, getAttr("CompCode origin", x.attributes))
        ++> flip(putString!, getAttr("Construction month", x.attributes))
        ++> flip(putString!, getAttr("Construction year", x.attributes))
        ++> flip(putString!, getAttr("ControlArea origin", x.attributes))
        ++> flip(putString!, getAttr("Controlling Area", x.attributes))
        ++> flip(putString!, getAttr("Cost Center", x.attributes))
        ++> flip(putString!, getAttr("Cost center origin", x.attributes))
        ++> flip(putString!, getAttr("Currency", x.attributes))
        ++> flip(putString!, getAttr("Equipment", x.attributes))
        ++> flip(putString!, getAttr("Equipment category", x.attributes))
        ++> flip(putString!, getAttr("Functional Location", x.attributes))
        ++> flip(putString!, getAttr("FunctLoc. origin", x.attributes))
        ++> flip(putString!, getAttr("Inventory number", x.attributes))
        ++> flip(putString!, getAttr("Language Key", x.attributes))
        ++> flip(putString!, getAttr("Location origin", x.attributes))
        ++> flip(putString!, getAttr("MaintCatalog origin", x.attributes))
        ++> flip(putString!, getAttr("Maintenance Plant", x.attributes))
        ++> flip(putString!, getAttr("MaintPlant origin", x.attributes))
        ++> flip(putString!, getAttr("MaintPlGroup origin", x.attributes))
        ++> flip(putString!, getAttr("ManufactPartNo.", x.attributes))
        ++> flip(putString!, getAttr("Manufacturer", x.attributes))
        ++> flip(putString!, getAttr("ManufSerialNumber", x.attributes))
        ++> flip(putString!, getAttr("Model number", x.attributes))
        ++> flip(putString!, getAttr("Object Type", x.attributes))
        ++> flip(putString!, getAttr("Planning Plant", x.attributes))
        ++> flip(putString!, getAttr("Plant plant origin", x.attributes))
        ++> flip(putString!, getAttr("Plant Section Origin", x.attributes))
        ++> flip(putString!, getAttr("Position", x.attributes))
        ++> flip(putString!, getAttr("PP WrkCenter origin", x.attributes))
        ++> flip(putString!, getAttr("Room number origin", x.attributes))
        ++> flip(putString!, getAttr("SalesOrg. origin", x.attributes))
        ++> flip(putString!, getAttr("SettlemntOrderOrigin", x.attributes))
        ++> flip(putString!, getAttr("Sort field origin", x.attributes))
        ++> flip(putString!, getAttr("StandingOrderOrigin", x.attributes))
        ++> flip(putString!, getAttr("Start-up date", x.attributes))
        ++> flip(putString!, getAttr("Status of an object", x.attributes))
        ++> flip(putString!, getAttr("Superord. Equipment", x.attributes))
        ++> flip(putString!, getAttr("Technical IdentNo.", x.attributes))
        ++> flip(putString!, getAttr("Unit of weight", x.attributes))
        ++> flip(putString!, getAttr("Valid From", x.attributes))
        ++> flip(putString!, getAttr("Valid To", x.attributes))
        ++> flip(putString!, getAttr("WBS element origin", x.attributes))
        ++> flip(putString!, getAttr("Work Center", x.attributes))
        *> return()

    /// ## Eqmltxt

    pub def addEquiLongTextRows(path: System.FilePath, arr: Array[EquiLongTextRow]): Result[Unit, String] & Impure = 
        let writer = {sheetName = "Eqmltext",
            headers = Some(["Equipment", "Description (medium text)", "Long Text"]),
            setter = setEquiLongTextRow,
            rows = Array.toList(arr)
        };
        SheetIO/Writer.addWorkSheet(writer, path)


    def setEquiLongTextRow(x: EquiLongTextRow): RowSetter[Unit] = 
        use SheetIO/RowSetter.{flatMap, return, putStringAt! => putString!};
        use SheetIO/RowSetter.{*>};
            startingAt(0)
        ++> flip(putString!, x.equiId)
        ++> flip(putString!, x.description)
        ++> flip(putString!, x.longText)
        *> return()


    /// ## Classfloc

    pub def extractClassFlocRows(db: #{ClassFloc | r}): Array[ClassFlocRow] & Impure = 
        query db select (x1, x2) from ClassFloc(x1, x2) 
            |> Array.map(makeClassFlocRow1)


    def makeClassFlocRow1(x: (String, String)): ClassFlocRow = 
        let (x1, x2) = x;
        { internalFloc  = x1
        , name          = x2
        }



    pub def addClassFlocRows(path: System.FilePath, arr: Array[ClassFlocRow]): Result[Unit, String] & Impure = 
        let writer = {sheetName = "Classfloc",
            headers = Some(["Int. Functional Location", "Name"]),
            setter = setClassFlocRow,
            rows = Array.toList(arr)
        };
        SheetIO/Writer.addWorkSheet(writer, path)


    def setClassFlocRow(x: ClassFlocRow): RowSetter[Unit] = 
        use SheetIO/RowSetter.{flatMap, return, putStringAt! => putString!};
        use SheetIO/RowSetter.{*>};
            startingAt(0)
        ++> flip(putString!, x.internalFloc)
        ++> flip(putString!, x.name)
        *> return()


    /// ## Classequi

    pub def extractClassEquiRows(db: #{ClassEqui | r}): Array[ClassEquiRow] & Impure = 
        query db select (x1, x2) from ClassEqui(x1, x2) 
            |> Array.map(makeClassEquiRow1)


    def makeClassEquiRow1(x: (String, String)): ClassEquiRow = 
        let (x1, x2) = x;
        { equiId        = x1
        , name          = x2
        }


    pub def addClassEquiRows(path: System.FilePath, arr: Array[ClassEquiRow]): Result[Unit, String] & Impure = 
        let writer = {sheetName = "Classequi",
            headers = Some(["Equipment", "Name"]),
            setter = setClassEquiRow,
            rows = Array.toList(arr)
        };
        SheetIO/Writer.addWorkSheet(writer, path)


    def setClassEquiRow(x: ClassEquiRow): RowSetter[Unit] = 
        use SheetIO/RowSetter.{flatMap, return, putStringAt! => putString!};
        use SheetIO/RowSetter.{*>};
            startingAt(0)
        ++> flip(putString!, x.equiId)
        ++> flip(putString!, x.name)
        *> return()


    pub def addValuaFlocRows(path: System.FilePath, arr: Array[ValuaFlocRow]): Result[Unit, String] & Impure = 
        let writer = {sheetName = "Valuafloc",
            headers = Some(["Int. Functional Location", "Name", "Int Counter", "Value"]),
            setter = setValuaFlocRow,
            rows = Array.toList(arr)
        };
        SheetIO/Writer.addWorkSheet(writer, path)

    /// ## Valuafloc

    pub def extractValuaFlocRows(db: #{ValuaFloc | r}): Array[ValuaFlocRow] & Impure = 
        query db select (x1, x2, x3, x4) from ValuaFloc(x1, x2, x3, x4) 
            |> Array.map(makeValuaFlocRow1)


    def makeValuaFlocRow1(x: (String, String, Int32, String)): ValuaFlocRow = 
        let (x1, x2, x3, x4) = x;
        { internalFloc  = x1
        , name          = x2
        , intCounter    = x3
        , value         = x4
        }


    def setValuaFlocRow(x: ValuaFlocRow): RowSetter[Unit] = 
        use SheetIO/RowSetter.{flatMap, return, putStringAt! => putString!, putInt32At! => putInt32!};
        use SheetIO/RowSetter.{*>};
            startingAt(0)
        ++> flip(putString!, x.internalFloc)
        ++> flip(putString!, x.name)
        ++> flip(putInt32!, x.intCounter)
        ++> flip(putString!, x.value)
        *> return()

    /// ## Valuaequi

    pub def extractValuaEquiRows(db: #{ValuaEqui | r}): Array[ValuaEquiRow] & Impure = 
        query db select (x1, x2, x3, x4) from ValuaEqui(x1, x2, x3, x4) 
            |> Array.map(makeValuaEquiRow1)


    def makeValuaEquiRow1(x: (String, String, Int32, String)): ValuaEquiRow = 
        let (x1, x2, x3, x4) = x;
        { equiId        = x1
        , name          = x2
        , intCounter    = x3
        , value         = x4
        }


    pub def addValuaEquiRows(path: System.FilePath, arr: Array[ValuaEquiRow]): Result[Unit, String] & Impure = 
        let writer = {sheetName = "Valuaequi",
            headers = Some(["Equipment", "Name", "Int Counter", "Value"]),
            setter = setValuaEquiRow,
            rows = Array.toList(arr)
        };
        SheetIO/Writer.addWorkSheet(writer, path)


    def setValuaEquiRow(x: ValuaEquiRow): RowSetter[Unit] = 
        use SheetIO/RowSetter.{flatMap, return, putStringAt! => putString!, putInt32At! => putInt32!};
        use SheetIO/RowSetter.{*>};
            startingAt(0)
        ++> flip(putString!, x.equiId)
        ++> flip(putString!, x.name)
        ++> flip(putInt32!, x.intCounter)
        ++> flip(putString!, x.value)
        *> return()

    /// Helpers

    def makeAttributes(db: #{Attribute |r}): Map[String, Map[String, String]] & Impure = 
        let key1of3 = xyz -> {let (x1, _, _) = xyz; x1};
        let innerKV = xyz -> {let (_, y1, z1) = xyz; (y1, z1)};
        query db select (x1, x2, x3) from Attribute(x1, x2, x3) 
            |> Relation/Organization.collectToMapMap(key1of3, innerKV)




    /// For SheetIO.RowSetter...

    def startingAt(i: Int32): RowSetter[Int32] = SheetIO/RowSetter.return(i)


    /// incrementing `bind`
    def ++>(mi: RowSetter[Int32], mx: Int32 -> RowSetter[b]): RowSetter[Int32] = 
        use SheetIO/RowSetter.{flatMap, return};
        let* ix = mi;
        let* _ = mx(ix);
        return(ix + 1)

    ///// 


    pub def flocRowToString(x: FlocRow): String = 
        useStringBuilder(sb -> {
            StringBuilder.appendString!(sb, x.internalFloc + " ");
            StringBuilder.appendString!(sb, x.functionalLocation + " ");
            StringBuilder.appendString!(sb, x.description + " ");
            StringBuilder.appendString!(sb, getAttr("Cost Center", x.attributes) + " ");
            StringBuilder.appendString!(sb, getAttr("Installation allowed", x.attributes) + " ");
            StringBuilder.appendString!(sb, getAttr("Start-up date", x.attributes) + " ")

        })



    /// Just a little experiment to see if we can make a convenient idiom for using StringBuilder
    /// flip(StringBuilder.appendString!, ...) is just noise - if Flix loses UFCS then
    /// appendString! might warrant a different arg order...
    ///
    pub def equiRowToString(x: EquiRow): String = 
        useStringBuilder(
                flip(StringBuilder.appendString!, x.equiId + " ")
            *>> flip(StringBuilder.appendString!, x.description + " ")
            *>> flip(StringBuilder.appendString!, getAttr("Cost Center", x.attributes) + " ")
            *>> flip(StringBuilder.appendString!, getAttr("Manufacturer", x.attributes) + " ")
            *>> flip(StringBuilder.appendString!, getAttr("Start-up date", x.attributes))
        )
            

    /// aka `seqR` for the function applicative
    pub def *>>(f: a -> b & ef1, g: a -> c & ef2, a: a): c & (ef1 and ef2) = 
        let _ = f(a);
        g(a)

    /// Alternative use `perform` rather than a new composition combinator...
    pub def equiRowToString2(x: EquiRow): String = 
        let appendString! = (s, sb) -> StringBuilder.appendString!(sb, s);
        useStringBuilder(
               perform(appendString!(x.equiId))
            >> perform(appendString!(" " + x.description))
            >> perform(appendString!(" " + getAttr("Cost Center", x.attributes)))
            >> perform(appendString!(" " + getAttr("Manufacturer", x.attributes)))
            >> perform(appendString!(" " + getAttr("Start-up date", x.attributes)))
            >> constant()
        )

    def perform(f: a -> b & ef, x: a): a & ef = 
        let _ = f(x);
        x


    def useStringBuilder(f: StringBuilder ~> Unit): String = 
        useStringBuilderHelper(f) as & Pure

    def useStringBuilderHelper(f: StringBuilder ~> Unit): String & Impure = 
        let sb = StringBuilder.new();
        f(sb);
        StringBuilder.toString(sb)

        

    def getAttr(name: String, attrs: Map[String, String]): String = 
        Map.getWithDefault(name, "", attrs)

}
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

    /// Note - qjbrowser / TyRuBa-JQuery build relations differently - they build a single big
    /// jointable then recover the hierarchy with an organization criteria.
    /// 
    /// Currently (at least) we are building multiple tables of relations.


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


    def makeAttributes(db: #{Attribute |r}): Map[String, Map[String, String]] & Impure = 
        let key1of3 = xyz -> {let (x1, _, _) = xyz; x1};
        let innerKV = xyz -> {let (_, y1, z1) = xyz; (y1, z1)};
        query db select (x1, x2, x3) from Attribute(x1, x2, x3) 
            |> Relation/Organization.collectToMapMap(key1of3, innerKV)

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

    pub def setFlocRow(x: FlocRow): RowSetter[Unit] = 
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


    pub def setEquiRow(x: EquiRow): RowSetter[Unit] = 
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

    def startingAt(i: Int32): RowSetter[Int32] = SheetIO/RowSetter.return(i)


    /// incrementing `bind`
    def ++>(mi: RowSetter[Int32], mx: Int32 -> RowSetter[b]): RowSetter[Int32] = 
        use SheetIO/RowSetter.{flatMap, return};
        let* ix = mi;
        let* _ = mx(ix);
        return(ix + 1)

    pub def setEquiRow2(x: EquiRow): RowSetter[Unit] = 
        use SheetIO/RowSetter.{flatMap, return, putStringAt! => putString!};
        use SheetIO/RowSetter.{*>};
            startingAt(0)
        ++> flip(putString!, x.equiId)
        ++> flip(putString!, x.description)
        ++> flip(putString!, getAttr("ABC indic. origin", x.attributes))
        ++> flip(putString!, getAttr("ABC Indicator", x.attributes))
        *> return()



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
    /// appendString! should have a different arg order...
    ///
    pub def equiRowToString(x: EquiRow): String = 
        (flip(StringBuilder.appendString!, x.equiId + " ")
            *>> flip(StringBuilder.appendString!, x.description + " ")
            *>> flip(StringBuilder.appendString!, getAttr("Cost Center", x.attributes) + " ")
            *>> flip(StringBuilder.appendString!, getAttr("Manufacturer", x.attributes) + " ")
            *>> flip(StringBuilder.appendString!, getAttr("Start-up date", x.attributes))
            )
            |> useStringBuilder
            

    /// aka `seqR` for functions
    pub def *>>(f: a -> b & ef1, g: a -> c & ef2, a: a): c & (ef1 and ef2) = 
        let _ = f(a);
        g(a)


    def useStringBuilder(f: StringBuilder ~> Unit): String = 
        useStringBuilderHelper(f) as & Pure

    def useStringBuilderHelper(f: StringBuilder ~> Unit): String & Impure = 
        let sb = StringBuilder.new();
        f(sb);
        StringBuilder.toString(sb)

        

    def getAttr(name: String, attrs: Map[String, String]): String = 
        Map.getWithDefault(name, "", attrs)

}
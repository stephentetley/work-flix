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
        use SheetIO/RowSetter.{flatMap, return, putStringAt!};
        use SheetIO/RowSetter.{*>};
            putStringAt!(0, x.internalFloc)
        *> putStringAt!(1, x.functionalLocation)
        *> putStringAt!(2, x.description)
        *> putStringAt!(3, getAttr("ABC indic. origin", x.attributes))
        *> putStringAt!(4, getAttr("Address origin", x.attributes))
        *> putStringAt!(5, getAttr("Asset no. origin", x.attributes))
        *> putStringAt!(6, getAttr("AuthGroup origin", x.attributes))
        *> putStringAt!(7, getAttr("Business area orig.", x.attributes))
        *> putStringAt!(8, getAttr("Company Code", x.attributes))
        *> putStringAt!(9, getAttr("CompCode origin", x.attributes))
        *> putStringAt!(10, getAttr("ControlArea origin", x.attributes))
        *> putStringAt!(11, getAttr("Controlling Area", x.attributes))
        *> putStringAt!(12, getAttr("Cost Center", x.attributes))
        *> putStringAt!(13, getAttr("Cost center origin", x.attributes))
        *> putStringAt!(14, getAttr("EquipInst. origin", x.attributes))
        *> putStringAt!(15, getAttr("FunctLocCategory", x.attributes))
        *> putStringAt!(16, getAttr("Installation allowed", x.attributes))
        *> putStringAt!(17, getAttr("Location origin", x.attributes))
        *> putStringAt!(18, getAttr("MaintCatalog origin", x.attributes))
        *> putStringAt!(19, getAttr("Maintenance Plant", x.attributes))
        *> putStringAt!(20, getAttr("MaintPlant origin", x.attributes))
        *> putStringAt!(21, getAttr("MaintPlGroup origin", x.attributes))
        *> putStringAt!(22, getAttr("Object Type", x.attributes))
        *> putStringAt!(23, getAttr("Planning Plant", x.attributes))
        *> putStringAt!(24, getAttr("Plant plant origin", x.attributes))
        *> putStringAt!(25, getAttr("Plant Section Origin", x.attributes))
        *> putStringAt!(26, getAttr("PP WrkCenter origin", x.attributes))
        *> putStringAt!(27, getAttr("Room number origin", x.attributes))
        *> putStringAt!(28, getAttr("SalesOrg. origin", x.attributes))
        *> putStringAt!(29, getAttr("SettlemntOrderOrigin", x.attributes))
        *> putStringAt!(30, getAttr("StandingOrderOrigin", x.attributes))
        *> putStringAt!(31, getAttr("Start-up date", x.attributes))
        *> putStringAt!(32, getAttr("Status of an object", x.attributes))
        *> putStringAt!(33, getAttr("Structure indicator", x.attributes))
        *> putStringAt!(34, getAttr("Superior FL for CR Processing", x.attributes))
        *> putStringAt!(35, getAttr("Superior FunctLoc.", x.attributes))
        *> putStringAt!(36, getAttr("Valid To", x.attributes))
        *> putStringAt!(37, getAttr("WBS element origin", x.attributes))
        *> putStringAt!(38, getAttr("Work Center", x.attributes))
        *> putStringAt!(39, getAttr("Work center origin", x.attributes))


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
        use SheetIO/RowSetter.{flatMap, return, putStringAt!};
        use SheetIO/RowSetter.{*>};
            putStringAt!(0, x.equiId)
        *> putStringAt!(1, x.description)
        *> putStringAt!(2, getAttr("ABC indic. origin", x.attributes))
        *> putStringAt!(3, getAttr("ABC indic. origin", x.attributes))
        *> putStringAt!(4, getAttr("ABC Indicator", x.attributes))
        *> putStringAt!(5, getAttr("Address origin", x.attributes))
        *> putStringAt!(6, getAttr("AuthGroup origin", x.attributes))
        *> putStringAt!(7, getAttr("Business area orig.", x.attributes))
        *> putStringAt!(8, getAttr("Company Code", x.attributes))
        *> putStringAt!(9, getAttr("CompCode origin", x.attributes))
        *> putStringAt!(10, getAttr("Construction month", x.attributes))
        *> putStringAt!(11, getAttr("Construction year", x.attributes))
        *> putStringAt!(12, getAttr("ControlArea origin", x.attributes))
        *> putStringAt!(13, getAttr("Controlling Area", x.attributes))
        *> putStringAt!(14, getAttr("Cost Center", x.attributes))
        *> putStringAt!(15, getAttr("Cost center origin", x.attributes))
        *> putStringAt!(16, getAttr("Currency", x.attributes))
        *> putStringAt!(17, getAttr("Equipment", x.attributes))
        *> putStringAt!(18, getAttr("Equipment category", x.attributes))
        *> putStringAt!(19, getAttr("Functional Location", x.attributes))
        *> putStringAt!(20, getAttr("FunctLoc. origin", x.attributes))
        *> putStringAt!(21, getAttr("Inventory number", x.attributes))
        *> putStringAt!(22, getAttr("Language Key", x.attributes))
        *> putStringAt!(23, getAttr("Location origin", x.attributes))
        *> putStringAt!(24, getAttr("MaintCatalog origin", x.attributes))
        *> putStringAt!(25, getAttr("Maintenance Plant", x.attributes))
        *> putStringAt!(26, getAttr("MaintPlant origin", x.attributes))
        *> putStringAt!(27, getAttr("MaintPlGroup origin", x.attributes))
        *> putStringAt!(28, getAttr("ManufactPartNo.", x.attributes))
        *> putStringAt!(29, getAttr("Manufacturer", x.attributes))
        *> putStringAt!(30, getAttr("ManufSerialNumber", x.attributes))
        *> putStringAt!(31, getAttr("Model number", x.attributes))
        *> putStringAt!(32, getAttr("Object Type", x.attributes))
        *> putStringAt!(33, getAttr("Planning Plant", x.attributes))
        *> putStringAt!(34, getAttr("Plant plant origin", x.attributes))
        *> putStringAt!(35, getAttr("Plant Section Origin", x.attributes))
        *> putStringAt!(36, getAttr("Position", x.attributes))
        *> putStringAt!(37, getAttr("PP WrkCenter origin", x.attributes))
        *> putStringAt!(38, getAttr("Room number origin", x.attributes))
        *> putStringAt!(39, getAttr("SalesOrg. origin", x.attributes))
        *> putStringAt!(40, getAttr("SettlemntOrderOrigin", x.attributes))
        *> putStringAt!(41, getAttr("Sort field origin", x.attributes))
        *> putStringAt!(42, getAttr("StandingOrderOrigin", x.attributes))
        *> putStringAt!(43, getAttr("Start-up date", x.attributes))
        *> putStringAt!(44, getAttr("Status of an object", x.attributes))
        *> putStringAt!(45, getAttr("Superord. Equipment", x.attributes))
        *> putStringAt!(46, getAttr("Technical IdentNo.", x.attributes))
        *> putStringAt!(47, getAttr("Unit of weight", x.attributes))
        *> putStringAt!(48, getAttr("Valid From", x.attributes))
        *> putStringAt!(49, getAttr("Valid To", x.attributes))
        *> putStringAt!(50, getAttr("WBS element origin", x.attributes))
        *> putStringAt!(51, getAttr("Work Center", x.attributes))



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
            

    /// aka `seqR`
    pub def *>>(f: a -> b & ef, g: a -> c & ef, a: a): c & ef = 
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
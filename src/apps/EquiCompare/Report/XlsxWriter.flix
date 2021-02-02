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

namespace EquiCompare/Report/XlsxWriter {
    
    use SheetIO.RowSetter;
    use SheetIO.SheetWriter;
    use EquiCompare/Report/Compare.{Synced, NotMigrated, Orphaned};
    
    
    pub def writeReport[r](db: #{Synced, NotMigrated, Orphaned | r}, outpath: System.FilePath): Result[Unit, String] & Impure = 
        use SheetIO/SheetWriter.{seqRight};
        let synced1 = fold Synced Chain.empty() buildSynced1ChainStep db;
        let notMigrated1 = fold NotMigrated Chain.empty() buildNotMigrated1ChainStep db;
        let orphaned1 = fold Orphaned Chain.empty() buildOrphaned1ChainStep db;
        SheetIO/SheetWriter.runXssf( seqRight(writeSynced1Sheet(synced1), 
                                        seqRight(writeNotMigrated1Sheet(notMigrated1), 
                                                    writeOrphaned1Sheet(orphaned1)))
                                   , outpath)
        

    /// Synced
    type alias Synced1 = 
        { pliReference: String
        , s4EquiId: String
        , commonName: String
        , description: String
        }

    pub def writeSynced1Sheet(rows: Chain[Synced1]): SheetWriter[Unit] = 
        use SheetIO/SheetWriter.{flatMap, return, createSheet, liftAction, mapX, appendRow};
        let* s1         = createSheet("Synced");
        let* headers    = liftAction(_ -> ["PLI Reference", "S4 Equipment", "Common Name", "Description"]);
        let* _          = appendRow(s1, SheetIO/RowSetter.putHeaders!(headers));
        let* _          = mapX(r -> appendRow(s1, setSynced1Row!(r)), Chain.toList(rows));
        return()


    def setSynced1Row!(x: Synced1): RowSetter[Unit] = 
        use SheetIO/RowSetter.{flatMap, return, putStringAt!};
        let* _      = putStringAt!(0, x.pliReference);
        let* _      = putStringAt!(1, x.s4EquiId);
        let* _      = putStringAt!(2, x.commonName);
        let* _      = putStringAt!(3, x.description);
        return()

    def makeSynced1(x: (String, String, String, String)): Synced1 = 
        let (x1, x2, x3, x4) = x;
        { pliReference  = x1
        , s4EquiId      = x2
        , commonName    = x3
        , description   = x4
        }

    /// fold step for the fixpoint, has to be pure
    def buildSynced1ChainStep(x: (String, String, String, String), ac: Chain[Synced1]): Chain[Synced1] = 
        Chain.snoc(ac, makeSynced1(x))

    /// NotMigrated
    type alias NotMigrated1  = 
        { pliReference: String
        , site: String
        , commonName: String
        }

    def writeNotMigrated1Sheet(rows: Chain[NotMigrated1]): SheetWriter[Unit] = 
        use SheetIO/SheetWriter.{flatMap, return, createSheet, liftAction, mapX, appendRow};
        let* s1         = createSheet("Not_Migrated");
        let* headers    = liftAction(_ -> ["PLI Reference", "Site", "Common Name"]);
        let* _          = appendRow(s1, SheetIO/RowSetter.putHeaders!(headers));
        let* _          = mapX(r -> appendRow(s1, setNotMigrated1Row!(r)), Chain.toList(rows));
        return()


    def setNotMigrated1Row!(x: NotMigrated1): RowSetter[Unit] = 
        use SheetIO/RowSetter.{flatMap, return, putStringAt!};
        let* _      = putStringAt!(0, x.pliReference);
        let* _      = putStringAt!(1, x.site);
        let* _      = putStringAt!(2, x.commonName);
        return()

    def makeNotMigrated1(x: (String, String, String)): NotMigrated1 = 
        let (x1, x2, x3) = x;
        { pliReference  = x1
        , site          = x2
        , commonName    = x3
        }

    /// fold step for the fixpoint, has to be pure
    def buildNotMigrated1ChainStep(x: (String, String, String), ac: Chain[NotMigrated1]): Chain[NotMigrated1] = 
        Chain.snoc(ac, makeNotMigrated1(x))

    /// Orphaned
    type alias Orphaned1 = 
        { s4EquiId: String
        , site: String
        , description: String
        }

    def writeOrphaned1Sheet(rows: Chain[Orphaned1]): SheetWriter[Unit] = 
        use SheetIO/SheetWriter.{flatMap, return, createSheet, liftAction, mapX, appendRow};
        let* s1         = createSheet("Orphaned");
        let* headers    = liftAction(_ -> ["S4 Equi Id", "Site", "Description"]);
        let* _          = appendRow(s1, SheetIO/RowSetter.putHeaders!(headers));
        let* _          = mapX(r -> appendRow(s1, setOrphaned1Row!(r)), Chain.toList(rows));
        return()


    def setOrphaned1Row!(x: Orphaned1): RowSetter[Unit] = 
        use SheetIO/RowSetter.{flatMap, return, putStringAt!};
        let* _      = putStringAt!(0, x.s4EquiId);
        let* _      = putStringAt!(1, x.site);
        let* _      = putStringAt!(2, x.description);
        return()

    def makeOrphaned1(x: (String, String, String)): Orphaned1 = 
        let (x1, x2, x3) = x;
        { s4EquiId      = x1
        , site          = x2
        , description   = x3
        }

    /// fold step for the fixpoint, has to be pure
    pub def buildOrphaned1ChainStep(x: (String, String, String), ac: Chain[Orphaned1]): Chain[Orphaned1] = 
        Chain.snoc(ac, makeOrphaned1(x))

}

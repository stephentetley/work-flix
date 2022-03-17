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

namespace S4Loader/PDT/Gen/ReadDb {

    use Functor.{<$>};
    use Applicative.{<*>};

    use BasicDb.DbMonad;
    use BasicDb.RowEvaluator;

    use S4Loader/Base/Schema.{PdtOneToOneMapping, PropertyAlias, EquiObjectClass, StringProperty, IntProperty, FloatProperty, DateProperty, TankShape};

    pub type alias PersistentRelations[r1: SchemaRow] =
        #{PdtOneToOneMapping, PropertyAlias, EquiObjectClass, StringProperty, IntProperty, FloatProperty, DateProperty, TankShape | r1}

    pub def readDbAll(): DbMonad[PersistentRelations[r]] = 
        ((x1, x2, x3, x4, x5) -> x1 <+> x2 <+> x3 <+> x4 <+> x5)
            <$> readTankShape()
            <*> readPdtOneToOneMappings()
            <*> readPropertyAliases()
            <*> readEquiObjectClasses()
            <*> S4Loader/Base/ReadProperties.readProperties()
        

    pub def readTankShape(): DbMonad[#{TankShape | r}] = 
        let sql = "SELECT mec.class_name,  mec.description FROM meta_equi_classes mec;";
        BasicDb/Reader.allRelations(evalTankShape(), sql)


    def evalTankShape(): RowEvaluator[#{TankShape | r}] = 
        use BasicDb/RowEvaluator.{getStringAt};
        ((x1, x2) -> #{ TankShape(x1, x2). })
            <$> getStringAt(0)
            <*> getStringAt(1)



    pub def readPdtOneToOneMappings(): DbMonad[#{PdtOneToOneMapping | r}] = 
        let sql = "SELECT mpom.s4_equi_class, mpom.s4_equi_char, mpom.pdt_field_name FROM meta_pdt_oto_mappings mpom;";
        BasicDb/Reader.allRelations(evalPdtOneToOneMapping(), sql)


    def evalPdtOneToOneMapping(): RowEvaluator[#{PdtOneToOneMapping | r}] = 
        use BasicDb/RowEvaluator.{getStringAt};
        ((x1, x2, x3) -> #{ PdtOneToOneMapping(x1, x2, x3). })
            <$> getStringAt(0)
            <*> getStringAt(1)
            <*> getStringAt(2)


    pub def readPropertyAliases(): DbMonad[#{PropertyAlias | r}] = 
        let sql = "SELECT mec.description, mec.class_name, mec.char_name FROM meta_equi_characteristics mec;";
        BasicDb/Reader.allRelations(evalPropertyAlias(), sql)


    def evalPropertyAlias(): RowEvaluator[#{PropertyAlias | r}] = 
        use BasicDb/RowEvaluator.{getStringAt};
        ((x1, x2, x3) -> #{ PropertyAlias(x1, x2, x3). })
            <$> getStringAt(0)
            <*> getStringAt(1)
            <*> getStringAt(2)

    pub def readEquiObjectClasses(): DbMonad[#{EquiObjectClass | r}] = 
        BasicDb/Reader.allRelations(evalEquiObjectClass(), selectEquiObjectClassSQL())

    def evalEquiObjectClass(): RowEvaluator[#{EquiObjectClass | r}] = 
        use BasicDb/RowEvaluator.{getStringAt};
        ((x1, x2, x3, x4) -> #{ EquiObjectClass(x1, x2, x3, x4). })
            <$> getStringAt(0)
            <*> getStringAt(1)
            <*> getStringAt(2)
            <*> getStringAt(3)

    /// This uses a join that we could do in Datalog but we do it here for efficiency
    def selectEquiObjectClassSQL(): String = 
        String.unlines(
            "SELECT "
	            :: "    sp.equipment_id,"
                :: "    mpat.s4_category,"
	            :: "    mpat.s4_object,"
	            :: "    mpat.s4_class"
                :: "FROM string_properties sp "
                :: "INNER JOIN meta_pdt_asset_types mpat ON sp.prop_value = mpat.pdt_asset_type"
                :: "WHERE "
	            :: "    sp.prop_name = 'Asset Type';"
                :: Nil
        )


}

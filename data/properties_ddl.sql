DROP TABLE IF EXISTS string_properties;
DROP TABLE IF EXISTS int_properties;
DROP TABLE IF EXISTS float_properties;
DROP TABLE IF EXISTS dd_s4_properties;
DROP TABLE IF EXISTS dd_property_aliases;

CREATE TABLE string_properties (
	pli_num TEXT NOT NULL, 
	prop_name TEXT NOT NULL, 
	prop_value TEXT NOT NULL,
	PRIMARY KEY(pli_num, prop_name)
	);
	
CREATE TABLE int_properties (
	pli_num TEXT NOT NULL, 
	prop_name TEXT NOT NULL, 
	prop_value INTEGER NOT NULL,
	PRIMARY KEY(pli_num, prop_name)	
	);
	
CREATE TABLE float_properties (
	pli_num TEXT NOT NULL, 
	prop_name TEXT NOT NULL, 
	prop_value NUMERIC NOT NULL,
	PRIMARY KEY(pli_num, prop_name)
	);
	
	
CREATE TABLE dd_s4_properties (
	char_name TEXT NOT NULL, 
	char_type TEXT NOT NULL,
	char_size INTEGER NOT NULL,
	decimal_places INTEGER,
	PRIMARY KEY(char_name)
	);	
	
CREATE TABLE dd_property_aliases (
	ai_prop_name TEXT NOT NULL, 
	s4_class_name TEXT NOT NULL,
	s4_char_name TEXT NOT NULL,
	PRIMARY KEY(ai_prop_name, s4_class_name)
	);	
SHELL=/bin/bash
.PHONY: all sch csv db web php loc www \
        clean schclean csvclean dbclean webclean phpclean locclean wwwclean \
		test help Help
# Variablen nur zum Testen geändert
  MD_READ := $(shell if [ -z `cat Vars | awk -F';' '/^MD_READ/ {print $$2; exit}'` ]; \
     then m=`which ghostwriter`;echo $${m##*/}; \
     else echo `cat Vars | awk -F';' '/^MD_READ/ {print $$2; exit}'`; fi)
  TBL = $(basename $(wildcard *.schema)) # Alle Schema
  TBL_SCH := ${TBL:%=%_sch}
  TBL_CSV := ${TBL:%=%_csv}
  TBL_DB  := ${TBL:%=%_db}
  TBL_PHP := ${TBL:%=%_php}
  TBL_SCH_v := ${TBL:%=%_sch_v}
  TBL_CSV_v := ${TBL:%=%_csv_v}
  TBL_DB_v  := ${TBL:%=%_db_v}
  TBL_PHP_v := ${TBL:%=%_php_v}
  SQL = $(TBL:%=db/%_create.sql) $(TBL:%=db/%_delete.sql) \
        $(TBL:%=db/%_drop.sql) $(TBL:%=db/%_loaddata.sql) \
        $(TBL:%=db/%_select.sql)
  LVL = $(TBL:%=db/%.lvl)
  TST = $(TBL:%=db/%_test.sh)
  TXT = $(TBL:%=db/%.txt) # Steuerungsdatei für csv aus Schema Datei
  SCH = $(SQL) $(LVL) $(TST) $(TXT)
  CSV = $(TBL:%=db/%_main.csv) # main wird auf jeden Fall erzeugt
  DB  = $(TBL:%=db/%.db)
  WEB = www/index.html www/version.html www/contact.html www/imprint.html \
        www/sitemap.html www/help.html
  PHP = $(TBL:%=www/%.php) $(TBL:%=www/%_main.php) www/vars.php
#
# Pseudoziele Erstellen
# alles erstellen
all:  $(SCH) $(CSV) $(DB) $(WEB) $(PHP)
verbose:  opts = -v
verbose:  all
# einzeln erstellen
sch:  $(SCH)
csv:  $(CSV)
db:   $(DB)
web : $(WEB)
php:  $(PHP)
# gruppiert erstellen
loc:  $(SCH) $(CSV) $(DB)
www:  $(WEB) $(PHP)
# Pseudoziele Löschen
# alles löschen
clean:
  # Anzahl und Namen der erzeugten csv und php Dateien hängen von den Namen der
    # Tabellen in der ods Datei ab. Diese kann make nicht kennen
    # Sicher ist, dass die Tabelle main existieren muss
    # main wird für die csv Erzeugung als target verwendet
    # php erzeugt auch schema.php, diese werden als target verwendet
    # Gelöscht werden alle csv Dateien in den in Frage kommenden Verzeichnissen
    # Gelöscht werden alle php Dateien in Verzeichnis www
	@echo 'rm -f $$(WEB) $$(PHP) www/*.php' # nur Variablennamen, viele Dateien
	@rm -f $(WEB) $(PHP) www/*.php
	./Framework/db.sh -A        # removes $$(DB)
	@echo 'rm -f $$(SCH) $$(CSV)'
	@rm -f $(SCH) $(CSV)
	@echo 'rm -f db/*.csv; rm -f /db/*/*.csv'
	@rm -f db/*.csv
	@rm -f db/*/*.csv
# einzeln löschen - aufrufen in umgekehrter Reihenfolge, siehe help
schclean:
	@echo 'rm -f $(SCH)' # Inhalt ausgeben, nur eine Aktion
	@rm -f $(SCH)
csvclean:
	@echo 'rm -f $(CSV)'
	@rm -f $(CSV)
	@echo 'rm -f db/*.csv; rm -f /db/*/*.csv'
	@rm -f db/*.csv
	@rm -f db/*/*.csv
dbclean:
	./Framework/db.sh -A         # removes $$(DB)
webclean:
	@echo 'rm -f $(WEB)'
	@rm -f $(WEB)
phpclean:
	@echo 'rm -f $(PHP) www/*.php'
	@rm -f $(PHP) www/*.php
# gruppiert löschen - aufrufen in umgekehrter Reihenfolge, siehe help
locclean:
	./Framework/db.sh -A         # removes $$(DB)
	@echo 'rm -f $$(CSV) $$(SCH)'
	@rm -f $(CSV) $(SCH)
wwwclean:
	@echo 'rm -f $$(WEB) $$(PHP) www/*.php'
	@rm -f $(WEB) $(PHP) www/*.php
#
test:
	$(foreach tst,$(TST),./$(tst);)
#
help:
    # Info: Quelle -> Ziel
      # Quelldateien:
      #    example1.schema example2.schema
      # Zieldateien
      #    db/example1_create.sql    db/example2_create.sql
      #    db/example1_select.sql    db/example2_select.sql
      #    db/example1_drop.sql      db/example2_drop.sql
      #    db/example1_loaddata.sql  db/example2_loaddata.sql
      #    db/example1.lvl           db/example2.lvl
      #    db/example1.txt           db/example2.txt
      #    db/example1_test.sh       db/example2_test.sh

      # Quelldateien:
      #    db/example1.txt db/example1/example1_*.ods
      #    Jeder dieser ods Dateien kann mehrere Tabellen enthalten
      #    Doch alle müssen vom Namen, der Reihenfolge und der Spalten her die
      #    gleichen Tabellen enthalten,
      #    Ausserdem muß jede ods Datei wenigstens eine Tabelle mit Namen main
      #    enthalten
      # Zieldateien
      #    db/example1_main.csv db/example1_tabellenname*.csv und
      #    db/example1/example1_*.csv
	@echo "Ziele:                                           "
	@echo "    make              all"
	@echo "    make all          sch csv db web php"
	@echo "    make clean        phpclean webclean dbclean csvclean schclean"
	@echo "    make test         unbedingte Testabfragen an die Datenbank"
	@echo "    make help         Diese Hilfe"
	@echo "    make Help         Ausführliche Hilfe für das Framework"
	@echo "    make tree         Zeigt die Schema in Leveln an"
	@echo "                                                          "
	@echo "    make sch          sql Dateien erzeugen, bedingt"
	@echo "    make csv          csv Dateien erzeugen, bedingt"
	@echo "    make db           Datenbanktabellen erzeugen und füllen, bedingt"
	@echo "    make web          Rahmen html Dateien erzeugen, bedingt"
	@echo "    make php          php Dateien erzeugen, bedingt"
	@echo "    make phpclean     Alle php Dateien löschen, unbedingt."
	@echo "    make webclean     Alle Rahmen html Dateien löschen, unbedingt."
	@echo "    make dbclean      Alle Tabellen aus Datenbank löschen, unbedingt."
	@echo "    make csvclean     Alle csv Dateien löschen, unbedingt."
	@echo "    make schclean     Alle sql Dateien löschen, unbedingt."
	@echo "                                                          "
	@echo "    make loc          sch csv db"
	@echo "    make www          web php"
	@echo "    make wwwclean     phpclean webclean"
	@echo "    make locclean     dbclean csvclean schclean"
	@echo "                                                          "
	@echo "    make SCHEMA       sch csv db php für SCHEMA, unbedingt.          "
	@echo "    make SCHEMA_SCH   sch für SCHEMA, unbedingt.           "
	@echo "    make SCHEMA_CSV   csv für SCHEMA, unbedingt.           "
	@echo "    make SCHEMA_DB    db  für SCHEMA, unbedingt.           "
	@echo "    make SCHEMA_PHP   php für SCHEMA, unbedingt.           "
	@echo "                                                         "
	@echo "    make SCHEMA_SCH_v sch für SCHEMA, unbedingt, verbose.           "
	@echo "    make SCHEMA_CSV_v csv für SCHEMA, unbedingt, verbose.           "
	@echo "    make SCHEMA_DB_v  db  für SCHEMA, unbedingt, verbose.           "
	@echo "    make SCHEMA_PHP_v php für SCHEMA, unbedingt, verbose.           "
	@echo "                                                         "

Help:
	@if [ -z `which $(MD_READ)` ]; then more +/"2.1 Makefile" Framework/help.md; \
	else $(MD_READ) Framework/help.md; 	fi
	echo $(MD_READ)
tree:
	./Framework/db.sh -0

# Ziele für ein einzelnes SCHEMA
$(TBL):
	./Framework/splitschema.sh $@
	./Framework/csv.sh $@
	./Framework/db.sh $@
	./Framework/php.sh $@
$(TBL_SCH):
	./Framework/splitschema.sh $(subst _sch,,$@)
$(TBL_CSV):
	./Framework/csv.sh $(subst _csv,,$@)
$(TBL_DB):
	./Framework/db.sh $(subst _db,,$@)
$(TBL_PHP):
	./Framework/php.sh $(subst _php,,$@)
  #Bedingt vlt so:
  #$(OBJECTS):%:%.c
  #          @echo target is $@, source is $<

# verbose Ziele für ein einzelnes SCHEMA
$(TBL_v):
	./Framework/splitschema.sh -v $@
	./Framework/csv.sh -v $@
	./Framework/db.sh -v $@
	./Framework/php.sh -v $@
$(TBL_SCH_v):
	./Framework/splitschema.sh -v $(subst _sch_v,,$@)
$(TBL_CSV_v):
	./Framework/csv.sh -v $(subst _csv_v,,$@)
$(TBL_DB_v):
	./Framework/db.sh -v $(subst _db_v,,$@)
$(TBL_PHP_v):
	./Framework/php.sh -v $(subst _php_v,,$@)

# Ziele
db/%_create.sql db/%_drop.sql db/%_loaddata.sql db/%_select.sql db/%.lvl db/%_test.sh db/%.txt : %.schema
	./Framework/splitschema.sh ${opts} $(basename $<)
#
db/%_main.csv : db/%.txt db/%/*.ods
	./Framework/csv.sh ${opts} $(notdir $(basename $<))
#
db/%.db : db/%_main.csv
	./Framework/db.sh ${opts} $(notdir $(basename $@))
#
www/%.html : Framework/%.tmpl Vars
	./Framework/web.sh ${opts}
#
www/help.html : Framework/help.md
	pandoc -s Framework/help.md -o www/help.html 2>/dev/null

www/%.php : Framework/php.tmpl Vars
	./Framework/php.sh ${opts} $(notdir $(basename $@))

www/vars.php : Framework/vars.tmpl Vars
	./Framework/php.sh ${opts} $(notdir $(basename $@))


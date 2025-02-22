Framework txt2db -- Ein Tool der Moncastry Suite --
===================================================

# 1. Einleitung

Erzeugt mit `make` aus `*.schema` und `*.ods` Dateien Datenbanktabellen für **mariadb** und `*.php` Dateien zum Anzeige der Tabellen im Browser.

Die Daten zur Erzeugung einer Datenbank, zum Einpflegen der Daten und zur Anzeige der Werte sind in einer leicht zu bearbeitenden Form vorhanden. Der Erstellungsprozess ist ein Aufruf von `make`.

# 2. Beschreibung

## 2.1. <a id="anton_Aufgaben"></a>Aufgaben und Lösungsmöglichkeiten

### 2.1.1. Datenbankstruktur

Datenbankstruktur und Befehle sollen in Textdateien liegen. Alles, was eine Datenbanktabelle betrifft soll in einer Quelldatei zusammen sein.

Die Datenbankstruktur wird durch Erzeugung von Tabellen mittels des Befehls `CREATE TABLE` gebildet. Diese Befehle können in der selben Datei liegen wie die Befehle `DROP TABLE`, `LOAD DATA` und `SELECT`.

Zur Ausführung können sie dann extrahiert werden. Die Datei kann vor der Ausführung auch gesplittet werden.

### 2.1.2. Daten

Die Daten sollen einfach verändert werden können.

Datenbankwerte können textuell über Csv Dateien eingelesen werden. Die Pflege von Csv Dateien als Datenquellen ist fehleranfällig. Deshalb sollen die Daten in Tabellen in einem Tabellenkalkulationsprogramm erstellt und verändert werden.

Diese können in Csv Dateien konvertiert werden.

### 2.1.3. Anzeige

Die Datenbank soll lokal im Browser angezeigt werden.

Aus den Datenbankabfragen können Php Dateien erzeugt werden. Es könnten auch mit dem Ergebnis der Abfragen statische HTML-Seiten erzeugt werden.

## 2.2. Rahmenfestlegung

### 2.2.1. Allgemein Rahmen

Quelldaten und Werkzeuge zur Erzeugung der Ergebnisse sind voneinander unabhängig. Der Werkzeugkasten (das Framework) kann für beliebige Tabellen verwendet werden. Der Erstellungsprozess wird mit `make` gesteuert. Als Tabellenkalkulationsprogramm wird **LibreOffice Calc** verwendet.

### 2.2.2. Framework

Das Framework **txt2db** besteht aus den Werkzeugen, den Dateien [`Makefile`](../Makefile) und [`Vars`](../Vars) und einer geforderten Struktur und Namenskonvention der Quelldaten. Im Detail wird es in [Kapitel 2](#anton_Kapitel_Framework) beschrieben.

### 2.2.3. Quelldaten

Datenbankstruktur und Datenbankdaten werden getrennt. Die Strukturdaten werden in Schema Dateien `*.schema` gespeichert, die Daten selbst in jeweils entsprechenden `*.ods` Dateien. Eine Schema Datei kann mehrere Datenbanktabellen verwalten. Sie enthält die Datenbankbefehle fürs Erzeugen, Löschen, Einlesen und Abfragen. Genaueres über die Daten in [Kapitel 3](#anton_Kapitel_Daten)

## 2.3. Einschränkungen

- **txt2db** funktioniert nicht unter Windows.
- **txt2db** ist nur auf Debian GNOME getestet.
- Ob ein anderer Wert als **localhost** für den Eintrag **db_server** in [`Vars`](../Vars) funktioniert ist nicht getestet.
- `make` löscht alle Csv Dateien im Verzeichnis `db/` und seinen direkten Unterverzeichnissen, auch die, die es nicht erzeugt.
- Zu jedem Schema muss es eine Datenbank Tabelle geben, die wie das Schema **SCHEMA** heißt.
- Es darf keine Datenbank Tabelle **main** geben.
- Alle Ods Tabellenblätter müssen so heißen wie die ihnen entsprechende Datenbank Tabelle.
- Das Ods Tabellenblatt das der Tabelle **SCHEMA** entspricht, kann auch **main** heißen.
- Im Abschnitt **Level** der Schemadatei darf außer der Levelziffer keine weitere Ziffer vorkommen.

## 2.4. Konventionen in diesem Dokument

Dateinamen sind als Markdown Code `quoted`. Pfade sind immer relativ zum Wurzelverzeichnis des Projekts. **SCHEMA** steht für den Namen des Schema. Dieser ist aus dem Namen der Schema Datei ersichtlich, sie heißt **SCHEMA.schema**`

**Schema** wird nicht dekliniert. Es ist im Plural und im Genitiv **Schema**.

# 3. Voraussetzungen

## 3.1. <a id="anton_Infrastruktur"></a>Infrastruktur

- [fus4sh](#anton_Fus4sh) muß installiert sein und gefunden werden, entweder über eine Umgebungsvariable **SCRIPT_DIR** oder eine Verlinkung von **fus4sh** ins Wurzelverzeichnis des Projekts.
- [make](https://www.gnu.org/software/make/) muß installiert sein.
- [libreoffice](https://de.libreoffice.org/) muß installiert sein und nicht laufen
- [mariadb](https://mariadb.org/) muß installiert sein und laufen.
    - Die [Datenbank](#anton_Datenbank)  [`Vars`](../Vars)**db_db** muß existieren.
    - Der Nutzer  [`Vars`](../Vars)**db_user** muß Zugriff auf die Datenbank haben.
    - Das Passwort des Nutzers muß [`Vars`](../Vars)**db_password** sein.
- Für die Anzeige:
    - ein Webserver muß installiert sein und laufen.
    - Der Servername muß [`Vars`](../Vars) **db_server** sein.
    - In die Document-Root muß `./www` als [`Vars`](../Vars)**www** verlinkt sein.
- Für die Entwicklerversion: <a id="anton_Infrastruktur_Entwickler">
    - [git](https://git-scm.com/) muß installiert sein.
    - [shellcheck](https://www.shellcheck.net/) (im **Debian** Repository enthalten) muß installiert sein.
    - [bats-core](https://bats-core.readthedocs.io/en/stable/index.html) muß [lokal im Projekt](#anton_bats_core) installiert sein
    - [`./Framework/intern/pre-commit.src`](intern/pre-commit.src) muß nach [`pre-commit`](../.git/hooks/pre-commit) kopiert sein.
    - [`./Framework/intern/post-commit.src`](intern/post-commit.src) muß nach [`post-commit`](../.git/hooks/post-commit) kopiert sein.
    - [`./Framework/intern/config.src`](intern/config.src) muß nach [`config`](../.git/config) kopiert sein.
    - Damit ist [`gitcommit.template`](intern/gitcommit.template) als git **commit-template** gesetzt
    - Bei Verwendung von **Visual Studio Code** kann [`./Framework/intern/txt2db.code-workspace.src`](intern/txt2db.code-workspace.src) ins Elternverzeichnis als `txt2db.code-workspace` kopiert als Workspace  verwendet werden.

## 3.2. <a id="anton_Projektstruktur"></a>Projektstruktur

Das Framework **txt2db** wird in das Wurzelverzeichnis  des Projekts kopiert. Dadurch entsteht folgende Verzeichnisstruktur
```
db/
   example1/
        example1_quelle_1.ods
        example1_quelle_2.ods
   example2/
        example2_quelle_1.ods
   example3/
        example3_quelle_1.ods
Framework/
    msgs.dat
    help.md
    csv.sh
    db.sh
    fus.sh
    web.sh
    php.sh
    splitschema.sh
    tmpl_fus.sh
    contact.tmpl
    imprint.tmpl
    index.tmpl
    php.tmpl
    sitemap.tmpl
    vars.tmpl
    version.tmpl
www/
    css/
        txt2db.css
        vars.css
    media/
        *.png
    scripts/
        txt2db.js
example1.schema
example2.schema
example3.schema
Makefile
README.md
.Vars
Vars
Version.txt
```
Verwendet man die Entwickler Version, erhält man folgende Struktur:
```
.git/
    config
    hooks/
        post-commit
        pre-commit
        *.sample
    */
    *
.vscode/
    project-words.txt
    markdown.css
db/
   example1/
        example1_quelle_1.ods
        example1_quelle_2.ods
   example2/
        example2_quelle_1.ods
   example3/
        example3_quelle_1.ods
Framework/
    intern/*
    msgs.dat
    help.md
    csv.sh
    db.sh
    fus.sh
    web.sh
    php.sh
    splitschema.sh
    tmpl_fus.sh
    contact.tmpl
    imprint.tmpl
    index.tmpl
    php.tmpl
    sitemap.tmpl
    vars.tmpl
    version.tmpl
test/
    test_helper/
        common-setup.bash
        *
    bats/*
    Framework/
        csv.bats
        db.bats
        fus.bats
        web.bats
        php.bats
        splitschema.bats
        tmpl_fus.bats
www/
    css/
        txt2db.css
        vars.css
    media/
        *.png
    scripts/
        txt2db.js
.gitignore
.gitmodules
example1.schema
example2.schema
example3.schema
Makefile
README.md
.Vars
Vars
Version.txt
```

## 3.3. <a id="anton_Einrichten"></a>Einrichten

Der Name ds Wurzelverzeichnis des Projekts sei **exampledb**. Der Name der Datenbank sei **example**. Die Dokumentroot heiße **myexample**. Einträge mit eine (-) davor sind optional.

- Installiere **fus4db**
- Erstelle eine Umgebungsvariable **SCRIPT_DIR** ins Elternverzeichnis von **fus4db**
    - öffne `~/.bashrc` in einem Editor und füge folgende 2 Zeilen hinzu (Den Pfad ins Elternverzeichnis von **fus4db** verwenden):
    - `declare -r SCRIPT_DIR="/home/OneDrive/Scripts"`
    - `export SCRIPT_DIR`
- Kopiere **txt2db** ins [Wurzelverzeichnis](#anton_Projektstruktur) **exampledb**
- (-)  Kopiere `./Framework/intern/txt2db.code-workspace`als `exampledb.code-workspace` ins Elternverzeichnis von **exampledb**
    - (-) Editiere die gerade kopierte Datei `exampledb.code-workspace` und ändere in der vierten Zeile den String von **txt2db** zu **exampledb**
    - (-) Gehe ins Verzeichnis `./Framework/intern`
    - (-) `rm txt2db.code-workspace`
    - (-) `ln -s ../../../exampledb.code-workspace`
    - (-) Öffne den Workspace in **Visual Studio Code**
- (-) Lade [bats-core](#anton_bats_core) ins Projektverzeichnis
- Erzeuge eine Datenbank für das Projekt. Diese heißt hier **example**;
    - Als Super User (Namen und Passwort eines lokalen Nutzers verwenden)
        - `sudo mariadb`
        - `create database example;`
        - `grant all privileges on example.* TO 'USER'@'localhost' identified by 'PWD';`
        - `flush privileges;`
        - `exit`
    - (-) Prüfe ob du Zugang zur Datenbank example  hast
        - (-) `mariadb --user=USER --password=PWD --database=example`
        - (-) `exit`
- Passe in der Datei `./Vars` die Werte zu den vier **db_** Schlüsseln an
    - **db_server;localhost;**
    - **db_db;example;**
    - **db_user;USER;**
    - **db_password;PWD;**
- Verlinke in der Dokumentroot deines Servers das Verzeichnis `./www` unter einem beliebigen Namen. Wir wählen **myexample**
     - `ln -s /PFAD_ZUM_PROJEKT/exampledb/www myexample`
- Passe weitere Werte in der Datei `./Vars` an
     - **www** zu **myexample**
     - (-) **project** auch zu **myexample** oder was anderem
     - (-) **author_attr** zu deinem Namen
     - (-) **keywords_attr** zu **exampledb**
     - (-) **title_attr** zu **exampledb**
     - (-) **cr_name** zu einem gewünschten Namen
     - (-) **header** zu **EXAMPLEDB**
     - (-) **in_desc_attr** dort **Txt2db** zu **Exampledb** ändern
     - (-) **co_desc_attr** Den Text anpassen
- Starte `make` in einer Shell in der Projektwurzel
- (-) Betrachte [das Ergebnis](127.0.0.1/myexample/) im Browser

Auf die notwendigen Schritte reduziert:

- Installiere **fus4db**
- Erstelle eine Umgebungsvariable **SCRIPT_DIR** ins Elternverzeichnis von **fus4db**
    - öffne `~/.bashrc` in einem Editor und füge folgende 2 Zeilen hinzu (Den Pfad ins Elternverzeichnis von **fus4db** verwenden):
    - `declare -r SCRIPT_DIR="/home/OneDrive/Scripts"`
    - `export SCRIPT_DIR`
- Kopiere **txt2db** ins [Wurzelverzeichnis](#anton_Projektstruktur) **exampledb**
- Erzeuge eine Datenbank für das Projekt. Diese soll **example** heißen;
    - Als Super User (Namen und Passwort eines lokalen Nutzers verwenden)
        - `sudo mariadb`
        - `create database example;`
        - `grant all privileges on example.* TO 'USER'@'localhost' identified by 'PWD';`
        - `flush privileges;`
        - `exit`
- Passe in der Datei `./Vars` die Werte zu den vier **db_** Schlüsseln an.
    - **db_server;localhost;**
    - **db_db;example;**
    - **db_user;USER;**
    - **db_password;PWD;**
- Verlinke in der Dokumentroot deines Servers das Verzeichnis `./www` unter einem beliebigen Namen. Wir wählen **myexample**
    - `ln -s /PFAD_ZUM_PROJEKT/exampledb/www myexample`
- Passe weitere Werte in der Datei `./Vars` an
    - **www** zu **myexample**
- Starte `make` in einer Shell in der Projektwurzel

## 3.4. <a id="anton_Datei_Vars"></a>Datei Vars

Das **txt2db** benötigt einige projektspezifische Daten. Diese werden aus der Datei [`Vars`](../Vars) gelesen. Jede Zeile entspricht einem Kenner-Wert  Eintrag. Trenner zwischen Kenner und Wert ist der Strichpunkt.

Das Framework liefert eine Vorgabedatei [`Vars`](../Vars) mit; sie enthält alle möglichen Einträge, die Werte können angepasst werden, die Werte für den Zugriff auf die Datenbank müssen angepasst werden. Die einzelnen Einträge werden jeweils in den Abschnitten der Werkzeuge erläutert, die sie benutzen.

Geheime Einträge können auch in einer Datei `./.Vars` gemacht werden. So kann man das gesamte Projekt bis auf diese Datei weitergeben. Schlüssel die sowohl in `./Vars` als auch in `./.Vars` vorhanden sind, nehmen den Wert aus `./.Vars`

## 3.5. <a id="anton_Datenbank"></a>Datenbank

Host, Name,  Nutzer und Passwort für die Datenbank werden in der Datei [`Vars`](../Vars) gespeichert:
```
db_server;localhost;
db_user;USER;
db_password;PWD;
db_db;txt2db;
```
Der Eintrag Host ist nur notwendig, wenn auch die Anzeige erzeugt werden soll. Die Verwendung eines anderen Hosts als **localhost** ist nicht getestet. Die Datenbank muss in **mariadb** existieren. Der Nutzer muss mit dem Passwort Zugriff darauf haben.

Für die Werte aus obigen Beispiel ergeben sich folgende Schritte zur Erzeugung:
```
sudo mariadb
create database txt2db;
grant all privileges on txt2db.* TO 'USER'@'localhost' identified by 'PWD';
flush privileges;
exit
```
Die Anmeldung erfolgt dann mit folgendem Aufruf:
```
mariadb --user=USER --password=PWD --database=txt2db
```

## 3.6. fus4sh

### 3.6.1. <a id="anton_Fus4sh"></a>Allgemein fus4sh

**fus4sh** ist ein weiteres Projekt der **Moncastry Suite**. Es stellt Funktionen zur Verfügung, die in größeren Shell-Script Projekten nützlich sein können. **txt2db** verwendet Funktionen daraus, ist also davon abhängig.

Es gibt zwei Möglichkeiten, daß **txt2db** Zugriff auf **fus4sh** erhält.

### 3.6.2. Umgebungsvariable SCRIPT_DIR

Man setzt eine Umgebungsvariable SCRIPT_DIR auf das Elternverzeichnis von **fus4sh**. Dies kann man z.B. in der `~/.bashrc` machen:
```
declare -r SCRIPT_DIR="/home/OneDrive/Scripts"
export SCRIPT_DIR
```
In einer neuen Shell ist diese Variable dann als Umgebungsvariable gesetzt
```
txt2db$ printenv SCRIPT_DIR
/home/OneDrive/Scripts
txt2db$
```
und **txt2db** funktionsfähig.


In der Entwicklerversion wird auch [shellcheck](https://www.shellcheck.net/) aufgerufen. Damit dieses den Pfad kennt, muß dieser in einer Konfigurationsdatei `.shellcheckrc` gefunden werden. Ein Aufruf von [fus.sh](./fus.sh) mit der Option **-c** erzeugt diese Datei:
```
txt2db$ ./Framework/fus.sh -c
fus4sh wird durch "SCRIPT_DIR" als "/home/OneDrive/Scripts/fus4sh"
eingebunden. Shellcheck kann Pfade nicht über Variablen auflösen.
Es kann diese Pfade aus seiner Konfigurationsdatei lesen.

Dieses Script mit der Option -c aufgerufen erstellt sie:
/home/OneDrive/Projekte/txt2db/Framework/fus.sh -c

Manuell können Sie so verfahren:
Legen Sie eine Datei "/home/OneDrive/Projekte/txt2db/.shellcheckrc" an.
Schreiben Sie folgende zwei Textzeilen in diese Datei:

source-path=/home/OneDrive/Scripts
source-path=/home/OneDrive/Scripts/fus4sh

Erzeuge /home/OneDrive/Projekte/txt2db/.shellcheckrc
```

### 3.6.3. Verlinkung von **fus4sh** nach **txt2db**

Man verlinkt das Wurzelverzeichnis von **fus4sh** ins Wurzelverzeichnis von **txt2db**:
```
txt2db$ ln -s /home/OneDrive/Scripts/fus4sh
txt2db$ ls
db  example1.schema  example2.schema  example3.schema  Framework  fus4sh  Makefile  test  Vars  www
txt2db$
```

Für die Entwicklerversion ist weiter nichts zu beachten. Da die Pfade zu **fus4sh** in diesem Fall relativ sind, werden sie Shellcheck schon im Code bekannt gegeben.

## 3.7. <a id="anton_bats_core"></a>bats-core

Verfahre wie in [Quick Installation](https://bats-core.readthedocs.io/en/stable/tutorial.html#quick-installation) von **bats-core** beschrieben. Gehe ins Wurzelverzeichnis des Projekts. Da mit dieser Methode **git submodule** erstellt werden, sollte das Git Repository schon existieren. Führe die folgenden drei Befehle aus:

```
git submodule add https://github.com/bats-core/bats-core.git test/bats
git submodule add https://github.com/bats-core/bats-support.git test/test_helper/bats-support
git submodule add https://github.com/bats-core/bats-assert.git test/test_helper/bats-assert
```


# 4. Framework txt2db

## 4.1. <a id="anton_Kapitel_Framework"></a>Struktur und Namenskonvention Quelldateien

Für eine Datenbanktabelle oder eine Gruppe zusammengehöriger Tabellen *example1* wird eine Schemadatei `example1.schema` und eine Datendatei `db/example1/example1_quelle_1.ods` benötigt. Für *example2* wären die entsprechenden Quelldateien `example2.schema` und `db/example2/example2_quelle_1.ods`.

## 4.2. Konventionen

- In den Schema Dateien müssen alle auszuführenden SQL Befehle vollständig großgeschrieben sein
- In Kommentaren der Schema Dateien darf kein auszuführender SQL Befehl vollständig groß geschrieben sein
- Soll die Ausgabe funktionieren, müssen in den Schema Dateien alle SQL Schlüsselwörter vollständig groß geschrieben sein.

## 4.3. [Makefile](../Makefile)

- `make help` zeigt alle verfügbaren Ziele an.
- `make` erstellt alles bedingt
- `make clean` löscht alles unbedingt
- `make test` lässt Tests über die Datenbank laufen
- `make tree` zeigt die Schema hierarchisch an

Dann gibt es noch Ziele für einzelne Schritte: `sch`, `csv`, `db`, `web`, `php` und für jedes dieser auch ein Löschziele `schclean`, `csvclean`, `dbclean`, `web`, `phpclean`. `loc` führt die drei Ziele `sch`, `csv`, `db` aus, `locclean` bereinigt sie. `www` fasst `web`, `php` zusammen und `wwwclean` bereinigt diese.

Erstellt und löscht man mit Einzelzielen sollte man `dbclean` immer vor `csvclean` und `schclean` ausführen, da es mit den Befehlen für eine neue Datenbankstruktur evtl nicht möglich ist die alten Tabellen zu löschen.

Es gibt auch unbedingte Ziele für jedes **SCHEMA**. `make SCHEMA` führt alle Erstellungsschritte für **SCHEMA** aus. Die Ziele **SCHEMA_SCH**, **SCHEMA_CSV**, **SCHEMA_DB** und **SCHEMA_PHP** führen jeweils nur den entsprechenden Erstellungsschritt für **SCHEMA** aus. Entsprechende Löschziele gibt es nicht, da diese Ziele unbedingt sind.

`make Help`
Zeigt diese Datei an. Für die Anzeige wird standardmäßig `ghostwriter` verwendet. Ein anderes Anzeigeprogramm kann mit dem Eintrag **MD_READ** in [`Vars`}(../Vars) vorgegeben werden. Standardmäßig ist dieser Eintrag in [`Vars`}(../Vars) deaktiviert:
```
 #MD_READ;gnome-text-editor;
```
Wird das Anzeigeprogramm nicht gefunden, erfolgt die Anzeige mit `more`.

Seine Ziele erfüllt **make** durch Ausführen der Scripte in `./Framework`. Diese können auch von der Befehlszeile aufgerufen werden.

## 4.4. <a id="anton_Placeholder"></a>Placeholder Substitution

In den Template Dateien für die Anzeige stehen Platzhalter. Diese haben entweder die Form %%name%% oder (%name%).

Die Platzhalter mit je zwei Prozentzeichen vorne und hinten entsprechen Einträgen in der Datei [`./Vars'](../Vars). Es können auch eigene Werte hinzugefügt werden. Jeder Platzhalter, der in einem Template steht und in  [`./Vars`](../Vars) zu finden ist, wird bei der Konvertierung ersetzt.

Die Platzhalter mit runden Klammern und Prozentzeichen sind funktionale Platzhalter. Deren Name **name** entspricht einer Funktion **create_name** in der Datei [./Framework/tmpl_fus.sh](./tmpl_fus.sh). Dort können auch eigene Funktionen hinzugefügt werden. Jeder funktionale Platzhalter, der in einem Template steht und zu dem eine Funktion **create_name** gefunden wird, wird durch die Ausgabe dieser Funktion ersetzt. Siehe [tmpl_fus](#anton_tmpl_fus_sh)

## 4.5. Scripte

### 4.5.1. Allgemein Scripte

Die Datei [`./Framework/fus.sh`](fus.sh) kann von allen anderen Script Dateien inkludiert werden. Sie inkludiert **fus4sh** Sie enthält allgemeine Funktionen. Die Funktionen in [`./Framework/tmpl_fus`](tmpl_fus.sh) erzeugen **html** Fragmente.

Die anderen Script Dateien sind ausführbare Scripte. Alle können mit den Optionen "**-h**"(Hilfe), "**-v**" (Verbose) und "**-d**" (Dry) aufgerufen werden. Bis auf [`web.sh`](#anton_web_sh) haben sie alle ein Argument, den Namen des Schema. [`db.sh`](#anton_db_sh) kann als zweites Argument noch **drop** haben, dann werden die Tabellen des Schema aus der Datenbank gelöscht.

### 4.5.2. <a id="anton_splitschema_sh"></a>[`./Framework/splitschema.sh`](splitschema.sh)

Erzeugt aus einer `*.schema` Datei im Wurzelverzeichnis acht Dateien im Verzeichnis `db`. Wenn die **schema** Datei `SCHEMA.schema` heisst, werden durch den Aufruf `./Framework/splitschema.sh SCHEMA` erzeugt:
- [`db/SCHEMA_create.sql`](#anton_CREATE_TABLE) zum Erzeugen der Tabellen
- [`db/SCHEMA_loaddata.sql`](#anton_LOAD_DATA) zum Füllen der Tabellen
- [`db/SCHEMA_drop.sql`](#anton_DROP_TABLE) zum Löschen der Tabellen
- [`db/SCHEMA_delete.sql`](#anton_DELETE_FROM_TABLE) zum Löschen von lower level Daten
- [`db/SCHEMA_select.sql`](#anton_SELECT_FROM) zum Abfragen der Tabellen
- [`db/SCHEMA.txt`](#anton_CSV_Control) Hilfsdatei, nötig zum [Erzeugen der **csv** Dateien](#anton_csv_sh) aus **ods** Dateien
- [`db/SCHEMA.lvl`](#anton_SCHEMA_LEVEL) zur Hierarchieerkennung der Schema
- [`db/SCHEMA_test.sh`](#anton_SELECT_FROM) Alle **SELECT** Befehle als Shell Aufrufe.

### 4.5.3. <a id="anton_csv_sh"></a>[`./Framework/csv.sh`](csv.sh)

Erzeugt aus einer [`*.ods` Datei](#anton_ODS_Dateien) in einem Unterverzeichnis **SCHEMA** von `./db` für jede Tabelle der **ods** Datei eine **csv** Datei im Verzeichnis `./db` mithilfe einer Steuerungsdatei `./db/SCHEMA.txt`.

Die Umwandlung erfolgt mit dem Kommandozeilenbefehl `libreoffice --convert-to`, das dazu die [Steuerungsdatei](#anton_CSV_Control)  `./db/SCHEMA.txt` verwendet, eine der Dateien die von [`splitschema.sh`](splitschema.sh) erzeugt wird.

Während [`csv.sh`](csv.sh) ausgeführt wird, darf **libreoffice** nicht laufen. Das Script erkennt dies, warnt und bricht ab.

### 4.5.4. <a id="anton_db_sh"></a>[`./Framework/db.sh`](db.sh)

Verändert die Datenbank in **mariadb** unter Nutzung der von [`splitschema.sh`](#anton_splitschema_sh) und [`csv.sh`](#anton_csv_sh) erstellten Dateien. Das erste Argument ist **SCHEMA**. Wird als zweites Argumente **drop** mitgegeben, werden die Daten und Tabellen von **SCHEMA** in **mariadb** gelöscht.

Da die Datenbanktabellen voneinander abhängig sein können, müssen die unteren zuerst erzeugt und die oberen zuerst gelöscht werden. Die Ziffer in der Datei `./db/SCHEMA.lvl` zeigt an in welchem Verhältnis sich ein Schema zu anderen befindet. Es werden nur 9 Level berücksichtigt.

Die Aufrufoptionen -1 bis -9 erzeugen die Tabellen bis zur angegebenen Schicht. Die Aufrufoptionen -A bis -I löschen die Tabellen von oben nach unten bis zu angegebenen Schicht, wobei A 1 entspricht und I 9.

- `./Framework/db.sh -h` zeigt alle möglichen Optionen an.
- `./Framework/db.sh -0`
    zeigt alle vorhandenen Schichten an
- `./Framework/db.sh -A`
    löscht von Schicht 9 bis 1 alle Tabellen  (bei nicht existierenden Tabellen oder Schichten wird nichts getan)
- `./Framework/db.sh -8`
    erzeugt daraufhin von Schicht 1 bis 8 alle Tabellen (bei nicht existierenden Schichten wird nichts getan)
- `./Framework/db.sh -v -8`
    löscht nun Tabellen der Schicht 8 und erstellt sie neu. Zeigt an, was es tut.
- `./Framework/db.sh -v -7`
    löscht nun Tabellen der Schicht 7 und 8 und erstellt sie neu. Zeigt an, was es tut.
- `./Framework/db.sh -v -C`
    löscht nun Tabellen der Schicht 7 bis 3. Zeigt an, was es tut.

### 4.5.5. <a id="anton_web_sh"></a>[`./Framework/web.sh`](web.sh)

Erzeugt aus den Dateien [`./Framework/index.tmpl`](index.tmpl), [`./Framework/version.tmpl`](version.tmpl), [`./Framework/contact.tmpl`](contact.tmpl), [`./Framework/imprint.tmpl`](imprint.tmpl) und [`./Framework/sitemap.tmpl`](sitemap.tmpl) die statischen **html-Dateien** `./www.index.html`, `./www.version.html`, `./www/contact.html`, `./www/imprint.html` und `./www/sitemap.html`. Es findet eine [Platzhalter](#anton_Placeholder) Konvertierung sowohl von statischen Platzhaltern als auch von funktionalen Platzhaltern statt.

### 4.5.6. <a id="anton_php_sh"></a>[`./Framework/php.sh`](php.sh)

[`./Framework/php.sh`](php.sh) erzeugt aus [`./Framework/vars.tmpl`](vars.tmpl) die Datei [`./www/vars.php`](vars.php). Diese wird von allen php Dateien, die [`./Framework/php.sh`](php.sh) erzeugt eingebunden.

Es findet eine [Platzhalter](#anton_Placeholder) Konvertierung sowohl von statischen Platzhaltern als auch von funktionalen Platzhaltern statt.

Für jedes Schema wird eine Überblicksseite erzeugt. In dieser ist im Moment der **article** leer. Für jede Tabelle wird eine Seite erzeugt, in derem **Article** werden alle  SELECT Abfragen aus[`db/SCHEMA_select.sql`](#anton_SELECT_FROM) mit php ausgeführt. Das bewirkt  der funktionale Platzhalter **(%article%)**, über den die Funktion **create_article** aufgerufen wird.

In der linken Seitenleiste werden über den prozeduralen Platzhalter **(%link_tree%)** alle erzeugten Seiten verlinkt.

Zugriff auf die Datenbank erfolgt erst bei der Anzeige im Browser.

### 4.5.7. <a id="anton_tmpl_fus_sh"></a>[`./Framework/tmpl_fus.sh`](tmpl_fus.sh)

Alle Platzhalter Funktionen haben 5 Argumente, nicht jede benutzt alle.

- INDENT - die Einrückungstiefe des zurückgegebenen php Codes. Die erste Zeile wird nicht eingerückt. Eine einzelne Einrückung ist auf 2 Leerzeichen festgelegt.
- SCHEMAS - eine Stringliste aus SCHEMA Namen
- SCHEMA - ein Schemaname
- TABLE - ein Tabellenname
- SELECT_FILE - ein Pfad zu einer Datei mit SELECT Statements

Vorhandene Funktionen sind:

- create_link_tree IND SCHEMAS                  : ul/li geschachtelte Links
- create_title_attr x x SCHEMA TABLE            : String
- create_desc_attr x x x TABLE x                : String
- create_gimmecks: x x SCHEMA TABLE             : p und Link to help
- create_breadcrumbs IND x SCHEMA TABLE         : li links
- create_article IND x SCHEMA TABLE SELECT_FILE : tables mit SELECT Ergebnissen

Die Liste der Placeholder Funktionen ist dynamisch. Sie besteht aus allen Funktionen, die in dieser Datei stehen und deren Name mit create_ beginnt werden. Wenn eine neue Funktion hinzugefügt wird, wird sie auf einen entsprechenden Placeholder angewandt.

# 5. Definierende Dateien und Daten

## 5.1. Allgemein Daten

Mit Hilfe der Quelldateien kann aus den Schema Dateien und den Daten in Tabellenkalkulationsdateien die vollständige Datenbank erzeugt werden. Die Schema Dateien sind reine Textdateien, Tabellenkalkulation bietet ein ausgewogenes Verhältnis von Editierbarkeit und Übersicht.

## 5.2. Schema Dateien

### 5.2.1. Allgemein Schema Dateien

Eine Schema Datei heißt `SCHEMA.schema` wobei **SCHEMA** der Name des Schema ist. Schema Dateien liegen im Wurzelverzeichnis des Projekts. Jederzeit können neue Schema Dateien hinzugefügt oder vorhandene entfernt werden.

Eine Schemadatei enthält das, was man als eine Tabelle modellieren möchte. Durch Normalisierungen können sich daraus für relationale Datenbanken mehrere Tabellen ergeben. Die Datei ist in 8 Abschnitte geteilt. Der 1. Abschnitt kann für Kommentierung verwendet werden.  Die anderen werden mit `make sch` in 7 Dateien aufgeteilt. Wer genaueres wissen möchte, `make sch` benutzt dazu das Script [`splitschema.sh`](#anton_splitschema_sh). Wird `make` ohne Ziel oder `make all` aufgerufen, ist das Splitten des Schema der erste Schritt, der ausgeführt wird.

Die fünf Abschnitte ["Schema Definition"](#anton_CREATE_TABLE), ["Read Data in"](#anton_LOAD_DATA), ["Remove Lower Level Data"](#anton_DELETE_FROM_TABLE), ["Remove Table(s)"](#anton_DROP_TABLE) und ["Abfragen"](#anton_SELECT_FROM) enthalten reinen SQL Code.

Der kleine Abschnitt ["Level"](#anton_SCHEMA_LEVEL) enthält die Daten der Tree Datei, eigentlich nur eine Nummer, die anzeigt, auf welcher Abhängigkeitsebene sich dieses Schema befindet. Ein Schema ist höchstens von anderen Schema mit niedrigerer Nummer abhängig.

Aus dem Abschnitt ["CSV Control"](#anton_CSV_Control) wird die Steuerungsdatei für `csv.sh`. Mit deren Hilfe wird der Inhalt der  Ods Tabellen in Csv Dateien geschrieben.

Der Beginn eines Abschnitts ist durch drei Doppelkreuze am Zeilenanfang gekennzeichnet. Die Interpretation eines Abschnitts wird alleine durch seine Position bestimmt, d.h. der wievielte Abschnitt es ist. Die Bezeichnungen in den Beispiel Schema Dateien haben keinen Einfluss auf die Semantik. Sie könnten auch fehlen oder widersinnig sein.

Im Folgenden werden die Abschnitte anhand der Beispieldatei [`example1.schema`](../example1.schema) genauer beschrieben.

### 5.2.2. <a id="anton_CREATE_TABLE"></a>Schema Definition

Dieser Abschnitt ist der vierte Abschnitt. Er enthält "CREATE TABLE" Befehle für das Schema SCHEMA. Es können mehrere Tabellen definiert werden. Eine Tabelle muß so heissen wie das Schema. Für Schema **example1** muß eine Tabelle **example1** erzeugt werden.

Die Befehle werden von oben nach unten ausgeführt. Es können Abhängigkeiten zu Tabellen niedrigerer Level verwendet werden. In welcher Reihenfolge Schema Dateien gleicher Level ausgeführt werden ist nicht definiert.

Aus diesem Abschnitt wird die Datei `./db/schema_create.sql` erzeugt. Diese kann mit `mariadb --user=db_user --password=db_password --database=db_db < ./db/schema_create.sql` in der Datenbank ausgeführt werden. `make db` führt diesen Schritt vor [**Read Data in**](#anton_LOAD_DATA) aus.

### 5.2.3. <a id="anton_LOAD_DATA"></a>Read Data in

Dieser Abschnitt ist der siebte Abschnitt. Er  enthält "LOAD DATA" Befehle für die vom Schema SCHEMA erzeugten Tabellen. Die Befehle werden von oben nach unten ausgeführt. Die Daten werden aus Csv Dateien eingelesen, die im Befehl angegeben werden müssen.

Diese Csv Dateien werden von `make csv` im Verzeichnis `./db/` erzeugt. `make db` liest sie in die Datenbank ein. `make` oder `make all` führen die Schritte in der notwendigen Reihenfolge aus.

Der Name der Csv Datei besteht aus dem Namen des Schema, einem Unterstrich und dem Namen der Tabelle. Der Name der Tabelle ist in der Ods Datei und in der Datenbank gleich. Eine Ausnahme ist die Datenbank Tabelle mit dem Namen des Schemas, in dem Beispiel **example1**. Sie kann auch mit als Tabellenblatt namens **main** in der Ods Datei vorhanden sein.

Im Beispiel ist der Name der Csv Datei `./db/example1_main.csv`, da die Tabelle mit den Daten in der Ods Datei **main** heißt. Würde diese **example1** heißen, würden die Datei `./db/example1_example1.csv` erzeugt und auf diese mit `./db/example1_main.csv` verlinkt werden. Dann könnten die Daten sowohl durch `./db/example1_example1.csv` als auch mit `./db/example1_main.csv` eingelesen werden.

In diesem Abschnitt können auch Daten in Tabellen niedrigerer Level eingelesen werden, sofern für sie ein Tabellenblatt existiert. So ist es möglich, nur von einer Tabelle abhängige Daten in nur einer Ods Datei zu verwalten.

Aus diesem Abschnitt wird die Datei `./db/schema_loaddata.sql erzeugt`. Diese kann mit `mariadb --user=db_user --password=db_password --database=db_db < ./db/schema_loaddata.sql` in der Datenbank ausgeführt werden. `make db` führt diesen Schritt nach dem [Erzeugen der Tabellen](#anton_CREATE_TABLE) aus.


### 5.2.4. <a id="anton_DROP_TABLE"></a>Remove Table(s)

Dieser Abschnitt ist der fünfte Abschnitt. Er enthält "DROP TABLE" Befehle für das Schema SCHEMA. In ihm werden alle Tabellen zum Löschen aufgeführt, die im vierten Abschnitt erzeugt werden.

Die Befehle werden von oben nach unten ausgeführt. Bei Abhängigkeiten müssen die Tabellen in umgekehrter Reihenfolge ihrer Erzeugung gelöscht werden.

Aus diesem Abschnitt wird die Datei `./db/schema_drop.sql erzeugt`. Diese kann mit `mariadb --user=db_user --password=db_password --database=db_db < ./db/schema_drop.sql` in der Datenbank ausgeführt werden. `make dbclean` führt diesen Schritt nach dem [**Löschen von Daten niedriger Level**](#anton_DELETE_FROM_TABLE) aus.

### 5.2.5. <a id="anton_DELETE_FROM_TABLE"></a>Delete Lower Level Daten

Dieser Abschnitt ist der sechste Abschnitt. Er enthält "DELETE FROM " Befehle für Daten von lower level Schema .

Ein Schema kann bei Erzeugung auch Daten in Tabellen niedrigerer Level einlesen. Es ist möglich dass Datensätze von Tabellen des Schema von diesen Daten abhängig sind. Diese kann man in diesem Abschnitt entfernen.

Mit `make SCHEMA` kann man die Tabellen nur eines Schema neu erzeugen. Dabei werden die Datenbanktabellen neu erzeugt und die Daten neu eingelesen. Sofern Daten niedrigerer Level in [**Read Data in**](#anton_LOAD_DATA) angegeben wurden,werden diese dabei auch mit neu eingelesen. Wenn sie bereits vorhanden sind, gibt **mariadb** Fehlermeldungen aus.

Dieser Abschnitt kann auch leer bleiben. Die Fehlermeldungen führen nicht zu Fehlern - der Datensatz wird nicht zweimal eingelesen. Führt man `make` immer nur vollständig aus, kann es sowieso keine Versuche doppelter Einträge geben.

Aus diesem Abschnitt wird die Datei `./db/schema_delete.sql erzeugt`. Diese kann mit `mariadb --user=db_user --password=db_password --database=db_db < ./db/schema_delete.sql` in der Datenbank ausgeführt werden. `make dbclean` führt diesen Schritt vor dem [**Remove Table**](#anton_DROP_TABLE) aus.

### 5.2.6. <a id="anton_SELECT_FROM"></a>Abfragen

Dieser Abschnitt ist der zweite Abschnitt. Er enthält "SELECT" Befehle. Er kann prinzipiell Abfragen über alle Tabellen dieses Schema und niedrigerer Level enthalten.

Aus diesem Abschnitt  werden die Dateien `./db/schema_select.sql` und `db/SCHEMA_test.sh` erzeugt.

`./db/schema_select.sql` kann mit `mariadb --user=db_user --password=db_password --database=db_db < ./schema_select.sql` in der Datenbank ausgeführt werden. Fehlermeldungen können in der Shell gesehen werden.

In `db/SCHEMA_test.sh` ist jeder SELECT Befehl einzeln als Shell Befehl geschrieben, z.B. `mariadb --user=db_user --password=db_password --database=db_db -e 'SELECT id FROM t;'`. Diese Datei ist ein ausführbares Script. `make test` ruft sie auf.

Auch um die Anzeige über Php Dateien zu erstellen wird `./db/schema_select.sql` verwendet. Alle Befehle, die nicht eine Tabelle des Schema abfragen werden dabei übersprungen. Diese "SELECT" Befehle tauchen in der Anzeige nirgends auf. Deswegen steht im ersten Absatz oben "prinzipiell".

### 5.2.7. <a id="anton_SCHEMA_LEVEL"></a>Level

Dieser Abschnitt ist der dritte Abschnitt. Dieser Abschnitt enthält eine Ziffer von 1 bis 9. Diese Ziffer bestimmt das Level des Schema. Alle Tabellen niedrigerer Level sind immer in der Datenbank vorhanden. Für Tabellen aus Schema gleicher Level ist das nicht sicher.

In diesen Abschnitt kann auch Text geschrieben werden. Dieser wird ignoriert. Stehen mehr als eine Ziffer darin, wird die erste genommen. Der Kommentar wird auch in die Level Datei kopiert. Dort darf keine Ziffer stehen.
Es sind nur 9 Level definierbar.

Aus diesem Abschnitt wird die Datei `./db/schema.lvl` erzeugt. `make db` und `make php` brauchen diese Information, in gewissem Sinne auch `make web`, da der Link Tree auch der statischen Html Seiten die erzeugten Php Seiten nach Leveln sortiert ausgibt.

### 5.2.8. <a id="anton_CSV_Control"></a>CSV Control

Dieser Abschnitt ist der achte und letzte Abschnitt. Er enthält die Steuerungssequenzen zum Konvertieren der Ods Tabellen in Csv Dateien.

Jede Zeile entspricht einem Tabellenblatt, beginnend beim ersten. Tabellenblätter am Ende, für die keine Zeilen existieren, werden nicht konvertiert, sie können beliebigen Inhalt haben.

Möchte man ein Tabellenblatt am Anfang ignorieren, gibt man für dieses Blatt **skip** an. Im Beispiel [`example1.schema`](../example1.schema) ist das erste Tabellenblatt in den Ods Quelldateien eine Dokumentationstabelle. Mit der ersten Zeile **skip** wird dieses erste Tabellenblatt übersprungen.

Für alle anderen Tabellenblätter gibt man **run** an oder einen Formatstring der Form **SpaltenNr/Format/SpaltenNr/Format/...**. Mögliche Formate sind  1 (Standard), 2(Text), 3(MM/DD/YY), 4(DD/MM/YY), 5(YY/MM/DD).

Bei früheren Versionen von **Libre Office** mußte der Formatstring genau die gewollten Spalten enthalten. Mit **Libre Office 7.4.7.2** werden nur Spalten mit Inhalt und alle Spalten mit Inhalt ausgegeben. Kommentare werden nachher vom Framework **txt2db** entfernt.

Die zweite Zeile **1/1/2/2** in [`example1.schema`](../example1.schema)  bezieht sich auf das zweite Tabellenblatt. Dies enthält Daten für die Datenbanktabelle **example1**. Die erste Spalte wird standardmäßig interpretiert, die zweite soll als Text in die Csv Datei geschrieben werden.

Die erzeugte Csv Datei hat dann folgenden Inhalt:
```
1;name1
2;name2
3;name3
...
```

Aus diesem Abschnitt wird die Datei `./db/schema.txt erzeugt`. `./Framework/csv.sh schema` verwendet diese Datei.


## 5.3. <a id="anton_ODS_Dateien"></a>Daten in *.ods Dateien

Die Daten für die Datenbanktabellen sind in Ods Dateien. Die Ods Datei/en für ein Schema liegen in einem Unterverzeichnis von `.db/`. Dieses muß den Namen des Schema haben.

Für ein Schema mehrere **ods** Dateien vorhanden sein, jede davon muss die selben Tabellenblätter mit den selben Spalten enthalten. So können ohne Dateikonflikte verschiedene Personen Daten hinzufügen.

Die **ods** Dateien müssen einen gemeinsamen Basisnamen **SCHEMA** haben, der durch einen Unterstrich vom unterscheidenden Namensteil getrennt wird. Auch wenn nur eine ods Datei vorhanden ist, muss deren Name aus Basisname **SCHEMA**, Unterstrich, Restname bestehen. Der Basisname **SCHEMA** ist der Namen des **Schema**.

Um das zu demonstrieren, gibt es für das Schema **example1** zwei Quelldateien:
```
db/
   example1/
        example1_quelle_1.ods
        example1_quelle_2.ods
example1.schema
```

Beide Ods Dateien enthalten die selben Tabellenblätter. Damit verschiedene Personen sie bearbeiten können, muß man eine Konvention für die Spalten bestimmen, die Werte  enthalten, die in der Datenbank **PRIMARY KEY** sind.

Aus allen Ods Dateien eines Schema wird für jedes Tabellenblatt eine Csv Datei `./db/SCHEMA_TABLE.csv` erstellt. Der unterscheidende Namensteil ist dafür ohne Belang.

## 5.4. Definierende Dateien für die Ausgabe und Datenbankzugriff

### 5.4.1. Allgemeines zu den definierenden Ausgabedaten

Die Ausgabedateien werden aus den `./Framework/*tmpl` Dateien erzeugt. Ans Projekt angepasste Werte kommen aus der Datei [`./Vars`](./Vars) und aus Funktionen in der Datei [`./Framework/tmpl_fus.sh`](./Framework/tmpl_fus.sh). Die Werte aus [`./Vars`](./Vars) ersetzen Platzhalter der Form **%%Schlüssel%%** und die Funktionen aus [`./Framework/tmpl_fus.sh`](./Framework/tmpl_fus.sh) ersetzen funktionale Platzhalter die die Form **%(Schlüssel)%** haben.

Die erzeugten Anzeigedateien inkludieren [`./www/css/txt2db.css`](./www/css/txt2db.css) und [`./www/scripts/txt2db.js`](./www/scripts/txt2db.js). Zusätzlich werden noch Includes erzeugt für `./www/css/Vars%%project%%.css` und `./www/scripts/Vars%%project%%.js`. Diese Dateien werden nicht ausgeliefert.

Die Dateien werden im Verzeichnis `./www` erzeugt. Ist dieses in die Dokument Root eines Servers verlinkt können die Dateien im Browser angesehen werden.

### 5.4.2. web

Es werden fünf statische Html Dateien mit vorgegebenem Inhalt erzeugt: `./www.index.html`, `./www/version.html`, `./www/contact.html`, `./www/imprint.html` und `./www/sitemap.html`. Die entsprechenden Quelldateien sind [`./Framework/index.tmpl`](index.tmpl), [`./Framework/version.tmpl`](version.tmpl), [`./Framework/contact.tmpl`](contact.tmpl), [`./Framework/imprint.tmpl`](imprint.tmpl) und [`./Framework/sitemap.tmpl`](sitemap.tmpl).

### 5.4.3. php
Aus dem Template [`./Framework/vars.tmpl`](vars.tmpl) wird die Datei `./www/vars.php` erzeugt. Diese wird von allen anderen erzeugten Php Dateien inkludiert.

Für jedes Schema und für jede Tabelle jedes Schema wird eine Php Datei im Verzeichnis `./www` erzeugt. Die Template Datei dafür ist [`./Framework/php.tmpl`](php.tmpl).

# 6. Erzeugungsprozess

## 6.1. Erzeugung des Projekt

Als projektspezifische Quelldateien gibt es nur `*.schema` Dateien und `*.ods` Dateien. Zum Start enthält das Verzeichnis `./db` keine Dateien. Die Datenbank enthält keine Tabellen.

`make` erzeugt aus diesen Datenbanktabellen und Php Dateien für die Anzeige im Browser.

Zuerst werden die Schema Dateien gesplittet und teilweise nachbearbeitet. Dies erzeugt Sql, Lvl und Txt Dateien im Verzeichnis `./db`. `make sch` führt nur diesen Schritt aus.

Dann werden aus den Ods Dateien Csv Dateien erstellt. Bei großen Ods Dateien kann das einige Zeit dauern. Dies erzeugt für jede Tabelle eine Csv Datei im Verzeichnis `./db`.  `make csv` führt nur diesen Schritt aus.

Dann werden die Datenbanktabellen erstellt und die Daten eingelesen. `make db` führt nur diesen Schritt aus.

Danach werden die statischen Html Dateien erzeugt. `make web` führt nur diesen Schritt aus.

Zuletzt werden die Php Dateien erzeugt. `make php` führt nur diesen Schritt aus.

## 6.2. Weiterentwicklung

Wenn Sie die [Infrastruktur](#anton_Infrastruktur_Entwickler) aufgesetzt haben, wie beschrieben, werden beim Einchecken in Git die Hooks **pre-commit** und **post-commit** ausgeführt.


[`./.git/hooks/pre-commit`](../.git/hooks/pre-commit) bricht mit exit Code 1 ab, wenn ein "TODO" in den einzucheckenden Dateien gefunden wird. Bei "todo" gibt es nur eine Meldung aus. Für alle **`*.sh`** Dateien führt werden vor dem Einchecken **shellcheck** und der **bats-core** Test für diese Datei ausgeführt. Die Testdateien liegen im Verzeichnis `./test/Framework/bats`. Der Basisname ist wie der der Sh Datei, die Endung ist **.bats**.

Läuft all das Fehlerfrei, wird [`gitcommit.template`](./intern/gitcommit.template) angezeigt.

Hält man sich nun an die Konvention, daß die Kurzbeschreibung für gravierende Änderungen mit **feat!:** beginnt, die für einfache neue Features aber mit **feat:** und die Kurzbeschreibung für Bugfixes mit **fix:**, so wird mit dem [`./.git/hooks/post-commit`](../.git/hooks/post-commit) ein Tag für jede Feature verändernde Version erzeugt.

# 7. Benefits

Die [Aufgaben](#anton_Aufgaben) sind gelöst, die Ziele erfüllt.


# 9. Ausblick

Man könnte anstelle von Php Dateien aus den Datenbankwerten auch Html Dateien erzeugen, indem man die Datenbankabfragen vor dem Erstellen der Ausgabedateien ausführt und die Werte in Html Tabellen ausgibt. Damit wäre für die Anzeige im Browser kein Server mehr notwendig.

Ebenso ist angedacht, in der Php Version weitere Anfragen formulieren zu können.



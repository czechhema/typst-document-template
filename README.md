# Šablona pro dokument ČHA pro systém Typst

Tento repozitář obsahuje šablonu pro sázací systém [Typst](https://typst.app/docs) pro psaní legislativních dokumentů ČHA - stanovy, řády, směrnice.

## Instalace

Balík není zveřejněn v oficiálním repozitáři balíků Typstu, je tedy nutné si jej nainstalovat lokálně.

Lokální balíky se umisťují do adresáře `<data-dir>/typst/packages/<namespace>/<jméno balíku>/<verze>`, kde `<data-dir>` je podle operačního systému:

* Linux: `$XDG_DATA_HOME` nebo `~/.local/share`
* MacOS: `~/Library/Application Support`
* Windows: `%APPDATA%`, což je `C:\Users\<username>\AppData`

Hodnoty `<namespace>`, `<jméno balíku>` a `<verze>` jsou pak víceméně jedno, jen verze by měla být ve tvaru `X.Y.Z`.
Do tohoto adresáře je potřeba umístit obsah tohoto repozitáře, resp. soubory `lib.typ` a `typst.toml`.

Ve zbytku tohoto návodu se předpokládá, že `<namespace> = local`, `<jméno balíku> = cha-doc` a `<verze> = 0.0.1`.

## Použití

Na začátku hlavního dokumentu se napíše

```language: typst
#import "@local/cha-doc:0.0.1": conf, stanovy, rad, smernice, aref, rref, lref // a případně další funkce a proměnné z šablony
// případné další importy

#show: conf.with(
  doc-type: smernice, // možné hodnoty: stanovy, rad, smernice; musí být importováno, viz výše
)
```

a dále pokračuje samotný dokument:

```language: typst
// nečíslovaná sekce - zařídí se přidáním <unnumbered>
= Preambule <unnumbered>
Text text text...

// číslovaná sekce, a to Čl. <římská číslice>
// Ono "Čl." ani číslice se nepíšou, doplňuje se samo
// Toto by se vysázelo jako:
//        Čl. I
//   Úvodní ustanovení
= Úvodní ustanovení
+ Odstavec - čísla 1., 2., ...
+ Odstavec s větším množstvím textu.
  Další řádky nemají na plynutí textu vliv,
  budou normálně za sebou, ale ve zdrojovém
  dokumentu musejí být zarovnány stejně jako
  první věta odstavce, akorát tam není to "+"
  ale mezera.
+ Má-li odstavec ve smyslu členění dokumentu být složen
  z více odstavců ve smyslu sázení, oddělí se prázdným
  řádkem, ale musí být zachováno odsazení.

  Tady začíná druhý sázený odstavec v rámci téhož
  odstavce-položky.
+ Odstavec
  + Písmeno - písmena a), b), ...
  + Písmeno
    + Bod - římské číslice malými písmeny (i), (ii), ...
    + Hlubší zanoření než toto šablona nepodporuje.

= Další sekce
+ Odstavec
  - nečíslovaný seznam
  - položky budou odražené černými puntíky
+ Ostavec
  + Písmeno, na které se později odkazuje <label>
+ Relativní reference: @label nebo #rref(<label>)
  napíše referenci relativně k místu, odkud se ukazuje,
  tedy v tomto případě by to byl jen odst. 2 písm. a;
  Čl. II už by se nepsalo.
+ Absolutní reference: #aref(<label>)
  napíše plnou referenci, tzn. v tomto případě
  Čl. II odst. 2 písm. a
+ Reference na poslední úroveň: #lref(<label>)
  napíše referenci na poslední element hierarchie,
  tedy v tomto případě by to bylo jen písm. a.
```

### Poznámka k referencím
Chování popsané na příkladu výše je chování při výchozím nastavení.
Když se v `#show: conf.with(...)` uvede `relative-refs: false`, tak všechny `@reference` budou absolutní místo relativních.
Na použití `rref`, `aref` a `lref` to nic nemění, jde jen o chování zavináčové zkratky.

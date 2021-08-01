/* 3701123 - Pascal ZHUANG
   EXERCICE 1 - 1ère DTD :
   L'éxécution de ce programme génère un fichier XML : Ex1_1_XML.xml
   Il faut ajouter manuellement <!DOCTYPE mondial SYSTEM "Ex1_1_DTD.dtd"> à la première ligne du fichier généré.
   Ce programme met environ 14s à finir
*/


-- CREATION DE TYPES ET TABLES :

/* Pour chaque type d'objet, on cherche le contenu dans la Database Explorer puis on sélectionne 
   seulement les colonnes qui nous sont utiles. Chaque type possède une méthode toXML permettant 
   de transformer un type objet en xml. */


-- AIRPORT  
/*  
    <!ELEMENT airport EMPTY>
    <!ATTLIST airport name CDATA #REQUIRED 
                      nearCity CDATA #IMPLIED > 
*/
drop type T_Airport force;
/
create or replace  type T_Airport as object (
-- On reprend les mêmes types de données que ceux de la Database.
   NAME            VARCHAR2(100 Byte),
   COUNTRY         VARCHAR2(4 Byte),
   CITY            VARCHAR2(50 Byte),

-- Signature de la méthode toXML permettant la conversion du type objet vers le xml, tout en respectant la DTD fournie.
   member function toXML return XMLType
)
/
-- Corps de la méthode toXML
create or replace type body T_Airport as
 member function toXML return XMLType is
   -- output est la variable contenant le résultat de la conversion en langage xml.
   output XMLType;
   begin
   /* L'attribut nearCity étant en #IMPLIED, doit être ajoutée que lorsqu'elle est présente dans la base de données.
   Cette présence est vérifiée avec une condition if.
   XMLType.appendchildxml est utilisée uniquement lorsque l'élément possède un ou plusieurs éléments fils.*/       
      if city is not null then
        output := XMLType.createxml('<airport name="'||name||'" nearCity="'||city||'" />');
      else
        output := XMLType.createxml('<airport name="'||name||'"/>');
      end if;
      return output;
   end;
end;
/
drop table LesAirports;
/
create table LesAirports of T_Airport;
/
create or replace type T_ensAirports as table of T_Airport;
/

-- CONTINENT
/*
    <!ELEMENT continent EMPTY >
    <!ATTLIST continent name CDATA #REQUIRED 
                        percent CDATA #REQUIRED >
*/
drop type T_Continent force;
/
create or replace  type T_Continent as object (
-- On reprend les mêmes types de données que ceux de la Database
   NAME           VARCHAR2(20 Byte),
   CODEPAYS       VARCHAR2(4),
   PERCENT        NUMBER,

-- Signature de la méthode toXML permettant la conversion du type objet vers le xml, tout en respectant la DTD fournie  
   member function toXML return XMLType
)
/
-- Corps de la méthode toXML
create or replace type body T_Continent as
 member function toXML return XMLType is
   output XMLType;
   begin
      output := XMLType.createxml('<continent name="'||name||'" percent="'||percent||'" />');
      return output;
   end;
end;
/
drop table LesContinents;
/
create table LesContinents of T_Continent;
/
create or replace type T_ensContinents as table of T_Continent;
/

-- COORDINATES
/*
    <!ELEMENT coordinates EMPTY >
    <!ATTLIST coordinates latitude CDATA #REQUIRED
                          longitude CDATA #REQUIRED>
*/
drop type T_Coordinates force;
/
create or replace  type T_Coordinates as object (
-- On reprend les mêmes types de données que ceux de la Database
   LATITUDE     NUMBER,
   LONGITUDE    NUMBER,

-- Signature de la méthode toXML permettant la conversion du type objet vers le xml, tout en respectant la DTD fournie  
   member function toXML return XMLType
)
/
-- Corps de la méthode toXML
create or replace type body T_Coordinates as
 member function toXML return XMLType is
   output XMLType;
   begin
      --Ce type est directement converti dans la méthode toXML de T_Island car c'est un élément vide qui apparait zéro ou une fois dans chaque Island.
      return output;
   end;
end;
/

-- ISLAND
/*
    <!ELEMENT island (coordinates?) >
    <!ATTLIST island name CDATA #REQUIRED >
*/
drop type T_Island force;
/
create or replace  type T_Island as object (
-- On reprend les mêmes types de données que ceux de la Database
   NAME             VARCHAR2(35 Byte),
   COORDINATES      T_Coordinates, -- T_Coordinates représentera le type GEOCOORD
   CODE_PROVINCE     VARCHAR2(35 Byte),

-- Signature de la méthode toXML permettant la conversion du type objet vers le xml, tout en respectant la DTD fournie    
   member function toXML return XMLType
)
/
-- Corps de la méthode toXML
create or replace type body T_Island as
 member function toXML return XMLType is
   output XMLType;
   begin
    /* L'élément Island pouvant ne pas avoir de coordonnées dans la base de données, doit être ajoutée en tant qu'élément fils
    que lorsqu'elle est présente dans la base de données. Cette présence est vérifiée avec une condition if.*/
      output := XMLType.createxml('<island name="'||name||'"/>');
      if coordinates is not null
      then
          -- on récupère la latitude et la longitude dans l'objet COORDINATES et on ajoute un élément fils avec XMLType.appendchildxml.
          output := XMLType.appendchildxml(output,'island', XMLType('<coordinates latitude="'||COORDINATES.Latitude||'" longitude="'||COORDINATES.Longitude||'" />'));
      end if;
      return output;
   end;
end;
/
drop table LesIslands;
/
create table LesIslands of T_Island;
/
create or replace type T_ensIslands as table of T_Island;
/

-- DESERT
/*
    <!ELEMENT desert EMPTY >
    <!ATTLIST desert name CDATA #REQUIRED 
                     area CDATA #IMPLIED >
*/
drop type T_Desert force;
/
create or replace  type T_Desert as object (
-- On reprend les mêmes types de données que ceux de la Database
   NAME               VARCHAR2(35 Byte),
   AREA               NUMBER,
   CODE_PROVINCE       VARCHAR2(35 Byte),

-- Signature de la méthode toXML permettant la conversion du type objet vers le xml, tout en respectant la DTD fournie       
   member function toXML return XMLType
)
/
-- Corps de la méthode toXML
create or replace type body T_Desert as
 member function toXML return XMLType is
   output XMLType;
   begin
   /* L'attribut area étant en #IMPLIED, doit être ajoutée que lorsqu'elle est présente dans la base de données.
   Cette présence est vérifiée avec une condition if. */ 
      if area is null then
        output := XMLType.createxml('<desert name="'||name||'"/>');
      else
        output := XMLType.createxml('<desert name="'||name||'" area="'||area||'"/>');
      end if;
      return output;
   end;
end;
/
drop table LesDeserts;
/
create table LesDeserts of T_Desert;
/
create or replace type T_ensDeserts as table of T_Desert;
/

-- MOUNTAIN
/*
    <!ELEMENT mountain EMPTY >
    <!ATTLIST mountain name CDATA #REQUIRED 
                       height CDATA #REQUIRED >
*/
drop type T_Mountain force;
/
create or replace  type T_Mountain as object (
-- On reprend les mêmes types de données que ceux de la Database
   NAME             VARCHAR2(35 Byte),
   HEIGHT           NUMBER,
   CODE_PROVINCE    VARCHAR2(35 Byte),

-- Signature de la méthode toXML permettant la conversion du type objet vers le xml, tout en respectant la DTD fournie     
   member function toXML return XMLType
)
/
-- Corps de la méthode toXML
create or replace type body T_Mountain as
 member function toXML return XMLType is
   output XMLType;
   begin
      output := XMLType.createxml('<mountain name="'||name||'" height="'||height||'"/>');
      return output;
   end;
end;
/
drop table LesMontagnes;
/
create table LesMontagnes of T_Mountain;
/
create or replace type T_ensMontagnes as table of T_Mountain;
/

-- PROVINCE
/*
    <!ELEMENT province ( (mountain|desert)*, island* ) >
    <!ATTLIST province name CDATA #REQUIRED 
                       capital CDATA #REQUIRED >
*/
drop type T_Province force;
/
create or replace  type T_Province as object (
-- On reprend les mêmes types de données que ceux de la Database
   NAME_PROVINCE    VARCHAR2(35 Byte),
   COUNTRY          VARCHAR2(4 Byte),
   CAPITAL          VARCHAR2(35 Byte),

-- Signature de la méthode toXML permettant la conversion du type objet vers le xml, tout en respectant la DTD fournie     
   member function toXML return XMLType
)
/
-- Corps de la méthode toXML
create or replace type body T_Province as
 member function toXML return XMLType is
/* Les éléments fils de l'élément Province pouvant ne pas être présents dans la base de données ou apparaître une ou plusieurs fois,
   on choisira alors d'utiliser des ensembles pour stocker ces données. */
   output XMLType;
   tmpMontagnes T_ensMontagnes;
   tmpDeserts T_ensDeserts;
   tmpIslands T_ensIslands;
   begin
      output := XMLType.createxml('<province name="'||NAME_Province||'" capital="'||capital||'"/>');
      /* On récupère d'abord dans une variable ensembliste de type T_ensMontagnes, toutes les montagnes de la province grâce à une requête
         parcourant une table contenant toutes les montagnes, avec une jointure sur le code de la province. Et on itère ensuite dans l'ensemble 
         pour ajouter un élément fils pour chacunes des montagnes. Les éléments fils d'un élément sont ajoutés avec XMLType.appendchildxml. */
      select value(m) bulk collect into tmpMontagnes 
      from LesMontagnes m
      where m.code_province = name_province;
      for indx IN 1..tmpMontagnes.COUNT
      loop
         output := XMLType.appendchildxml(output,'province', tmpMontagnes(indx).toXML());   
      end loop;
      
      /* On récupère d'abord dans une variable ensembliste de type T_ensDeserts, tous les déserts de la province grâce à une requête
         parcourant une table contenant tous les déserts, avec une jointure sur le code de la province. Et on itère ensuite dans l'ensemble 
         pour ajouter un élément fils pour chacuns des déserts. Les éléments fils d'un élément sont ajoutés avec XMLType.appendchildxml. */
      select value(d) bulk collect into tmpDeserts
      from LesDeserts d
      where d.code_province = name_province;  
      for indx IN 1..tmpDeserts.COUNT
      loop
         output := XMLType.appendchildxml(output,'province', tmpDeserts(indx).toXML());   
      end loop;
      
      /* On récupère d'abord dans une variable ensembliste de type T_ensIslands, toutes les iles de la province grâce à une requête
         parcourant une table contenant toutes les iles, avec une jointure sur le code de la province. Et on itère ensuite dans l'ensemble
         pour ajouter un élément fils pour chacunes des iles. Les éléments fils d'un élément sont ajoutés avec XMLType.appendchildxml. */
      select value(i) bulk collect into tmpIslands
      from LesIslands i
      where i.code_province = name_province;  
      for indx IN 1..tmpIslands.COUNT
      loop
         output := XMLType.appendchildxml(output,'province', tmpIslands(indx).toXML());   
      end loop;
      
      return output;
   end;
end;
/
drop table LesProvinces;
/
create table LesProvinces of T_Province;
/
create or replace type T_ensProvinces as table of T_Province;
/

-- COUNTRY
/*
    <!ELEMENT country (continent+, province+, airport*) >
    <!ATTLIST country idcountry ID #REQUIRED
                      nom CDATA #REQUIRED>
*/
drop type T_Country force;
/
create or replace  type T_Country as object (
-- On reprend les mêmes types de données que ceux de la Database
   NAME         VARCHAR2(35 Byte),
   CODE         VARCHAR2(4 Byte),
   CAPITAL      VARCHAR2(35 Byte),
   PROVINCE     VARCHAR2(35 Byte),
   AREA         NUMBER,
   POPULATION   NUMBER,

-- Signature de la méthode toXML permettant la conversion du type objet vers le xml, tout en respectant la DTD fournie     
   member function toXML return XMLType
)
/
-- Corps de la méthode toXML
create or replace type body T_Country as
 member function toXML return XMLType is
/* Les éléments fils de l'élément Country pouvant soit ne pas être présents dans la base de données ou apparaître une ou plusieurs fois (*),
   soit être présents au moins une fois (+), on choisira alors d'utiliser des ensembles pour stocker ces données. */
   output XMLType;
   tmpcontinents T_ensContinents;
   tmpprovinces T_ensProvinces;
   tmpairports T_ensAirports;
   begin
      output := XMLType.createxml('<country idcountry="'||code||'" nom="'||name||'"/>');
      /* On récupère d'abord dans une variable ensembliste de type T_ensContinents, tous les continents où se situe le pays grâce à une requête
         parcourant une table contenant tous les continents, avec une jointure sur le code du pays. Et on itère ensuite dans l'ensemble pour ajouter
         un élément fils pour chacuns des continents. Les éléments fils d'un élément sont ajoutés avec XMLType.appendchildxml. */
      select value(c) bulk collect into tmpcontinents
      from LesContinents c
      where c.codepays = code;  
      for indx IN 1..tmpcontinents.COUNT
      loop
         output := XMLType.appendchildxml(output,'country', tmpcontinents(indx).toXML());   
      end loop;
      
      /* On récupère d'abord dans une variable ensembliste de type T_ensProvinces, toutes les provinces du pays grâce à une requête
         parcourant une table contenant toutes les provinces, avec une jointure sur le code du pays. Et on itère ensuite dans l'ensemble pour ajouter
         un élément fils pour chacunes des provinces. Les éléments fils d'un élément sont ajoutés avec XMLType.appendchildxml. */
      select value(p) bulk collect into tmpprovinces
      from LesProvinces p
      where p.country = code;  
      for indx IN 1..tmpprovinces.COUNT
      loop
         output := XMLType.appendchildxml(output,'country', tmpprovinces(indx).toXML());   
      end loop;
      
      /* On récupère d'abord dans une variable ensembliste de type T_ensAirports, tous les aéroports du pays grâce à une requête
         parcourant une table contenant tous les aéroports, avec une jointure sur le code du pays. Et on itère ensuite dans l'ensemble pour ajouter 
         un élément fils pour chacuns des aéroports. Les éléments fils d'un élément sont ajoutés avec XMLType.appendchildxml. */
      select value(a) bulk collect into tmpairports
      from LesAirports a
      where a.country = code;  
      for indx IN 1..tmpairports.COUNT
      loop
         output := XMLType.appendchildxml(output,'country', tmpairports(indx).toXML());   
      end loop;
      
      return output;
   end;
end;
/
drop table LesCountrys;
/
create table LesCountrys of T_Country;
/
create or replace type T_ensCountrys as table of T_Country;
/

-- MONDIAL
/*
    <!ELEMENT mondial (country+) >
*/
drop type T_Mondial force;
/
create or replace  type T_Mondial as object (
-- Nom arbitraire du monde, utile pour pouvoir créer ce type
   NAME VARCHAR2(20),

-- Signature de la méthode toXML permettant la conversion du type objet vers le xml, tout en respectant la DTD fournie  
   member function toXML return XMLType
);
/
-- Corps de la méthode toXML
create or replace type body T_Mondial as
 member function toXML return XMLType is
 /* Les éléments fils de l'élément Mondial devant apparaître au moins une fois, on choisira alors d'utiliser un ensemble
    pour stocker ces données. */
   output XMLType;
   tmpcountrys T_ensCountrys;
   begin
      output := XMLType.createxml('<mondial/>');
      /* On récupère d'abord dans une variable ensembliste de type T_ensCountrys, tous les pays du monde grâce à une requête
         parcourant une table contenant tous les pays. Et on itère ensuite dans l'ensemble pour ajouter un élément fils pour chacuns 
         des pays. Les éléments fils d'un élément sont ajoutés avec XMLType.appendchildxml. */
      select value(c) bulk collect into tmpcountrys
      from LesCountrys c;
      -- pas de condition car on veut tous les pays de la base.
      for indx IN 1..tmpcountrys.COUNT
      loop
         output := XMLType.appendchildxml(output,'mondial', tmpcountrys(indx).toXML());   
      end loop;
      
      return output;
   end;
end;
/
drop table LeMonde;
/
create table LeMonde of T_Mondial;
/

-- INSERTIONS

-- Création et insertion du monde
insert into LeMonde values(T_Mondial('Le monde'));

-- Création et insertion des objets Country dans la table contenant les pays, en parcourant la base des pays : COUNTRY
insert into LesCountrys
    select T_Country(c.name, c.code, c.capital, c.province, c.area, c.population) 
    from COUNTRY c;

-- Création et insertion des objets Province dans la table contenant les provinces, en parcourant la base des provinces : PROVINCE      
insert into LesProvinces
    select T_Province(p.name, p.country, p.capital) 
    from PROVINCE p;

-- Création et insertion des objets Montagne dans la table contenant les montagnes,
-- en parcourant la base MOUNTAIN et GEO_MOUTAIN avec une jointure sur le nom des montagnes                     
insert into LesMontagnes
    select T_Mountain(m.name, m.height, g.province) 
    from MOUNTAIN m, GEO_MOUNTAIN g
    where m.name = g.mountain;

-- Création et insertion des objets Desert dans la table contenant les déserts,
-- en parcourant la base DESERT et GEO_DESERT avec une jointure sur le nom des déserts         
insert into LesDeserts
    select T_Desert(d.name, d.area, gd.province) 
    from DESERT d, GEO_DESERT gd
    where d.name = gd.desert;

-- Création et insertion des objets Island dans la table contenant les îles,
-- en parcourant la base ISLAND et GEO_ISLAND avec une jointure sur le nom des îles          
insert into LesIslands
    select T_Island(i.name, T_Coordinates(i.COORDINATES.latitude, i.COORDINATES.longitude), gi.province) 
    from ISLAND i, GEO_ISLAND gi
    where i.name = gi.Island;

-- Création et insertion des objets Continent dans la table contenant les continents,
-- en parcourant la base CONTINENT et ENCOMPASSES avec une jointure sur le nom des continents 
insert into LesContinents
    select T_Continent(c.name, e.country, e.percentage) 
    from CONTINENT c, ENCOMPASSES e
    where c.name = e.continent;

-- Création et insertion des objets Airport dans la table contenant les aéroports, en parcourant la base des aéroports: AIRPORT 
insert into LesAirports
    select T_Airport(a.name, a.country, a.city) 
    from AIRPORT a;
      
-- exporter le resultat dans un fichier 
WbExport -type=text
         -file='Ex1_1_XML.xml'
         -createDir=true
         -encoding=UTF-8
         -header=false
         -delimiter=','
         -decimal=','
         -dateFormat='yyyy-MM-dd'
/

-- affichage du monde en xml
select m.toXML().getClobVal() 
from LeMonde m;
/

/* 3701123 - Pascal ZHUANG
   EXERCICE 1 - 1�re DTD :
   L'�x�cution de ce programme g�n�re un fichier XML : Ex1_1_XML.xml
   Il faut ajouter manuellement <!DOCTYPE mondial SYSTEM "Ex1_1_DTD.dtd"> � la premi�re ligne du fichier g�n�r�.
   Ce programme met environ 14s � finir
*/


-- CREATION DE TYPES ET TABLES :

/* Pour chaque type d'objet, on cherche le contenu dans la Database Explorer puis on s�lectionne 
   seulement les colonnes qui nous sont utiles. Chaque type poss�de une m�thode toXML permettant 
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
-- On reprend les m�mes types de donn�es que ceux de la Database.
   NAME            VARCHAR2(100 Byte),
   COUNTRY         VARCHAR2(4 Byte),
   CITY            VARCHAR2(50 Byte),

-- Signature de la m�thode toXML permettant la conversion du type objet vers le xml, tout en respectant la DTD fournie.
   member function toXML return XMLType
)
/
-- Corps de la m�thode toXML
create or replace type body T_Airport as
 member function toXML return XMLType is
   -- output est la variable contenant le r�sultat de la conversion en langage xml.
   output XMLType;
   begin
   /* L'attribut nearCity �tant en #IMPLIED, doit �tre ajout�e que lorsqu'elle est pr�sente dans la base de donn�es.
   Cette pr�sence est v�rifi�e avec une condition if.
   XMLType.appendchildxml est utilis�e uniquement lorsque l'�l�ment poss�de un ou plusieurs �l�ments fils.*/       
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
-- On reprend les m�mes types de donn�es que ceux de la Database
   NAME           VARCHAR2(20 Byte),
   CODEPAYS       VARCHAR2(4),
   PERCENT        NUMBER,

-- Signature de la m�thode toXML permettant la conversion du type objet vers le xml, tout en respectant la DTD fournie  
   member function toXML return XMLType
)
/
-- Corps de la m�thode toXML
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
-- On reprend les m�mes types de donn�es que ceux de la Database
   LATITUDE     NUMBER,
   LONGITUDE    NUMBER,

-- Signature de la m�thode toXML permettant la conversion du type objet vers le xml, tout en respectant la DTD fournie  
   member function toXML return XMLType
)
/
-- Corps de la m�thode toXML
create or replace type body T_Coordinates as
 member function toXML return XMLType is
   output XMLType;
   begin
      --Ce type est directement converti dans la m�thode toXML de T_Island car c'est un �l�ment vide qui apparait z�ro ou une fois dans chaque Island.
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
-- On reprend les m�mes types de donn�es que ceux de la Database
   NAME             VARCHAR2(35 Byte),
   COORDINATES      T_Coordinates, -- T_Coordinates repr�sentera le type GEOCOORD
   CODE_PROVINCE     VARCHAR2(35 Byte),

-- Signature de la m�thode toXML permettant la conversion du type objet vers le xml, tout en respectant la DTD fournie    
   member function toXML return XMLType
)
/
-- Corps de la m�thode toXML
create or replace type body T_Island as
 member function toXML return XMLType is
   output XMLType;
   begin
    /* L'�l�ment Island pouvant ne pas avoir de coordonn�es dans la base de donn�es, doit �tre ajout�e en tant qu'�l�ment fils
    que lorsqu'elle est pr�sente dans la base de donn�es. Cette pr�sence est v�rifi�e avec une condition if.*/
      output := XMLType.createxml('<island name="'||name||'"/>');
      if coordinates is not null
      then
          -- on r�cup�re la latitude et la longitude dans l'objet COORDINATES et on ajoute un �l�ment fils avec XMLType.appendchildxml.
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
-- On reprend les m�mes types de donn�es que ceux de la Database
   NAME               VARCHAR2(35 Byte),
   AREA               NUMBER,
   CODE_PROVINCE       VARCHAR2(35 Byte),

-- Signature de la m�thode toXML permettant la conversion du type objet vers le xml, tout en respectant la DTD fournie       
   member function toXML return XMLType
)
/
-- Corps de la m�thode toXML
create or replace type body T_Desert as
 member function toXML return XMLType is
   output XMLType;
   begin
   /* L'attribut area �tant en #IMPLIED, doit �tre ajout�e que lorsqu'elle est pr�sente dans la base de donn�es.
   Cette pr�sence est v�rifi�e avec une condition if. */ 
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
-- On reprend les m�mes types de donn�es que ceux de la Database
   NAME             VARCHAR2(35 Byte),
   HEIGHT           NUMBER,
   CODE_PROVINCE    VARCHAR2(35 Byte),

-- Signature de la m�thode toXML permettant la conversion du type objet vers le xml, tout en respectant la DTD fournie     
   member function toXML return XMLType
)
/
-- Corps de la m�thode toXML
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
-- On reprend les m�mes types de donn�es que ceux de la Database
   NAME_PROVINCE    VARCHAR2(35 Byte),
   COUNTRY          VARCHAR2(4 Byte),
   CAPITAL          VARCHAR2(35 Byte),

-- Signature de la m�thode toXML permettant la conversion du type objet vers le xml, tout en respectant la DTD fournie     
   member function toXML return XMLType
)
/
-- Corps de la m�thode toXML
create or replace type body T_Province as
 member function toXML return XMLType is
/* Les �l�ments fils de l'�l�ment Province pouvant ne pas �tre pr�sents dans la base de donn�es ou appara�tre une ou plusieurs fois,
   on choisira alors d'utiliser des ensembles pour stocker ces donn�es. */
   output XMLType;
   tmpMontagnes T_ensMontagnes;
   tmpDeserts T_ensDeserts;
   tmpIslands T_ensIslands;
   begin
      output := XMLType.createxml('<province name="'||NAME_Province||'" capital="'||capital||'"/>');
      /* On r�cup�re d'abord dans une variable ensembliste de type T_ensMontagnes, toutes les montagnes de la province gr�ce � une requ�te
         parcourant une table contenant toutes les montagnes, avec une jointure sur le code de la province. Et on it�re ensuite dans l'ensemble 
         pour ajouter un �l�ment fils pour chacunes des montagnes. Les �l�ments fils d'un �l�ment sont ajout�s avec XMLType.appendchildxml. */
      select value(m) bulk collect into tmpMontagnes 
      from LesMontagnes m
      where m.code_province = name_province;
      for indx IN 1..tmpMontagnes.COUNT
      loop
         output := XMLType.appendchildxml(output,'province', tmpMontagnes(indx).toXML());   
      end loop;
      
      /* On r�cup�re d'abord dans une variable ensembliste de type T_ensDeserts, tous les d�serts de la province gr�ce � une requ�te
         parcourant une table contenant tous les d�serts, avec une jointure sur le code de la province. Et on it�re ensuite dans l'ensemble 
         pour ajouter un �l�ment fils pour chacuns des d�serts. Les �l�ments fils d'un �l�ment sont ajout�s avec XMLType.appendchildxml. */
      select value(d) bulk collect into tmpDeserts
      from LesDeserts d
      where d.code_province = name_province;  
      for indx IN 1..tmpDeserts.COUNT
      loop
         output := XMLType.appendchildxml(output,'province', tmpDeserts(indx).toXML());   
      end loop;
      
      /* On r�cup�re d'abord dans une variable ensembliste de type T_ensIslands, toutes les iles de la province gr�ce � une requ�te
         parcourant une table contenant toutes les iles, avec une jointure sur le code de la province. Et on it�re ensuite dans l'ensemble
         pour ajouter un �l�ment fils pour chacunes des iles. Les �l�ments fils d'un �l�ment sont ajout�s avec XMLType.appendchildxml. */
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
-- On reprend les m�mes types de donn�es que ceux de la Database
   NAME         VARCHAR2(35 Byte),
   CODE         VARCHAR2(4 Byte),
   CAPITAL      VARCHAR2(35 Byte),
   PROVINCE     VARCHAR2(35 Byte),
   AREA         NUMBER,
   POPULATION   NUMBER,

-- Signature de la m�thode toXML permettant la conversion du type objet vers le xml, tout en respectant la DTD fournie     
   member function toXML return XMLType
)
/
-- Corps de la m�thode toXML
create or replace type body T_Country as
 member function toXML return XMLType is
/* Les �l�ments fils de l'�l�ment Country pouvant soit ne pas �tre pr�sents dans la base de donn�es ou appara�tre une ou plusieurs fois (*),
   soit �tre pr�sents au moins une fois (+), on choisira alors d'utiliser des ensembles pour stocker ces donn�es. */
   output XMLType;
   tmpcontinents T_ensContinents;
   tmpprovinces T_ensProvinces;
   tmpairports T_ensAirports;
   begin
      output := XMLType.createxml('<country idcountry="'||code||'" nom="'||name||'"/>');
      /* On r�cup�re d'abord dans une variable ensembliste de type T_ensContinents, tous les continents o� se situe le pays gr�ce � une requ�te
         parcourant une table contenant tous les continents, avec une jointure sur le code du pays. Et on it�re ensuite dans l'ensemble pour ajouter
         un �l�ment fils pour chacuns des continents. Les �l�ments fils d'un �l�ment sont ajout�s avec XMLType.appendchildxml. */
      select value(c) bulk collect into tmpcontinents
      from LesContinents c
      where c.codepays = code;  
      for indx IN 1..tmpcontinents.COUNT
      loop
         output := XMLType.appendchildxml(output,'country', tmpcontinents(indx).toXML());   
      end loop;
      
      /* On r�cup�re d'abord dans une variable ensembliste de type T_ensProvinces, toutes les provinces du pays gr�ce � une requ�te
         parcourant une table contenant toutes les provinces, avec une jointure sur le code du pays. Et on it�re ensuite dans l'ensemble pour ajouter
         un �l�ment fils pour chacunes des provinces. Les �l�ments fils d'un �l�ment sont ajout�s avec XMLType.appendchildxml. */
      select value(p) bulk collect into tmpprovinces
      from LesProvinces p
      where p.country = code;  
      for indx IN 1..tmpprovinces.COUNT
      loop
         output := XMLType.appendchildxml(output,'country', tmpprovinces(indx).toXML());   
      end loop;
      
      /* On r�cup�re d'abord dans une variable ensembliste de type T_ensAirports, tous les a�roports du pays gr�ce � une requ�te
         parcourant une table contenant tous les a�roports, avec une jointure sur le code du pays. Et on it�re ensuite dans l'ensemble pour ajouter 
         un �l�ment fils pour chacuns des a�roports. Les �l�ments fils d'un �l�ment sont ajout�s avec XMLType.appendchildxml. */
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
-- Nom arbitraire du monde, utile pour pouvoir cr�er ce type
   NAME VARCHAR2(20),

-- Signature de la m�thode toXML permettant la conversion du type objet vers le xml, tout en respectant la DTD fournie  
   member function toXML return XMLType
);
/
-- Corps de la m�thode toXML
create or replace type body T_Mondial as
 member function toXML return XMLType is
 /* Les �l�ments fils de l'�l�ment Mondial devant appara�tre au moins une fois, on choisira alors d'utiliser un ensemble
    pour stocker ces donn�es. */
   output XMLType;
   tmpcountrys T_ensCountrys;
   begin
      output := XMLType.createxml('<mondial/>');
      /* On r�cup�re d'abord dans une variable ensembliste de type T_ensCountrys, tous les pays du monde gr�ce � une requ�te
         parcourant une table contenant tous les pays. Et on it�re ensuite dans l'ensemble pour ajouter un �l�ment fils pour chacuns 
         des pays. Les �l�ments fils d'un �l�ment sont ajout�s avec XMLType.appendchildxml. */
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

-- Cr�ation et insertion du monde
insert into LeMonde values(T_Mondial('Le monde'));

-- Cr�ation et insertion des objets Country dans la table contenant les pays, en parcourant la base des pays : COUNTRY
insert into LesCountrys
    select T_Country(c.name, c.code, c.capital, c.province, c.area, c.population) 
    from COUNTRY c;

-- Cr�ation et insertion des objets Province dans la table contenant les provinces, en parcourant la base des provinces : PROVINCE      
insert into LesProvinces
    select T_Province(p.name, p.country, p.capital) 
    from PROVINCE p;

-- Cr�ation et insertion des objets Montagne dans la table contenant les montagnes,
-- en parcourant la base MOUNTAIN et GEO_MOUTAIN avec une jointure sur le nom des montagnes                     
insert into LesMontagnes
    select T_Mountain(m.name, m.height, g.province) 
    from MOUNTAIN m, GEO_MOUNTAIN g
    where m.name = g.mountain;

-- Cr�ation et insertion des objets Desert dans la table contenant les d�serts,
-- en parcourant la base DESERT et GEO_DESERT avec une jointure sur le nom des d�serts         
insert into LesDeserts
    select T_Desert(d.name, d.area, gd.province) 
    from DESERT d, GEO_DESERT gd
    where d.name = gd.desert;

-- Cr�ation et insertion des objets Island dans la table contenant les �les,
-- en parcourant la base ISLAND et GEO_ISLAND avec une jointure sur le nom des �les          
insert into LesIslands
    select T_Island(i.name, T_Coordinates(i.COORDINATES.latitude, i.COORDINATES.longitude), gi.province) 
    from ISLAND i, GEO_ISLAND gi
    where i.name = gi.Island;

-- Cr�ation et insertion des objets Continent dans la table contenant les continents,
-- en parcourant la base CONTINENT et ENCOMPASSES avec une jointure sur le nom des continents 
insert into LesContinents
    select T_Continent(c.name, e.country, e.percentage) 
    from CONTINENT c, ENCOMPASSES e
    where c.name = e.continent;

-- Cr�ation et insertion des objets Airport dans la table contenant les a�roports, en parcourant la base des a�roports: AIRPORT 
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

/* 3701123 - Pascal ZHUANG
   EXERCICE 2 :
   L'éxécution de ce programme génère un fichier XML : Ex2_XML.xml
   Il faut ajouter manuellement <!DOCTYPE ex2 SYSTEM "Ex2_DTD.dtd"> à la première ligne du fichier généré.
*/

-- CREATION DE TYPES ET TABLES :

/* Pour chaque type d'objet, on cherche le contenu dans la Database Explorer puis on sélectionne 
   seulement les colonnes qui nous sont utiles. Chaque type possède une méthode toXML permettant 
   de transformer un type objet en xml. */



-- MOUNTAIN
/*
    <!ELEMENT mountain EMPTY >
    <!ATTLIST mountain name   CDATA #REQUIRED 
                       height CDATA #REQUIRED >
*/
drop type T_Mountain force;
/
create or replace  type T_Mountain as object (
-- On reprend les mêmes types de données que ceux de la Database
   NAME         VARCHAR2(35 Byte),
   MOUNTAINS    VARCHAR2(35 Byte),
   HEIGHT       NUMBER,
   TYPE         VARCHAR2(10 Byte),
   CODEPAYS     Varchar2(30 byte),

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
create table LesMontagnes of T_mountain;
/
create or replace type T_ensMontagnes as table of T_Mountain;
/

--ISLAND
/*
    <!ELEMENT island EMPTY >
    <!ATTLIST island name CDATA #REQUIRED >
*/
drop type T_Island force;
/
create or replace  type T_Island as object (
-- On reprend les mêmes types de données que ceux de la Database, ici les coordonnées des iles ne sont pas interressants, on choisira de ne les remettre
   NOM_ILE     VARCHAR2(35 Byte),
   ISLANDS     VARCHAR2(35 Byte),
   AREA        NUMBER,
   HEIGHT      NUMBER,
   TYPE        VARCHAR2(10 Byte),
   CODEPAYS    VARCHAR2(4 Byte),

-- Signature de la méthode toXML permettant la conversion du type objet vers le xml, tout en respectant la DTD fournie
   member function toXML return XMLType
)
/
-- Corps de la méthode toXML
create or replace type body T_Island as
 member function toXML return XMLType is
   output XMLType;
   begin
      output := XMLType.createxml('<island name="'||nom_ile||'"/>');
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
   NAME     VARCHAR2(35 Byte),
   AREA      NUMBER,
   CODEPAYS   Varchar2(30 byte),
   
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
      if area is not null then
        output := XMLType.createxml('<desert name="'||name||'" area="'||area||'"/>');
      else
        output := XMLType.createxml('<desert name="'||name||'"/>');
      end if;
      return output;
   end;
end;
/
drop table LesDeserts;
/
create table LesDeserts of T_desert;
/
create or replace type T_ensDeserts as table of T_Desert;
/

-- GEO
/*
    <!ELEMENT geo ( (mountain|desert)*, island* ) >
*/
drop type T_Geo force;
/
create or replace  type T_Geo as object (
  CODE_PAYS  VARCHAR2(30 byte),

-- Signature de la méthode toXML permettant la conversion du type objet vers le xml, tout en respectant la DTD fournie  
  member function toXML return XMLType
)
/
-- Corps de la méthode toXML
create or replace type body T_Geo as
 member function toXML return XMLType is
/* Les éléments fils de l'élément Geo pouvant soit ne pas être présents dans la base de données ou apparaître une ou plusieurs fois (*),
   on choisira alors d'utiliser des ensembles pour stocker ces données. */
   output XMLType;
   tmpMontagnes T_ensMontagnes;
   tmpDeserts T_ensDeserts;
   tmpIslands T_ensIslands;
   begin
       output := XMLType.createxml('<geo/>');
       
      /* On récupère d'abord dans une variable ensembliste de type T_ensMontagnes, toutes les montagnes de geo grâce à une requête
         parcourant une table contenant toutes les montagnes, avec une jointure sur le code du pays. Et on itère ensuite dans l'ensemble pour ajouter
         un élément fils pour chacunes des montagnes. Les éléments fils d'un élément sont ajoutés avec XMLType.appendchildxml. */
      select value(m) bulk collect into tmpMontagnes
      from LesMontagnes m
      where m.codepays = code_pays;  
      for indx IN 1..tmpMontagnes.COUNT
      loop
         output := XMLType.appendchildxml(output,'geo', tmpMontagnes(indx).toXML());   
      end loop;
      
      /* On récupère d'abord dans une variable ensembliste de type T_ensDeserts, tous les déserts de geo grâce à une requête
         parcourant une table contenant tous les déserts, avec une jointure sur le code du pays. Et on itère ensuite dans l'ensemble pour ajouter
         un élément fils pour chacuns des déserts. Les éléments fils d'un élément sont ajoutés avec XMLType.appendchildxml. */
      select value(d) bulk collect into tmpDeserts
      from LesDeserts d
      where d.codepays = code_pays ;  
      for indx IN 1..tmpDeserts.COUNT
      loop
         output := XMLType.appendchildxml(output,'geo', tmpDeserts(indx).toXML());   
      end loop;
      
      /* On récupère d'abord dans une variable ensembliste de type T_ensIslands, toutes les iles de geo grâce à une requête
         parcourant une table contenant toutes les iles, avec une jointure sur le code du pays. Et on itère ensuite dans l'ensemble pour ajouter
         un élément fils pour chacunes des iles. Les éléments fils d'un élément sont ajoutés avec XMLType.appendchildxml. */
      select value(i) bulk collect into tmpIslands
      from LesIslands i
      where i.codepays = code_pays ;    
      for indx IN 1..tmpIslands.COUNT
      loop
         output := XMLType.appendchildxml(output,'geo', tmpIslands(indx).toXML());   
      end loop;
      
      return output;
   end;
end;
/

-- BORDER
/*
    <!ELEMENT border EMPTY>
    <!ATTLIST border countryCode CDATA #REQUIRED
                     length CDATA #REQUIRED >
*/
drop type T_border force;
/
create or replace  type T_border as object (
-- On reprend les mêmes types de données que ceux de la Database
   COUNTRY1       VARCHAR2(4 Byte),
   COUNTRY2       VARCHAR2(4 Byte),
   BLENGTH        NUMBER,

-- Signature de la méthode toXML permettant la conversion du type objet vers le xml, tout en respectant la DTD fournie   
   member function toXML return XMLType
);
/
-- Corps de la méthode toXML
create or replace type body T_border as
 member function toXML return XMLType is
   output XMLType;
   begin
        -- Ce type est directement converti dans la méthode toXML de T_contCountries car c'est un élément fils vide qui apparait dans contCountries 
      return output;
   end;
end;
/
drop table LesBorders;
/
create table LesBorders of T_Border;
/
create or replace type T_ensBorders as table of T_Border;
/

-- ENCOMPASSES

drop type T_Encompasses force;
/
create or replace  type T_Encompasses as object (
-- On reprend les mêmes types de données que ceux de la Database
  COUNTRY_E     VARCHAR2(4 Byte),
  CONTINENT_E   VARCHAR2(20 Byte),
  PERCENTAGE    NUMBER
  
--Pas de conversion en xml, cet objet servira à faire des jointures et à récupérer des informations de Encompasses
)
/
drop table LesEncompasses;
/
create table LesEncompasses of T_Encompasses;
/
create or replace type T_ensEncompasses as table of T_Encompasses;
/

--CONTCOUNTRIES
/*
    <!ELEMENT contCountries (border*) > 
*/
drop type T_contCountries force;
/
create or replace  type T_contCountries as object (

  CODEPAYS        VARCHAR2(4 Byte),
  CODECONTINENT   VARCHAR2(20 Byte),

-- Méthode calculant la taille/longueur de la frontière entre deux pays  
  member function tailleFrontiere(pays1 VARCHAR2, pays2 VARCHAR2) return NUMBER,
-- Signature de la méthode toXML permettant la conversion du type objet vers le xml, tout en respectant la DTD fournie
  member function toXML return XMLType
)
/

create or replace type body T_contCountries as
  member function tailleFrontiere(pays1 VARCHAR2, pays2 VARCHAR2) return NUMBER is
  -- Variable qui contiendra la frontiere entre les deux pays
  tmpBorder T_ensBorders;
   begin
         -- On itère dans la base des borders pour trouver LA frontiere entre les deux pays, cette requette renvoie un élément border
         select value(b) bulk collect into tmpBorder
         from LesBorders b
         where (b.country1=pays1 and b.country2=pays2) or
               (b.country1=pays2 and b.country2=pays1);
        -- On retourne zéro les deux pays ne sont pas voisins
        if tmpBorder.count = 0 then
           return 0;
        else
        -- Sinon on retourne la longueur de la frontiere
           return tmpBorder(1).blength;
        end if;
   end;
   
-- Corps de la méthode toXML   
 member function toXML return XMLType is
/* Les éléments Encompasses permettant d'avoir les éléments fils Border de l'élément ContCountries pouvant ne pas être présents 
   dans la base de données ou apparaître une ou plusieurs fois, on choisira alors d'utiliser des ensembles pour stocker ces données. */
   output XMLType;
   tmpEncompasses T_ensEncompasses; 
   
   begin
      output := XMLType.createxml('<contCountries/>');
      /* On récupère d'abord dans une variable ensembliste de type T_ensEncompasses, toutes les pays sur le même continent grâce à une requête
         parcourant une table contenant toutes encompasses, avec une jointure sur le code du continent. Et on itère ensuite dans l'ensemble pour ajouter
         un élément fils pour chacunes des frontières. Les éléments fils d'un élément sont ajoutés avec XMLType.appendchildxml. */      
      select value(e) bulk collect into tmpEncompasses
      from LesEncompasses e
      where codecontinent=e.continent_e;      
      
      -- <!ELEMENT contCountries (border*) > 
      for indx IN 1..tmpEncompasses.COUNT
      loop      
         output := XMLType.appendchildxml(output,'contCountries', 
            XMLType('<border countryCode="'||tmpEncompasses(indx).country_e||'" 
            length="'||tailleFrontiere(codepays, tmpEncompasses(indx).country_e)||'" />'));  
      end loop;
      
      return output;
   end;
end;
/
-- COUNTRY
/*
    <!ELEMENT country (contCountries) >
    <!ATTLIST country name CDATA #REQUIRED 
                      continent CDATA #REQUIRED
                      blength CDATA #REQUIRED  >
*/
drop type T_Country force;
/
create or replace  type T_Country as object (
-- On reprend les mêmes types de données que ceux de la Database
   NAME           VARCHAR2(35 Byte),
   CODE           VARCHAR2(4 Byte),
   CAPITAL        VARCHAR2(35 Byte),
   PROVINCE       VARCHAR2(35 Byte),
   AREA           NUMBER,
   POPULATION     NUMBER,

-- Méthode déterminant la hauteur de sa plus haute montagne
   member function maxHauteur return Number,
-- Méthode déterminant le continent principal auquel appartient le pays
   member function contPrincipal return varchar2,
-- Méthode calculant la longueur totale de sa frontière
   member function blength return Number,
-- Signature de la méthode toXML permettant la conversion du type objet vers le xml, tout en respectant la DTD fournie
   member function toXML return XMLType
)
/
create or replace type body T_Country as
-- Corps de la méthode maxHauteur - peak
 member function maxHauteur return Number is
    resultat Number;
    begin
    -- On itère pour trouver la hauteur maximale des montagnes s'il y en a 
      select max(m.HEIGHT) collect into resultat
      from LesMontagnes m
      where m.codepays = code;
      -- S'il n'y a pas de montagne, la hauteur est de 0.
      if resultat is null then
        resultat:=0;
      end if;
      -- On retourne la hauteur
      return resultat;
   end;

-- Corps de la méthode contPrincipal 
  member function contPrincipal return varchar2 is
    resultat varchar2(40);
    begin
        -- On cherche le pourcentage MAXIMAL dans encompasses pour le pays
        select distinct m.CONTINENT_e collect into resultat
        from LesEncompasses m
        where m.country_e=code and m.PERCENTAGE=(select max(m2.PERCENTAGE)
                                                 from LesEncompasses m2
                                                 where m.country_e=m2.country_e);

      return resultat;
   end;
   
-- Corps de la méthode blength  
  member function blength return Number is
    resultat Number;
    begin
        -- On itère pour trouver toutes les frontières du pays et on somme les longueurs pour trouver la longueur totale de sa frontière
        select SUM(b.blength) collect into resultat
        from LesBorders b
        where b.country1=code or b.country2=code;

      return resultat;
   end;

-- Corps de la méthode toXML
 member function toXML return XMLType is
   output XMLType;
   begin
       -- <!ATTLIST country name CDATA #REQUIRED continent CDATA #REQUIRED >
       -- <!ATTLIST country name CDATA #REQUIRED blength CDATA #REQUIRED >
       output := XMLType.createxml('<country name="'||name||'" continent="'||contPrincipal||'" blength="'||blength()||'"/>');
       -- <!ELEMENT country (contCountries) >
       output := XMLType.appendchildxml(output,'country', T_contCountries(code,contPrincipal).toXML());
       -- <!ELEMENT country (geo, peak?) >
       output := XMLType.appendchildxml(output,'country', T_Geo(code).toXML());
       /* L'élément Country pouvant ne pas avoir de montagne dans la base de données, peak doit être ajoutée en tant qu'élément fils
        que lorsqu'une montagne est présente dans la base de données. Cette présence est vérifiée avec une condition if.*/
       if maxHauteur > 0 then
        output := XMLType.appendchildxml(output,'country', XMLType('<peak height="'||maxHauteur()||'"/>'));
       end if;
      return output;
   end;
end;
/
drop table LesCountrys;
/
Create table LesCountrys of T_Country;
/

-- MONDIAL - ex2
/*
    <!ELEMENT ex2 (country+) >
*/
drop type T_Mondial force;
/
create or replace  type T_Mondial as object (
-- Nom arbitraire du monde, utile pour pouvoir créer ce type
   NAME     VARCHAR2(20),
   
-- Signature de la méthode toXML permettant la conversion du type objet vers le xml, tout en respectant la DTD fournie
   member function toXML return XMLType
);
/
-- Corps de la méthode toXML
create or replace type body T_Mondial as
 member function toXML return XMLType is
/* Les éléments Country devant apparaitre au moins une fois, on choisira alors d'utiliser des ensembles pour stocker ces données. */
   output XMLType;
   tmpCountry T_ensCountry;
   begin
   
      output := XMLType.createxml('<ex2/>');
      /* On récupère d'abord dans une variable ensembliste de type T_ensCountry, toutes les pays du monde grâce à une requête
         parcourant une table contenant tous les pays. Et on itère ensuite dans l'ensemble pour ajouter un élément fils pour chacuns 
         des pays. Les éléments fils d'un élément sont ajoutés avec XMLType.appendchildxml. */ 
      select value(c) bulk collect into tmpCountry
      from LesCountrys c;
      -- pas de condition car on veut toutes les pays de la base.
      for indx IN 1..tmpCountry.COUNT
      loop
         output := XMLType.appendchildxml(output,'ex2', tmpCountry(indx).toXML());   
      end loop;
      
      return output;
   end;
end;
/
drop table LeMonde;
/
create table LeMonde of T_Mondial;
/


--INSERTIONS

-- Création et insertion du monde
insert into LeMonde values(T_Mondial('Le monde'));

-- Création et insertion des objets Mountain dans la table contenant les montagnes, on ne veut pas plusieurs fois la même montagne,
-- en parcourant la base MOUNTAIN, GEO_MOUTAIN et COUNTRY avec une jointure sur le nom des montagnes et le code des pays  
insert into LesMontagnes
  T_Mountain((select distinct m.name, m.mountains, m.height, m.type, gm.country
              from MOUNTAIN m, GEO_MOUNTAIN gm, COUNTRY c
              where m.name = gm.mountain and gm.country = c.code));

-- Création et insertion des objets Desert dans la table contenant les déserts, on ne veut pas plusieurs fois le même désert,
-- en parcourant la base DESERT, GEO_DESERT et COUNTRY avec une jointure sur le nom des déserts et le code des pays
insert into LesDeserts
  T_Desert((select distinct m.name, m.area, gd.country
            from DESERT m, GEO_DESERT gd, COUNTRY c
            where m.name = gd.desert and gd.country = c.code));

-- Création et insertion des objets Island dans la table contenant les îles, on ne veut pas plusieurs fois la même île,
-- en parcourant la base ISLAND, GEO_ISLAND et COUNTRY avec une jointure sur le nom des îles et le code des pays         
insert into LesIslands
  T_Island((select distinct m.name, m.islands, m.area, m.height, m.type, gi.country
            from ISLAND m, GEO_ISLAND gi, COUNTRY c
            where m.name = gi.island and gi.country = c.code));

-- Création et insertion des objets Country dans la table contenant les pays, en parcourant la base des pays : COUNTRY          
insert into LesCountrys
    select T_Country(c.name, c.code, c.capital, c.province, c.area, c.population)
    from COUNTRY c;

-- Création et insertion des objets Encompasses dans la table contenant les encompasses, en parcourant la base des encompasses : ENCOMPASSES
insert into LesEncompasses
    T_Encompasses(select e.country, e.continent, e.PERCENTAGE
                  from ENCOMPASSES e);

-- Création et insertion des objets Border dans la table contenant les frontières, en parcourant la base des frontières : BORDERS            
insert into LesBorders
 select T_Border(b.country1, b.country2, b.LENGTH)
   from BORDERS b;

/

-- exporter le resultat dans un fichier 
WbExport -type=text
         -file='Ex2_XML.xml'
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



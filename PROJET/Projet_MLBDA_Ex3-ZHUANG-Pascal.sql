/* 3701123 - Pascal ZHUANG
   EXERCICE 3 :
   L'éxécution de ce programme génère un fichier XML : Ex3_XML.xml
   Il faut ajouter manuellement <!DOCTYPE mondial SYSTEM "Ex3_DTD.dtd"> à la première ligne du fichier généré.
*/

-- CREATION DE TYPES ET TABLES :

/* Chaque type possède une méthode toXML permettant de transformer un type objet en xml. Le fichier xml suivra une DTD permettant de répondre aux requêtes
   XPath de l'énoncé. */


-- MONTAGNE
/*
    <!ELEMENT montagne (#PCDATA) >
    <!ATTLIST montagne 	nom CDATA #IMPLIED
					    altitude CDATA #IMPLIED 
					    latitude CDATA #IMPLIED 
					    longitude CDATA #IMPLIED >
*/
drop type T_Montagne force;
/
create or replace  type T_Montagne as object (
-- On reprend les mêmes types de données que ceux de la Database
   NAME           VARCHAR2(35 Byte),
   HEIGHT         NUMBER,
   LATITUDE       NUMBER,
   LONGITUDE      NUMBER,
   CODEPROVINCE   VARCHAR2(35 Byte),

-- Signature de la méthode toXML permettant la conversion du type objet vers le xml, tout en respectant la DTD fournie   
   member function toXML return XMLType
)
/
-- Corps de la méthode toXML
create or replace type body T_Montagne as
 member function toXML return XMLType is
   output XMLType;
   begin
      output := XMLType.createxml('<montagne nom="'||name||'" altitude="'||height||'" latitude="'||latitude||'" longitude="'||longitude||'" />');
      return output;
   end;
end;
/
drop table LesMontagnes;
/
create table LesMontagnes of T_montagne;
/
create or replace type T_ensMontagnes as table of T_Montagne;
/

-- RIVER
/*
    <!ELEMENT riviere EMPTY >
    <!ATTLIST riviere nom CDATA #REQUIRED 
    				            source CDATA #REQUIRED>
*/
drop type T_River force;
/
create or replace  type T_River as object (
-- On reprend les mêmes types de données que ceux de la Database
   NAME           VARCHAR2(35 Byte),
   SOURCE         VARCHAR2(10 Byte),
   CODEPROVINCE   VARCHAR2(35 Byte),   
   CODEPAYS       VARCHAR2(4 Byte),  

-- Signature de la méthode toXML permettant la conversion du type objet vers le xml, tout en respectant la DTD fournie   
   member function toXML return XMLType
)
/
-- Corps de la méthode toXML
create or replace type body T_River as
 member function toXML return XMLType is
   output XMLType;
   begin
      output := XMLType.createxml('<riviere nom="'||name||'" source="'||source||'"/>');
      return output;
   end;
end;
/
drop table LesRivers;
/
create table LesRivers of T_river;
/
create or replace type T_ensRivers as table of T_River;
/

-- FRONTIERE
/*
    <!ELEMENT frontiere (#PCDATA) >
    <!ATTLIST frontiere	longueur CDATA #REQUIRED >
*/
drop type T_Frontiere force;
/
create or replace  type T_Frontiere as object (
-- On reprend les mêmes types de données que ceux de la Database
   PAYS1        VARCHAR2(4 Byte),
   PAYS2        VARCHAR2(4 Byte),
   NAME1        VARCHAR2(35 Byte),
   NAME2        VARCHAR2(35 Byte),
   longueur     NUMBER,

-- Signature de la méthode toXML permettant la conversion du type objet vers le xml, tout en respectant la DTD fournie   
   member function toXML return XMLType
)
/
-- Corps de la méthode toXML
create or replace type body T_Frontiere as
 member function toXML return XMLType is
   output XMLType;
   begin
      output := XMLType.createxml('<frontiere longueur="'||longueur||'">'||name1 || ' et '|| name2 ||'</frontiere>');
      return output;
   end;
end;
/
drop table LesFrontieres;
/
create table LesFrontieres of T_Frontiere;
/
create or replace type T_ensFrontieres as table of T_Frontiere;
/

-- ORGANIZATION
/*
    <!ELEMENT organization (#PCDATA) >
    <!ATTLIST organization 	date_creation CDATA #IMPLIED >
*/
drop type T_Organization force;
/
create or replace  type T_Organization as object (
-- On reprend les mêmes types de données que ceux de la Database
   ABBREVATION    VARCHAR2(12 Byte),
   NAME           VARCHAR2(80 Byte),
   ESTABLISHED    DATE,
   ISMEMBERPAYS   VARCHAR2(4 Byte),
   
-- Signature de la méthode toXML permettant la conversion du type objet vers le xml, tout en respectant la DTD fournie 
   member function toXML return XMLType
)
/
-- Corps de la méthode toXML
create or replace type body T_Organization as
 member function toXML return XMLType is
   output XMLType;
   begin
   /* L'attribut Established étant en #IMPLIED, doit être ajoutée que lorsqu'elle est présente dans la base de données.
   Cette présence est vérifiée avec une condition if. */ 
      if established is not null then
        output := XMLType.createxml('<organization date_creation="'||to_char(established,'YYYY/MM/DD')||'">'||name||'</organization>');
      else
        output := XMLType.createxml('<organization>'||name||'</organization>');
      end if;
      return output;
   end;
end;
/
drop table LesOrganizations;
/
create table LesOrganizations of T_organization;
/
create or replace type T_ensOrganizations as table of T_Organization;
/

-- PROVINCE
/*
    <!ELEMENT province (riviere*, montagne*) >
    <!ATTLIST province nom CDATA #REQUIRED >
*/
drop type T_Province force;
/
create or replace  type T_Province as object (
-- On reprend les mêmes types de données que ceux de la Database
   NOM_PROVINCE    VARCHAR2(35 Byte),
   CODE_PAYS        VARCHAR2(4 Byte),

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
   tmpRivers T_ensRivers;
   tmpMontagnes T_ensMontagnes;

   begin
      output := XMLType.createxml('<province nom="'||nom_province||'"/>');
      /* On récupère d'abord dans une variable ensembliste de type T_ensRivers, toutes les rivières de la province grâce à une requête
         parcourant une table contenant toutes les rivères, avec une jointure sur le nom de la province. Et on itère ensuite dans l'ensemble 
         pour ajouter un élément fils pour chacunes des rivières. Les éléments fils d'un élément sont ajoutés avec XMLType.appendchildxml. */
      select value(r) bulk collect into tmpRivers
      from LesRivers r
      where r.codeProvince = nom_province and code_pays = r.codepays; 
      for indx IN 1..tmpRivers.COUNT
      loop
         output := XMLType.appendchildxml(output,'province', tmpRivers(indx).toXML());   
      end loop;
      
      /* On récupère d'abord dans une variable ensembliste de type T_ensMontagnes, toutes les montagnes de la province, s'il y en a grâce à une requête
         parcourant une table contenant toutes les montagnes, avec une jointure sur le nom de la province. Et on itère ensuite dans l'ensemble 
         pour ajouter un élément fils pour chacunes des montagnes. Les éléments fils d'un élément sont ajoutés avec XMLType.appendchildxml. */
      select value(m) bulk collect into tmpMontagnes
      from LesMontagnes m
      where m.codeProvince = nom_province;  
      for indx IN 1..tmpMontagnes.COUNT
      loop
         output := XMLType.appendchildxml(output,'province', tmpMontagnes(indx).toXML());   
      end loop;
      -- Si la province ne possède pas de montagne, alors c'est vide
      if tmpMontagnes.COUNT = 0 then
        output := XMLType.appendchildxml(output,'province', XMLType('<montagne>empty</montagne>'));
      end if;
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

-- PAYS
/*
    <!ELEMENT pays (province+, frontiere*, organization*) >
    <!ATTLIST pays 	nom CDATA #REQUIRED 
    				    codepays CDATA #REQUIRED
    				    population CDATA #REQUIRED >
*/
drop type T_Pays force;
/
create or replace  type T_Pays as object (
-- On reprend les mêmes types de données que ceux de la Database
  NAME            VARCHAR2(35 Byte),
  CODE            VARCHAR2(4 Byte),
  POPULATION      NUMBER,
  CODE_CONTINENT  VARCHAR2(20 Byte),

-- Signature de la méthode toXML permettant la conversion du type objet vers le xml, tout en respectant la DTD fournie  
  member function toXML return XMLType
)
/
-- Corps de la méthode toXML
create or replace type body T_Pays as
 member function toXML return XMLType is
/* Les éléments fils de l'élément Pays pouvant soit ne pas être présents dans la base de données ou apparaître une ou plusieurs fois (*),
   soit être présents au moins une fois (+), on choisira alors d'utiliser des ensembles pour stocker ces données. */
   output XMLType;
   tmpProvince T_ensProvinces;
   tmpFrontiere T_ensFrontieres;
   tmpOrganization T_ensOrganizations;
   begin
       output := XMLType.createxml('<pays nom="'||name||'" codepays="'||code||'" population="'||population||'"/>');
       
      /* On récupère d'abord dans une variable ensembliste de type T_ensProvinces, toutes les provinces du pays grâce à une requête
         parcourant une table contenant toutes les provinces, avec une jointure sur le code du pays. Et on itère ensuite dans l'ensemble pour ajouter
         un élément fils pour chacunes des provinces. Les éléments fils d'un élément sont ajoutés avec XMLType.appendchildxml. */
      select value(p) bulk collect into tmpProvince
      from LesProvinces p
      where code = p.code_pays ;  
      for indx IN 1..tmpProvince.COUNT
      loop
         output := XMLType.appendchildxml(output,'pays', tmpProvince(indx).toXML());   
      end loop;
      
      /* On récupère d'abord dans une variable ensembliste de type T_ensFrontieres, toutes les frontières du pays grâce à une requête
         parcourant une table contenant toutes les frontières, avec une jointure sur le code du pays. Et on itère ensuite dans l'ensemble pour ajouter
         un élément fils pour chacunes des frontières. Les éléments fils d'un élément sont ajoutés avec XMLType.appendchildxml. */
      select value(f) bulk collect into tmpFrontiere
      from LesFrontieres f
      where code = f.pays1 or code = f.pays2;  
      for indx IN 1..tmpFrontiere.COUNT
      loop
         output := XMLType.appendchildxml(output,'pays', tmpFrontiere(indx).toXML());   
      end loop;
      
      /* On récupère d'abord dans une variable ensembliste de type T_ensOrganizations, toutes les organizations du pays grâce à une requête
         parcourant une table contenant toutes les organisations, avec une jointure sur le code du pays. Et on itère ensuite dans l'ensemble pour ajouter
         un élément fils pour chacunes des organizations. Les éléments fils d'un élément sont ajoutés avec XMLType.appendchildxml. */
      select value(o) bulk collect into tmpOrganization
      from LesOrganizations o
      where code = o.isMemberPays
      Order by o.ESTABLISHED;  
      for indx IN 1..tmpOrganization.COUNT
      loop
         output := XMLType.appendchildxml(output,'pays', tmpOrganization(indx).toXML());   
      end loop;
      
      return output;
   end;
end;
/
drop table LesPays;
/
create table LesPays of T_Pays;
/
create or replace type T_ensPays as table of T_Pays;
/

-- CONTINENT
/*
    <!ELEMENT continent (pays+) >
    <!ATTLIST continent nom CDATA #REQUIRED >
*/
drop type T_Continent force;
/
create or replace  type T_Continent as object (
-- Nom du continent
  NAME_CONTINENT   VARCHAR2(20 Byte),

-- Signature de la méthode toXML permettant la conversion du type objet vers le xml, tout en respectant la DTD fournie   
  member function toXML return XMLType
)
/
-- Corps de la méthode toXML
create or replace type body T_Continent as
 member function toXML return XMLType is
/* Les éléments fils Pays de l'élément Continent devant être présents au moins une fois (+),
   on choisira alors d'utiliser des ensembles pour stocker ces données. */
   output XMLType;
   tmpPays T_ensPays; 
   begin
      output := XMLType.createxml('<continent nom="'||name_continent||'"/>');
      /* On récupère d'abord dans une variable ensembliste de type T_ensPays, tous les pays du continent du pays grâce à une requête
         parcourant une table contenant tous les pays, avec une jointure sur le code du continent. Et on itère ensuite dans l'ensemble pour ajouter
         un élément fils pour chacuns des pays. Les éléments fils d'un élément sont ajoutés avec XMLType.appendchildxml. */
      select value(p) bulk collect into tmpPays
      from LesPays p
      where name_continent = p.code_continent; 
      for indx IN 1..tmpPays.COUNT
      loop
         output := XMLType.appendchildxml(output,'continent', tmpPays(indx).toXML());    
      end loop;
      return output;
   end;
end;
/
drop table LesContinent;
/
create table LesContinent of T_Continent;
/
create or replace type T_ensContinent as table of T_Continent;
/

-- MONDIAL
/*
<!ELEMENT mondial (continent+) >
*/
drop type T_Mondial force;
/
create or replace  type T_Mondial as object (
-- Nom arbitraire du monde, utile pour pouvoir créer ce type
   NAME   VARCHAR2(20),
   
-- Signature de la méthode toXML permettant la conversion du type objet vers le xml, tout en respectant la DTD fournie
   member function toXML return XMLType
);
/
-- Corps de la méthode toXML
create or replace type body T_Mondial as
 member function toXML return XMLType is
/* Les éléments fils Continent de l'élément Mondial devant être présents au moins une fois (+),
   on choisira alors d'utiliser des ensembles pour stocker ces données. */
   output XMLType;
   tmpContinent T_ensContinent;
   begin  
      output := XMLType.createxml('<mondial/>');
      /* On récupère d'abord dans une variable ensembliste de type T_ensContinent, toutes les continents du monde grâce à une requête
         parcourant une table contenant tous les continents. Et on itère ensuite dans l'ensemble pour ajouter un élément fils pour chacuns 
         des continents. Les éléments fils d'un élément sont ajoutés avec XMLType.appendchildxml. */ 
      select value(c) bulk collect into tmpContinent
      from LesContinent c;
      -- pas de condition car on veut tous les continents de la base.
      for indx IN 1..tmpContinent.COUNT
      loop
         output := XMLType.appendchildxml(output,'mondial', tmpContinent(indx).toXML());   
      end loop;
      
      return output;
   end;
end;
/
drop table LeMonde;
/
create table LeMonde of T_Mondial;


--INSERTIONS

-- Création et insertion du monde
insert into LeMonde values(T_Mondial('Le monde'));

-- Création et insertion des objets Continent dans la table contenant les continents, en parcourant la base des continents : CONTINENT
insert into LesContinent
  select T_continent(c.name)
  from CONTINENT c;

-- Création et insertion des objets Pays dans la table contenant les pays,
-- en parcourant la base COUNTRY et ENCOMPASSES avec une jointure sur le code des pays
insert into LesPays
  select T_Pays(c.name, c.code, c.population, e.continent)
  from COUNTRY c, ENCOMPASSES e
  where c.code = e.country;

-- Création et insertion des objets Province dans la table contenant les provinces, en parcourant la base des provinces : PROVINCE
insert into LesProvinces
  select T_Province(p.name, p.country)
  from  PROVINCE p;

-- Création et insertion des objets RIVER dans la table contenant les rivières, en parcourant la base des sources de rivière : GEO_SOURCE
-- Permet de savoir si la source de la rivière est dans le pays ou pas
insert into LesRivers
  select T_River(s.river, 'OUI', s.province, s.country)
  from GEO_SOURCE s;

-- Création et insertion des objets RIVER dans la table contenant les rivières, en parcourant la base des rivières : GEO_RIVER
-- Permet de savoir si la source de la rivière est dans le pays ou pas
insert into LesRivers
  select T_River(g.river, 'NON', g.province, g.country)
  from GEO_RIVER g
  where g.river not in (select s.river 
                        from GEO_SOURCE s 
                        where g.province = s.province);

-- Création et insertion des objets Montagne dans la table contenant les montagnes,
-- en parcourant la base MOUNTAIN et GEO_MOUTAIN avec une jointure sur le nom des montagnes 
insert into LesMontagnes
  select T_montagne(m.name, m.height, m.COORDINATES.latitude, m.COORDINATES.longitude, g.province)
  from  MOUNTAIN m, GEO_MOUNTAIN g
  where m.name = g.mountain;

-- Création et insertion des objets Frontiere dans la table contenant les frontieres,
-- en parcourant la base BORDERS, et COUNTRY avec une jointure sur le code des deux pays 
insert into LesFrontieres
  select  T_Frontiere(b.country1, b.country2, c1.name, c2.name, b.length)
  from  BORDERS b, COUNTRY c1, COUNTRY c2
  where b.country1=c1.code and b.country2=c2.code;

-- Création et insertion des objets Organization dans la table contenant les organizations,
-- en parcourant la base ORGANIZATION, et ISMEMBER avec une jointure sur l'abbreviation de l'organization
insert into LesOrganizations
         T_Organization((select o.abbreviation, o.name, o.established, i.country
                          from ORGANIZATION o, ISMEMBER i
                          where o.abbreviation = i.organization));


/
-- exporter le resultat dans un fichier 
WbExport -type=text
         -file='Ex3_XML.xml'
         -createDir=true
         -encoding=UTF-8
         -header=false
         -delimiter=','
         -decimal=','
         -dateFormat='yyyy-MM-dd'
/
select m.toXML().getClobVal() 
from LeMonde m;
/



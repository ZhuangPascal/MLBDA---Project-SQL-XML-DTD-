/* 3701123 - Pascal ZHUANG
   EXERCICE 1 - 2�me DTD :
   L'�x�cution de ce programme g�n�re un fichier XML : Ex1_2_XML.xml
   Il faut ajouter manuellement <!DOCTYPE mondial SYSTEM "Ex1_2_DTD.dtd"> � la premi�re ligne du fichier g�n�r�.
   Ce programme met environ 1m 40s � finir.
*/


-- CREATION DE TYPES ET TABLES :

/* Pour chaque type d'objet, on cherche le contenu dans la Database Explorer puis on s�lectionne 
   seulement les colonnes qui nous sont utiles. Chaque type poss�de une m�thode toXML permettant 
   de transformer un type objet en xml. */



-- HEADQUARTER 
/*  
    <!ELEMENT headquarter EMPTY>
    <!ATTLIST headquarter name CDATA #REQUIRED>
*/
drop type T_Headquarter force;
/
create or replace  type T_Headquarter as object (
-- On r�cup�re le nom de la ville o� se situe l'organisation
   CITY       VARCHAR2(35 Byte),
 
-- Signature de la m�thode toXML permettant la conversion du type objet vers le xml, tout en respectant la DTD fournie   
   member function toXML return XMLType
)
/
-- Corps de la m�thode toXML
create or replace type body T_Headquarter as
 member function toXML return XMLType is
   output XMLType;
   begin
        -- Ce type est directement converti dans la m�thode toXML de T_Organization car c'est un �l�ment fils vide qui n'apparait qu'une fois 
        -- dans chaque Organization. 
      return output;
   end;
end;
/
drop table  LesHeadquarters;
/
create table LesHeadquarters of T_Headquarter;
/
create or replace type T_ensHeadquarters as table of T_Headquarter;
/

-- BORDER
/*
    <!ELEMENT border EMPTY>
    <!ATTLIST border countryCode CDATA #REQUIRED
                     length CDATA #REQUIRED >
*/
drop type T_Border force;
/
create or replace  type T_Border as object (
-- On reprend les m�mes types de donn�es que ceux de la Database
   COUNTRY1        VARCHAR2(4 Byte),
   COUNTRY2        VARCHAR2(4 Byte),
   LENGTH          NUMBER,
   
-- Signature de la m�thode toXML permettant la conversion du type objet vers le xml, tout en respectant la DTD fournie 
   member function toXML return XMLType
)
/
-- Corps de la m�thode toXML
create or replace type body T_Border as
 member function toXML return XMLType is
   output XMLType;
   begin
      -- Ce type est directement converti dans la m�thode toXML de T_Country car c'est un �l�ment vide et fils de l'�l�ment BORDERS
      -- qui n'apparait qu'une fois dans chaque Country. 
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

-- LANGUAGE
/*
    <!ELEMENT language EMPTY >
    <!ATTLIST language language CDATA #REQUIRED
                       percent  CDATA #REQUIRED >
*/
drop type T_Language force;
/
create or replace  type T_Language as object (
-- On reprend les m�mes types de donn�es que ceux de la Database
   COUNTRY        VARCHAR2(4 Byte),
   NAME           VARCHAR2(50 Byte),
   PERCENTAGE     NUMBER,
   
-- Signature de la m�thode toXML permettant la conversion du type objet vers le xml, tout en respectant la DTD fournie 
   member function toXML return XMLType
)
/
-- Corps de la m�thode toXML
create or replace type body T_Language as
 member function toXML return XMLType is
   output XMLType;
   begin
      output := XMLType.createxml('<language language="'||name||'"  percent="'||percentage||'"/>');
      return output;
   end;
end;
/
drop table LesLanguages;
/
create table LesLanguages of T_Language;
/
create or replace type T_ensLanguages as table of T_Language;
/

-- COUNTRY
/*
    <!ELEMENT country (language*, borders) >
    <!ATTLIST country code CDATA #IMPLIED
                      name CDATA #REQUIRED 
                      population CDATA #REQUIRED > 
*/
drop type T_Country force;
/
create or replace  type T_Country as object (
-- On reprend les m�mes types de donn�es que ceux de la Database
   NAME            VARCHAR2(35 Byte),
   CODE_PAYS       VARCHAR2(4 Byte),
   CAPITAL         VARCHAR2(35 Byte),
   PROVINCE        VARCHAR2(35 Byte),
   AREA            NUMBER,
   POPULATION      NUMBER,
   ORGANIZATION    VARCHAR2(12 Byte),

-- Signature de la m�thode toXML permettant la conversion du type objet vers le xml, tout en respectant la DTD fournie
   member function toXML return XMLType
)
/
-- Corps de la m�thode toXML
create or replace type body T_Country as
 member function toXML return XMLType is
/* Les �l�ments fils Language de l'�l�ment Country pouvant ne pas �tre pr�sents dans la base de donn�es ou appara�tre une ou plusieurs fois,
   on choisira alors d'utiliser des ensembles pour stocker ces donn�es. L'�l�ment fils unique Borders �tant une liste de Border, on utilisera
   �galement une liste.*/
   output XMLType;
   tmpLanguages T_ensLanguages;
   tmpBorders T_ensBorders; 
   begin
   /* L'attribut code_pays �tant en #IMPLIED, doit �tre ajout�e que lorsqu'elle est pr�sente dans la base de donn�es.
   Cette pr�sence est v�rifi�e avec une condition if. */ 
      if code_pays is not null then
        output := XMLType.createxml('<country code="'||code_pays||'" name="'||name||'" population="'||population||'"/>');
      else
        output := XMLType.createxml('<country name="'||name||'" population="'||population||'"/>');
      end if;
      
      /* On r�cup�re d'abord dans une variable ensembliste de type T_ensLanguages, tous les langages du pays gr�ce � une requ�te
         parcourant une table contenant tous les langages, avec une jointure sur le code du pays. Et on it�re ensuite dans l'ensemble 
         pour ajouter un �l�ment fils pour chacuns des langages. Les �l�ments fils d'un �l�ment sont ajout�s avec XMLType.appendchildxml. */
      select value(l) bulk collect into tmpLanguages
      from LesLanguages l
      where l.country = code_pays;  
      for indx IN 1..tmpLanguages.COUNT
      loop
         output := XMLType.appendchildxml(output,'country', tmpLanguages(indx).toXML());   
      end loop;
      
      -- L'�l�ment Borders est obligatoire m�me vide
      output := XMLType.appendchildxml(output,'country', XMLType('<borders/>') );
      
      /* On r�cup�re d'abord dans une variable ensembliste de type T_ensBorders, toutes les fronti�res du pays gr�ce � une requ�te
         parcourant une table contenant toutes les fronti�res, avec une jointure sur le code du pays. Et on it�re ensuite dans l'ensemble 
         pour ajouter un �l�ment fils pour chacunes des fronti�res. Les �l�ments fils d'un �l�ment sont ajout�s avec XMLType.appendchildxml. */
      select value(b) bulk collect into tmpBorders
      from LesBorders b
      where b.country1 = code_pays or b.country2 = code_pays;        
      for indx IN 1..tmpBorders.COUNT
      loop
      /* On veut ajouter le pays frontalier du pays actuel, or le pays actuel peut se trouver dans country1 ou dans country2 des �l�ments border.
        On ins�re donc une condition if pour d�terminer le pays frontalier. */
         if code_pays = tmpBorders(indx).country1 then
          output := XMLType.appendchildxml(output,'country/borders', XMLtype('<border countryCode="'||tmpBorders(indx).country2||'" length="'||tmpBorders(indx).length||'"/>'));   
         else
          output := XMLType.appendchildxml(output,'country/borders', XMLtype('<border countryCode="'||tmpBorders(indx).country1||'" length="'||tmpBorders(indx).length||'"/>'));
         end if;
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
-- ORGANIZATION
/*
    <!ELEMENT organization (country+, headquarter) >
*/
drop type T_Organization force;
/
create or replace  type T_Organization as object (
-- On reprend les m�mes types de donn�es que ceux de la Database
   ABBREVIATION      VARCHAR2(12 Byte),
   CITY              VARCHAR2(35 Byte),
   
-- Signature de la m�thode toXML permettant la conversion du type objet vers le xml, tout en respectant la DTD fournie
   member function toXML return XMLType
)
/
-- Corps de la m�thode toXML
create or replace type body T_Organization as
 member function toXML return XMLType is
/* Les �l�ments fils Country de l'�l�ment Organization devant �tre pr�sents au moins une fois, on choisira alors d'utiliser 
   des ensembles pour stocker ces donn�es. L'�l�ment fils unique Headquarter �tant un �l�ment fils vide, on utilisera XMLType.appendchildxml
   pour l'ajouter.*/
   output XMLType;
   tmpCountrys T_ensCountrys;

   begin
      output := XMLType.createxml('<organization />');
      
      /* On r�cup�re d'abord dans une variable ensembliste de type T_ensCountrys, tous les pays des organizations gr�ce � une requ�te
         parcourant une table contenant tous les pays, avec une jointure sur l'abbreviation de l'organization. Et on it�re ensuite dans l'ensemble 
         pour ajouter un �l�ment fils pour chacuns des pays. Les �l�ments fils d'un �l�ment sont ajout�s avec XMLType.appendchildxml. */
      select value(c) bulk collect into tmpCountrys
      from LesCountrys c
      where c.organization = abbreviation;
      for indx IN 1..tmpCountrys.COUNT
      loop
         output := XMLType.appendchildxml(output,'organization', tmpCountrys(indx).toXML());   
      end loop;
      
      -- on ajoute ici l'�l�ment fils vide Headquarter correspondant � la ville o� se situe le quartier g�n�ral.
      output := XMLType.appendchildxml(output,'organization', XMLType('<headquarter name="'||city||'"/>'));   

      return output;
   end;
end;
/
drop table LesOrganizations;
/
create table LesOrganizations of T_Organization;
/
create or replace type T_ensOrganizations as table of T_Organization;
/

-- MONDIAL
/*
    <!ELEMENT mondial (organization+) >
*/
drop type T_Mondial force;
/
create or replace  type T_Mondial as object (
-- Nom arbitraire du monde, utile pour pouvoir cr�er ce type
   NAME   VARCHAR2(20),

-- Signature de la m�thode toXML permettant la conversion du type objet vers le xml, tout en respectant la DTD fournie    
   member function toXML return XMLType
);
/
-- Corps de la m�thode toXML
create or replace type body T_Mondial as
 member function toXML return XMLType is
/* Les �l�ments fils Organization de l'�l�ment Mondial devant �tre pr�sents au moins une fois, on choisira alors d'utiliser 
   des ensembles pour stocker ces donn�es. */
   output XMLType;
   tmpOrganizations T_ensOrganizations;
   begin
      output := XMLType.createxml('<mondial/>');
      
      /* On r�cup�re d'abord dans une variable ensembliste de type T_ensOrganizations, toutes les organizations du monde gr�ce � une requ�te
         parcourant une table contenant toutes les organizations. Et on it�re ensuite dans l'ensemble pour ajouter un �l�ment fils pour chacunes 
         des organizations. Les �l�ments fils d'un �l�ment sont ajout�s avec XMLType.appendchildxml. */
      select value(o) bulk collect into tmpOrganizations
      from LesOrganizations o;
       -- pas de condition car on veut toutes les organizations de la base.
      for indx IN 1..tmpOrganizations.COUNT
      loop
         output := XMLType.appendchildxml(output,'mondial', tmpOrganizations(indx).toXML());   
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

-- Cr�ation et insertion du monde
insert into LeMonde values(T_Mondial('Le monde'));

-- Cr�ation et insertion des objets Organization dans la table contenant les organizations,
-- en parcourant la base ISMEMBER et ORGANIZATION avec une jointure sur l'abbreviation de l'organisation
insert into LesOrganizations
      T_Organization(select distinct m.ORGANIZATION, o.city
                     from  IsMember m, ORGANIZATION o
                     where m.ORGANIZATION = o.ABBREVIATION);

-- Cr�ation et insertion des objets Country dans la table contenant les pays,
-- en parcourant la base COUNTRY et ISMEMBER avec une jointure sur le code du pays
insert into LesCountrys
   select T_Country(c.name, c.code, c.capital, c.province, c.area, c.population, m.ORGANIZATION)
   from Country c, Ismember m
   where c.code = m.country;

-- Cr�ation et insertion des objets LANGUAGE dans la table contenant les langages, en parcourant la base des langages : LANGUAGE    
insert into LesLanguages
   select T_language(l.country, l.name, l.percentage)
   from Language l;

-- Cr�ation et insertion des objets BORDER dans la table contenant les fronti�res, en parcourant la base des fronti�res : BORDERS
insert into LesBorders
   select T_Border(b.country1, b.country2, b.LENGTH)
   from Borders b;

-- Cr�ation et insertion des objets HEADQUARTER dans la table contenant les quartiers g�n�raux, en parcourant la base : ORGANIZATION
insert into LesHeadquarters
   select T_Headquarter(o.city)
   from Organization o;

-- exporter le r�sultat dans un fichier 
WbExport -type=text
         -file='Ex1_2_XML.xml'
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

libname coreData xmlv2 'C:\Users\ETiffany\OneDrive - State of Indiana\Desktop\coreInterviewFiles.XML';

proc sql;
/* pulling count of eligible participants */
title 'Total Nonseed';
	select count(*) as Total from coredata.Interview
	where CONSENTA=1 and ISEED=0;

/* pulling counts of counties for eligible participants */
title 'County Breakdown';
	select
	sum(case when INDCTYR6=1 then 1 end) as Boone,
	sum(case when INDCTYR6=2 then 1 end) as Brown,
	sum(case when INDCTYR6=3 then 1 end) as Hamilton,
	sum(case when INDCTYR6=4 then 1 end) as Hancock,
	sum(case when INDCTYR6=5 then 1 end) as Hendricks,
	sum(case when INDCTYR6=6 then 1 end) as Johnson,
	sum(case when INDCTYR6=7 then 1 end) as Madison,
	sum(case when INDCTYR6=8 then 1 end) as Marion,
	sum(case when INDCTYR6=9 then 1 end) as Morgan,
	sum(case when INDCTYR6=10 then 1 end) as Putnam,
	sum(case when INDCTYR6=11 then 1 end) as Shelby,
	sum(case when INDCTYR6>11 then 1 end) as OtherNA
	from coreData.Interview
	where CONSENTA=1 and ISEED=0;

/* pulling count of townships by zipcode for eligible participants */
title 'Township Breakdown (overlap)';
select
sum(case when ZIP in (46077,46228,46234,46254,46260,46268,46278) then 1 end) as Pike,
sum(case when ZIP in (46205,46208,46218,46220,46226,46228,46240,46250,46260,46268) then 1 end) as Washington,
sum(case when ZIP in (46216,46218,46220,46226,46235,46236,46250,46256) then 1 end) as Lawrence,
sum(case when ZIP in (46203,46218,46219,46226,46229,46235,46239) then 1 end) as Warren,
sum(case when ZIP in (46107,46203,46237,46239,46259) then 1 end) as Franklin,
sum(case when ZIP in (46107,46203,46217,46225,46227,46237) then 1 end) as Perry,
sum(case when ZIP in (46113,46183,46217,46221,46231,46241) then 1 end) as Decatur,
sum(case when ZIP in (46214,46221,46222,46224,46231,46234,46241,46254) then 1 end) as Wayne,
sum(case when ZIP in (46107,46201,46202,46203,46204,46205,46208,46218,46219,46221,46222,46225) then 1 end) as Downtown
from coredata.Interview
where CONSENTA=1 and ISEED=0;

title 'Washington Twp Breakdown';
select ZIP, count(*) from coredata.Interview
where ZIP in (46205,46208,46218,46220,46226,46228,46240,46250,46260,46268)
group by ZIP;

title 'Downtown Breakdown';
select ZIP, count(*) from coredata.Interview
where ZIP in (46107,46201,46202,46203,46204,46205,46208,46218,46219,46221,46222,46225)
group by ZIP;

proc import DATAFILE='C:\Users\ETiffany\OneDrive - State of Indiana\Desktop\MapLabels.xlsx' DBMS=xlsx OUT=MapLabels REPLACE;
/* xlsx "maplabels" for fieldsite labels created
includes:
- label (text)
- latitude (y)
- longitude (x)
- font size (size)
- font (style)
- function (function)
- font color (color)
- position of text (position)
- SAS variables (xsys, ysys, hsys, when)*/

/* creating new dataset "labs" from "maplabels" */
data labs;
	set work.maplabels; 
/* converting to text type 8. */
	xsys = put(nxsys, 8.); 
	ysys = put(nysys, 8.);
	hsys = put(nhsys, 8.);
/* dropping old variables */
	drop nxsys;
	drop nysys;
	drop nhsys; 
run;

proc mapimport out=indy_shp
	datafile='C:\Users\ETiffany\OneDrive - State of Indiana\Desktop\ZIP_Code_Boundaries.shp';
/* importing .shp file with info for zip code outlines found online */
run;

/* creating separate table of zipcodes and counts */
proc sql;
create table Zips as
select ZIP, count(*) as COUNT from coredata.Interview
group by ZIP;
quit;

/* creating table ZipMap from .shp file to change zipcode to numeric variable */
data ZipMap;
	set INDY_SHP;
	ZIP = input(ZIPCODE, 5.);
run;

/* reset graphic presets */
/* goptions reset = all; */

/* Map the Data*/
ods graphics on;
goptions ftitle='Arial';
title "Zipcode Distribution"; footnote " ";
/* colors from green->red */
/* pattern1 c=cx00ff00; pattern2 c=cx35ff00; 
pattern3 c=cx65ff00; pattern4 c=cx88ff00; 
pattern5 c=cxccff00; pattern6 c=cxd0ff00; 
pattern7 c=cxe0ff00; pattern8 c=cxffee00; 
pattern9 c=cxffe000; pattern10 c=cxffdd00; 
pattern11 c=cxffd100; pattern12 c=cxffcd00; 
pattern13 c=cxffc000; pattern14 c=cxff8700; 
pattern15 c=cxff7700; pattern16 c=cxff5400; */

proc gmap data=Zips map=ZipMap all;
id ZIP; /* matches values between response and map dataset */
choro COUNT /* response variable */
 / levels=12/* pattern/color levels */
 missing coutline=black /* include missing, suppress legent, black outline */
 cdef=white cempty=black /* black outline white fill for empty zipcodes */
 annotate=LABS; /* annotate field sites with labs dataset */
run;quit;
ods graphics off;

proc sql;
title 'Primary Usage Breakdown';
	select
	sum(case when E_USINJ=1 then 1 end) as Speedball,
	sum(case when E_USINJ=2 then 1 end) as Heroin,
	sum(case when E_USINJ=3 then 1 end) as PowderCocaine,
	sum(case when E_USINJ=4 then 1 end) as CrackCocaine,
	sum(case when E_USINJ=5 then 1 end) as Methamphetamine,
	sum(case when E_USINJ=6 then 1 end) as Painkillers,
	sum(case when E_USINJ>6 then 1 end) as OtherNA
	from coreData.Interview
	where CONSENTA=1 and ISEED=0;

title 'Primary Usage Breakdown (%)';
	select
	sum(case when E_USINJ=1 then 1 end)/count(*) as Speedball,
	sum(case when E_USINJ=2 then 1 end)/count(*) as Heroin,
	sum(case when E_USINJ=3 then 1 end)/count(*) as PowderCocaine,
	sum(case when E_USINJ=4 then 1 end)/count(*) as CrackCocaine,
	sum(case when E_USINJ=5 then 1 end)/count(*) as Methamphetamine,
	sum(case when E_USINJ=6 then 1 end)/count(*) as Painkillers,
	sum(case when E_USINJ>6 then 1 end)/count(*) as OtherNA
	from coreData.Interview
	where CONSENTA=1 and ISEED=0;

title 'Total Percentage Heroin (%)';
	select
	sum(case when INJ_HERO < 5 then 1 end)/count(*) as Yes,
	sum(case when INJ_HERO = 5 then 1 end)/count(*) as No
	from coreData.Interview
	where CONSENTA=1 and ISEED=0;

title 'Total Percentage Meth (%)';
	select
	sum(case when INJ_METH < 5 then 1 end)/count(*) as Yes,
	sum(case when INJ_METH = 5 then 1 end)/count(*) as No
	from coreData.Interview
	where CONSENTA=1 and ISEED=0;

title 'Gender Breakdown';
	select
	sum(case when GENDER=1 then 1 end) as Male,
	sum(case when GENDER=2 then 1 end) as Female,
	sum(case when GENDER=3 then 1 end) as Transgender,
	sum(case when GENDER>3 then 1 end) as NA
	from coredata.Interview
	where CONSENTA=1 and ISEED=0;

title 'Gender Breakdown (%)';
	select
	sum(case when GENDER=1 then 1 end)/count(*) as Male,
	sum(case when GENDER=2 then 1 end)/count(*) as Female,
	sum(case when GENDER=3 then 1 end)/count(*) as Transgender,
	sum(case when GENDER>3 then 1 end)/count(*) as NA
	from coredata.Interview
	where CONSENTA=1 and ISEED=0;

title 'Field Site Breakdown';
	select FLDSTEID as Site, count(*) from coredata.Interview
	where CONSENTA=1 and ISEED=0 and FLDSTEID<4
	group by FLDSTEID;

title 'Field Site Breakdown (%)';
	select
	sum(case when FLDSTEID=0 then 1 end)/count(*) as StepUp,
	sum(case when FLDSTEID=1 then 1 end)/count(*) as WSL,
	sum(case when FLDSTEID=2 then 1 end)/count(*) as JBC,
	sum(case when FLDSTEID=3 then 1 end)/count(*) as RHC
	from coredata.Interview
	where CONSENTA=1 and ISEED=0 and FLDSTEID<4;

title 'Age Breakdown';
	select
	sum(case when AGE<30 then 1 end) as Young,
	sum(case when AGE>=30 and AGE<40 then 1 end) as Thirties,
	sum(case when AGE>=40 and AGE<50 then 1 end) as Forties,
	sum(case when AGE>=50 then 1 end) as Old
	from (select AGE from coredata.Interview where CONSENTA=1 and ISEED=0);

title 'Age Breakdown (%)';
	select
	sum(case when AGE<30 then 1 end)/count(*) as Young,
	sum(case when AGE>=30 and AGE<40 then 1 end)/count(*) as Thirties,
	sum(case when AGE>=40 and AGE<50 then 1 end)/count(*) as Forties,
	sum(case when AGE>=50 then 1 end)/count(*) as Old
	from (select AGE from coredata.Interview where CONSENTA=1 and ISEED=0);

title 'Orientation Breakdown';
	select 
	sum(case when IDENTITY=1 then 1 end) as Hetero,
	sum(case when IDENTITY=2 then 1 end) as Homo,
	sum(case when IDENTITY=3 then 1 end) as Bi,
	sum(case when IDENTITY>3 then 1 end) as NA
	from coredata.Interview
	where CONSENTA=1 and ISEED=0;

title 'Orientation Breakdown (%)';
	select 
	sum(case when IDENTITY=1 then 1 end)/count(*) as Hetero,
	sum(case when IDENTITY=2 then 1 end)/count(*) as Homo,
	sum(case when IDENTITY=3 then 1 end)/count(*) as Bi,
	sum(case when IDENTITY>3 then 1 end)/count(*) as NA
	from coredata.Interview
	where CONSENTA=1 and ISEED=0;

title 'Consent Breakdown (%)';
	select
	sum(CONSENTB)/count(*) as HIV, sum(CNSTHEP1)/count(*) as HCV, sum(CNSTSTG1R6)/count(*) as Storage
	from coredata.Interview
	where CONSENTA=1 and ISEED=0;

title 'Homelessness (12 mo) Breakdown';
	select EVRHOMLS as EverHomeless, count(*) from coredata.Interview
	where CONSENTA=1 and ISEED=0
	group by EVRHOMLS;
	
title 'Homelessness (12 mo) Breakdown (%)';
	select 
	sum(case when EVRHOMLS=0 then 1 end)/count(*) as No,
	sum(case when EVRHOMLS=1 then 1 end)/count(*) as Yes
	from coredata.Interview
	where CONSENTA=1 and ISEED=0;

title 'Current Homelessness Breakdown (out of ever homeless)';
	select CURHMLSS as CurrentHomeless, count(*) from coredata.Interview
	where CONSENTA=1 and ISEED=0 and EVRHOMLS=1
	group by CURHMLSS;

title 'Current Homelessness Breakdown (out of ever homeless %)';
	select 
	sum(case when CURHMLSS=0 then 1 end)/sum(EVRHOMLS) as No,
	sum(case when CURHMLSS=1 then 1 end)/sum(EVRHOMLS) as Yes,
	sum(case when CURHMLSS=7 then 1 end)/sum(EVRHOMLS) as Unknown
	from coredata.Interview
	where CONSENTA=1 and ISEED=0 and EVRHOMLS=1;

title 'Currently Homeless (out of all participants)';
	select 
	sum(case when CURHMLSS=0 then 1 end) as No,
	sum(case when CURHMLSS=1 then 1 end) as Yes,
	sum(case when CURHMLSS=7 then 1 end) as Unknown,
	sum(case when CURHMLSS=8 then 1 end) as NeverHomeless
	from coredata.Interview
	where CONSENTA=1 and ISEED=0;

title 'Currently Homeless (out of all participants %)';
	select 
	sum(case when CURHMLSS=0 then 1 end)/count(*) as No,
	sum(case when CURHMLSS=1 then 1 end)/count(*) as Yes,
	sum(case when CURHMLSS=7 then 1 end)/count(*) as Unknown,
	sum(case when CURHMLSS=8 then 1 end)/count(*) as NeverHomeless
	from coredata.Interview
	where CONSENTA=1 and ISEED=0;

title 'Ever Incarcerated';
	select EVHELD, count(*) from coredata.Interview
	where CONSENTA=1 and ISEED=0
	group by EVHELD;

title 'Incarcerated past 12mo';
	select HELD12M, count(*) from coredata.Interview
	where CONSENTA=1 and ISEED=0 and EVHELD=1
	group by HELD12M;

title 'Homelessness for those ever incarcerated';
	select 
	sum(case when CURHMLSS=0 then 1 end) as NotCurHmls,
	sum(case when CURHMLSS=1 then 1 end) as CurHmls,
	sum(case when CURHMLSS=8 then 1 end) as NeverHmls,
	sum(case when CURHMLSS=7 then 1 end) as NA 
	from coredata.Interview
	where CONSENTA=1 and ISEED=0 and EVHELD=1;

title 'Homelessness for those ever incarcerated (%)';
	select 
	sum(case when CURHMLSS=0 then 1 end)/count(*) as NotCurHmls,
	sum(case when CURHMLSS=1 then 1 end)/count(*) as CurHmls,
	sum(case when CURHMLSS=8 then 1 end)/count(*) as NeverHmls,
	sum(case when CURHMLSS=7 then 1 end)/count(*) as NA 
	from coredata.Interview
	where CONSENTA=1 and ISEED=0 and EVHELD=1;

title 'Homelessness for those never incarcerated';
	select 
	sum(case when CURHMLSS=0 then 1 end) as NotCurHmls,
	sum(case when CURHMLSS=1 then 1 end) as CurHmls,
	sum(case when CURHMLSS=8 then 1 end) as NeverHmls,
	sum(case when CURHMLSS=7 then 1 end) as NA 
	from coredata.Interview
	where CONSENTA=1 and ISEED=0 and EVHELD=0;

title 'Homelessness for those never incarcerated (%)';
	select 
	sum(case when CURHMLSS=0 then 1 end)/count(*) as NotCurHmls,
	sum(case when CURHMLSS=1 then 1 end)/count(*) as CurHmls,
	sum(case when CURHMLSS=8 then 1 end)/count(*) as NeverHmls,
	sum(case when CURHMLSS=7 then 1 end)/count(*) as NA 
	from coredata.Interview
	where CONSENTA=1 and ISEED=0 and EVHELD=0;

data raceNHBS;
set coredata.Interview;
if HISPANIC=1 then racetot=0;
else if sum(RACEA,RACEB,RACEC,RACED,RACEE)=1 and RACEA=1 then racetot=1;
else if sum(RACEA,RACEB,RACEC,RACED,RACEE)=1 and RACEB=1 then racetot=2;
else if sum(RACEA,RACEB,RACEC,RACED,RACEE)=1 and RACEC=1 then racetot=3;
else if sum(RACEA,RACEB,RACEC,RACED,RACEE)=1 and RACED=1 then racetot=4;
else if sum(RACEA,RACEB,RACEC,RACED,RACEE)=1 and RACEE=1 then racetot=5;
else racetot=6;

proc sql;
title 'Race Breakdown';
	select 
	sum(case when racetot=0 then 1 end) as HispLat,
	sum(case when racetot=1 then 1 end) as AIAN,
	sum(case when racetot=2 then 1 end) as Asian,
	sum(case when racetot=3 then 1 end) as Black,
	sum(case when racetot=4 then 1 end) as HPI,
	sum(case when racetot=5 then 1 end) as White,
	sum(case when racetot=6 then 1 end) as Multiracial 
	from raceNHBS
	where CONSENTA=1 and ISEED=0;

title 'Race Breakdown (%)';
	select 
	sum(case when racetot=0 then 1 end)/count(*) as HispLat,
	sum(case when racetot=1 then 1 end)/count(*) as AIAN,
	sum(case when racetot=2 then 1 end)/count(*) as Asian,
	sum(case when racetot=3 then 1 end)/count(*) as Black,
	sum(case when racetot=4 then 1 end)/count(*) as HPI,
	sum(case when racetot=5 then 1 end)/count(*) as White,
	sum(case when racetot=6 then 1 end)/count(*) as Multiracial 
	from raceNHBS
	where CONSENTA=1 and ISEED=0;


title 'Dependent Breakdown';
	select DEPENDR6, count(*) from coredata.Interview
	where CONSENTA=1 and ISEED=0
	group by DEPENDR6;

title 'Dependent/Income Breakdown';
	select HHINCR6, 
	sum(case when DEPENDR6=1 then 1 end) as Self,
	sum(case when DEPENDR6=2 then 1 end) as OneDependent,
	sum(case when DEPENDR6=3 then 1 end) as TwoDependent,
	sum(case when DEPENDR6=4 then 1 end) as ThreeDependent,
	sum(case when DEPENDR6>4 then 1 end) as MoreDependent
	from coredata.Interview
	where CONSENTA=1 and ISEED=0 and DEPENDR6<20
	group by HHINCR6;
run;

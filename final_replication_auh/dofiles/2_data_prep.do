********************************************************************************
/*do-file: 2_data_prep
********************************************************************************
********************************************************************************
****project title: AUH_argentina			
****database used: INDEC - Encuesta permanente de hogares (EPH)
****authors: S. Carrère	
********************************************************************************
********************************************************************************
****description: -keep households monitored over time 
				 -variable creation for monitoring over time
****date: 20/11/2024	created
****date: 20/10/2025	modified
*/
********************************************************************************

cd "$AUH_argentina/data"

/*******************************************************************************
********************************************************************************
STEP 1: Prepare data for merging
********************************************************************************
*******************************************************************************/
use basehog_2003_2015.dta, clear

*Year_quarter
egen ANO_TRIM = concat(ANO4 TRIMESTRE),punct("_")
label variable ANO_TRIM "Year and quarter"
order ANO_TRIM, b(TRIMESTRE)

*household id
egen ID_mob = group(CODUSU NRO_HOGAR)
label variable ID_mob "Household ID for all periods"

*households id between pairs of observations
egen ID = group(CODUSU NRO_HOGAR TRIMESTRE)
label variable ID "Household ID for panel periods (t to t+1) "
order ID_mob ID, b(HOGID_men)

*identify the time period
egen panel = group(ANO4 TRIM)
*identify a pair of observation for a household between t and t+1
egen panelmax = max(panel), by(ID)
egen panelmin = min(panel), by(ID)
*identify the earliest and latest observation for a household
egen panelmax_ID_mob = max(panel), by(ID_mob)
egen panelmin_ID_mob = min(panel), by(ID_mob)



sort ID_mob ANO_TRIM
*count number of observations per household 
egen hh_count = seq(), by(ID_mob)

*indicate the first interview for a household
gen hog_obs = 1 if hh_count==1
replace hog_obs = 0 if hog_obs==. 

*count how many times the household is interview in the survey
duplicates tag ID_mob , generate(rep_hh)
gen nb_dupli = rep_hh+1
drop rep_hh

*indicate the first year of interview
gen initial_year = 1 if (hh_count==1|hh_count==2) & nb_dupli==4
replace initial_year = 0 if (hh_count==3|hh_count==4) & nb_dupli==4
replace initial_year = 1 if hh_count==1
replace initial_year = 0 if hh_count==2 & nb_dupli==2 & panel==panelmax
replace initial_year = 0 if hh_count==2 & nb_dupli==2 & panel==panelmin_ID_mob+1 
replace initial_year = 1 if hh_count==2 & nb_dupli==3 & panel==panelmin_ID_mob+1 
replace initial_year = 0 if hh_count==3 & nb_dupli==3 & panel==panelmax_ID_mob 
replace initial_year = 0 if hh_count==2 & nb_dupli==3 & panel==panelmax_ID_mob-1 
*indicate the final year of interview
gen final_year = 1 if initial_year==0
replace final_year=0 if initial_year==1

*indicate the initial (=1) or final year of interview (=2)
gen wave = 1 if initial_year==1
replace wave = 2 if final_year==1

*indicate if the follow-up is only for 6 months
gen intra_y = 1 if final_year==1 & panel==panelmin_ID_mob+1
replace intra_y=0 if intra_y==.
egen intra_year = max(intra_y), by(ID_mob)
drop intra_y initial_year final_year

*indicate if the household follow-up is during the AUH implementation period
gen auh_implementation = 0
replace auh_implementation = 1 if nb_dupli==4 & panelmin_ID_mob>=20 & panelmin_ID_mob<=25
replace auh_implementation = 1 if nb_dupli==3 & panelmin_ID_mob>=20 & panelmin_ID_mob<=25 & panelmax_ID_mob>=25 & panelmax_ID_mob<=30
replace auh_implementation = 1 if nb_dupli==2 & panelmin_ID_mob>=20&panelmin_ID_mob<=25 & panelmax_ID_mob>=25

*generate a time variable with panels of hh observations
gen ano_panel = 1 if panelmin==1&panelmax==5 | panelmin==2&panelmax==6
replace ano_panel = 2 if panelmin==3&panelmax==7 | panelmin==4&panelmax==8 | panelmin==5&panelmax==9 | panelmin==6&panelmax==10 
replace ano_panel = 3 if panelmin==7&panelmax==11 | panelmin==8&panelmax==12 | panelmin==9&panelmax==13 | panelmin==10&panelmax==14 
replace ano_panel = 4 if panelmin==11&panelmax==15 | panelmin==12&panelmax==16 | panelmin==14&panelmax==17 
replace ano_panel = 5 if panelmin==15&panelmax==18 | panelmin==16&panelmax==19 | panelmin==17&panelmax==21 
replace ano_panel = 6 if panelmin==18&panelmax==22 | panelmin==19&panelmax==23 | panelmin==20&panelmax==24 | panelmin==21&panelmax==25
replace ano_panel = 7 if panelmin==22&panelmax==26 | panelmin==23&panelmax==27 | panelmin==24&panelmax==28 | panelmin==25&panelmax==29 
replace ano_panel = 8 if panelmin==26&panelmax==30 | panelmin==27&panelmax==31 | panelmin==28&panelmax==32 | panelmin==29&panelmax==33 
replace ano_panel = 9 if panelmin==30&panelmax==34 | panelmin==31&panelmax==35 | panelmin==32&panelmax==36 | panelmin==33&panelmax==37 
replace ano_panel = 10 if panelmin==34&panelmax==38 | panelmin==35&panelmax==39 | panelmin==36&panelmax==40 | panelmin==37&panelmax==41 
replace ano_panel = 11 if panelmin==38&panelmax==42 | panelmin==40&panelmax==44 | panelmin==41&panelmax==45
replace ano_panel = 12 if panelmin==42&panelmax==46 | panelmin==43&panelmax==47
replace ano_panel=1 if ano_panel==. & nb_dupli==2 & (panelmin_ID_mob>=1&panelmin_ID_mob<=2) & (panelmax_ID_mob>=2&panelmax_ID_mob<=7)
replace ano_panel=2 if ano_panel==. & nb_dupli==2 & (panelmin_ID_mob>=3&panelmin_ID_mob<=6) & (panelmax_ID_mob>=4&panelmax_ID_mob<=11)
replace ano_panel=3 if ano_panel==. & nb_dupli==2 & (panelmin_ID_mob>=7&panelmin_ID_mob<=10) & (panelmax_ID_mob>=8&panelmax_ID_mob<=15)
replace ano_panel=4 if ano_panel==. & nb_dupli==2 & (panelmin_ID_mob>=11&panelmin_ID_mob<=14) & (panelmax_ID_mob>=12&panelmax_ID_mob<=18)
replace ano_panel=5 if ano_panel==. & nb_dupli==2 & (panelmin_ID_mob>=15&panelmin_ID_mob<=17) & (panelmax_ID_mob>=16&panelmax_ID_mob<=22)
replace ano_panel=6 if ano_panel==. & nb_dupli==2 & (panelmin_ID_mob>=18&panelmin_ID_mob<=21) & (panelmax_ID_mob>=19&panelmax_ID_mob<=26)
replace ano_panel=7 if ano_panel==. & nb_dupli==2 & (panelmin_ID_mob>=22&panelmin_ID_mob<=25) & (panelmax_ID_mob>=23&panelmax_ID_mob<=30)
replace ano_panel=8 if ano_panel==. & nb_dupli==2 & (panelmin_ID_mob>=26&panelmin_ID_mob<=29) & (panelmax_ID_mob>=27&panelmax_ID_mob<=34)
replace ano_panel=9 if ano_panel==. & nb_dupli==2 & (panelmin_ID_mob>=30&panelmin_ID_mob<=33) & (panelmax_ID_mob>=31&panelmax_ID_mob<=38)
replace ano_panel=10 if ano_panel==. & nb_dupli==2 & (panelmin_ID_mob>=34&panelmin_ID_mob<=37) & (panelmax_ID_mob>=35&panelmax_ID_mob<=42)
replace ano_panel=11 if ano_panel==. & nb_dupli==2 & (panelmin_ID_mob>=38&panelmin_ID_mob<=41) & (panelmax_ID_mob>=39&panelmax_ID_mob<=46)
replace ano_panel=12 if ano_panel==. & nb_dupli==2 & (panelmin_ID_mob>=42&panelmin_ID_mob<=45) & (panelmax_ID_mob>=43&panelmax_ID_mob<=47)
egen max_ano_panel = max(ano_panel),by(ID_mob)
replace ano_panel = max_ano_panel if ano_panel==. & nb_dupli==3 

label define ano_panel_name 1"2003-2004" 2"2004-2005" 3"2005-2006" 4"2006-2007" 5"2007-2008" ///
							6"2008-2009" 7"2009-2010" 8"2010-2011" 9"2011-2012" 10"2012-2013" 11"2013-2014" 12"2014-2015" ,replace
label values ano_panel ano_panel_name
label variable ano_panel "Panels"



*Create household income variables 

//IPCF converted into PPP $US alternative factor (2011) (factor conversion 14.23)
gen IPCF_US = IPCF_cpi/14.23
**mean income over waves (alt)
egen m_IPCF_US_ano1 = mean(IPCF_US) if wave==1, by(ID_mob)
egen m_IPCF_US_ano2 = mean(IPCF_US) if wave==2, by(ID_mob)
egen m_IPCF_US_an1 = max(m_IPCF_US_ano1), by(ID_mob)
egen m_IPCF_US_an2 = max(m_IPCF_US_ano2), by(ID_mob)
*mean income over the period and standard deviation (alt)
bysort ID_mob: egen mean_IPCF_US = mean(IPCF_US) 
bysort ID_mob: egen sd_IPCF_US = sd(IPCF_US) 
gen CV_IPCF = sd_IPCF_US/mean_IPCF_US
replace CV_IPCF = 0 if CV_IPCF==. & nb_dupli!=1

//generation an income variable of $US PPP per day (alt)
gen IPCF_US_pd_an1 = m_IPCF_US_an1/30
gen IPCF_US_pd_an2 = m_IPCF_US_an2/30

//count the number of periods classified as poverty
gen poor_period_511 = 1 if catrev_511==1
replace poor_period_511 = 0 if catrev_511!=1 
egen nb_poor_period_511 = total(poor_period_511) , by(ID_mob)
egen mean_poor_period_511 = mean(poor_period_511), by(ID_mob) 
label variable mean_poor_period_511 "Average time spent in poverty during the observation period with PPP $US (2011) ; factor conversion 14.23"

*create the income groups based on the average per capita income 
gen catrev_511_an1=1 if IPCF_US_pd_an1<5.5 & IPCF_US_pd_an1!=.
replace catrev_511_an1=2 if IPCF_US_pd_an1>=5.5 & IPCF_US_pd_an1<11.5 & IPCF_US_pd_an1!=.
replace catrev_511_an1=3 if IPCF_US_pd_an1>=11.5 & IPCF_US_pd_an1!=.
gen catrev_511_an2=1 if IPCF_US_pd_an2<5.5 & IPCF_US_pd_an2!=.
replace catrev_511_an2=2 if IPCF_US_pd_an2>=5.5 & IPCF_US_pd_an2<11.5 & IPCF_US_pd_an2!=.
replace catrev_511_an2=3 if IPCF_US_pd_an2>=11.5 & IPCF_US_pd_an2!=.
label define catrev_class 1"Poor" 2"Vulnerable" 3"Middle and upper-income groups",replace
label values catrev_511_an1 catrev_class
label values catrev_511_an2 catrev_class

*
gen catrev_513_an1=1 if IPCF_US_pd_an1<5.5 & IPCF_US_pd_an1!=.
replace catrev_513_an1=2 if IPCF_US_pd_an1>=5.5 & IPCF_US_pd_an1<13.5 & IPCF_US_pd_an1!=.
replace catrev_513_an1=3 if IPCF_US_pd_an1>=13.5 & IPCF_US_pd_an1!=.
gen catrev_513_an2=1 if IPCF_US_pd_an2<5.5 & IPCF_US_pd_an2!=.
replace catrev_513_an2=2 if IPCF_US_pd_an2>=5.5 & IPCF_US_pd_an2<13.5 & IPCF_US_pd_an2!=.
replace catrev_513_an2=3 if IPCF_US_pd_an2>=13.5 & IPCF_US_pd_an2!=.
label values catrev_513_an1 catrev_class
label values catrev_513_an2 catrev_class

*
gen catrev_515_an1=1 if IPCF_US_pd_an1<5.5 & IPCF_US_pd_an1!=.
replace catrev_515_an1=2 if IPCF_US_pd_an1>=5.5 & IPCF_US_pd_an1<15.5 & IPCF_US_pd_an1!=.
replace catrev_515_an1=3 if IPCF_US_pd_an1>=15.5 & IPCF_US_pd_an1!=.
gen catrev_515_an2=1 if IPCF_US_pd_an2<5.5 & IPCF_US_pd_an2!=.
replace catrev_515_an2=2 if IPCF_US_pd_an2>=5.5 & IPCF_US_pd_an2<15.5 & IPCF_US_pd_an2!=.
replace catrev_515_an2=3 if IPCF_US_pd_an2>=15.5 & IPCF_US_pd_an2!=.
label values catrev_515_an1 catrev_class
label values catrev_515_an2 catrev_class


*decile IPCF
gen DECCFR_num = 0 if DECCFR=="00"
replace DECCFR_num = 1 if DECCFR=="01"
replace DECCFR_num = 2 if DECCFR=="02"
replace DECCFR_num = 3 if DECCFR=="03"
replace DECCFR_num = 4 if DECCFR=="04"
replace DECCFR_num = 5 if DECCFR=="05"
replace DECCFR_num = 6 if DECCFR=="06"
replace DECCFR_num = 7 if DECCFR=="07"
replace DECCFR_num = 8 if DECCFR=="08"
replace DECCFR_num = 9 if DECCFR=="09"
replace DECCFR_num = 10 if DECCFR=="10"
gen DECCFR_num_ano1 = DECCFR_num if wave==1
egen DECCFR_num_an1=max(DECCFR_num_ano1), by(ID)
*indicate the maximum income decile of a household in the per capita household income distribution
egen DECCFR_num_mob_an1=max(DECCFR_num_ano1), by(ID_mob)


//creates a variable if one person in the household imputed income values 
gen imput = 1 if IDIMPH!="00000"
replace imput = 0 if imput==.
//if the household imputed income value across waves
egen imput_hh_year = max(imput), by(ID_mob)


save basehog_mob_2003_2015.dta, replace



/*******************************************************************************
********************************************************************************
STEP 2: Merge household and individual level
********************************************************************************
*******************************************************************************/


cd "$AUH_argentina/data"

use baseind_2003_2015.dta, clear

egen ANO_TRIM = concat(ANO4 TRIMESTRE),punct("_")
label variable ANO_TRIM "Year and quarterly"
order ANO_TRIM, b(TRIMESTRE)

//Matching with households with monitoring over time
merge m:1 HOGID_men ANO_TRIM using basehog_mob_2003_2015.dta
drop _merge

*create an unique ID for each household member
egen ID_ind = group(CODUSU NRO_HOGAR COMPONENTE TRIMESTRE)
order ID_mob ID ID_ind , b(HOGID_men)
order wave, b(ANO4)

*create an unique ID for each household member for all waves
egen ID_ind_mob = group(CODUSU NRO_HOGAR COMPONENTE)
order ID_ind_mob , b(ID_ind)
order wave, b(ANO4)

**fixed effect region and time
ta REGION, g(reg_n)
ta ano_panel, g(t_)


**keep only households with a follow-up located in 2004-2015 period
*keep if ano_panel>=2 & ano_panel<=12

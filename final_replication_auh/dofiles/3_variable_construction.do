********************************************************************************
/*do-file: 3_variable_construction
********************************************************************************
********************************************************************************
****project title: AUH_argentina			
****database used: INDEC - Encuesta permanente de hogares (EPH)
****authors: S. Carrère	
********************************************************************************
********************************************************************************
****description: -create variables for the analysis
				
****date: 20/11/2024	created
****date: 20/10/2025	modified
*/
********************************************************************************

cd "$AUH_argentina/data"

*create a variable which identifies the head of household in the earliest interview
gen hog_obs_jefe = hog_obs if CH03==1
replace hog_obs_jefe = 0 if hog_obs_jefe==.

*Correct some errors in the dataset
bys HOGID_men ANO_TRIM: egen min_CH03 = min(CH03)
replace CH03=1 if CH03==2 & HOGID_men=="146027  _1" & ANO_TRIM=="2009_2"
replace CH03=1 if CH03==2 & HOGID_men=="146027  _1" & ANO_TRIM=="2009_3"

replace CH04=1 if CH03==10 & CH04==2 & HOGID_men=="149527  _1" & ANO_TRIM=="2003_3"
replace CH03=1 if CH03==10 & HOGID_men=="149527  _1" & ANO_TRIM=="2003_3"

replace CH03=1 if CH03==9 & HOGID_men=="232446  _1" & ANO_TRIM=="2003_3"

replace CH03=1 if CH03==2 & HOGID_men=="243433  _1" & ANO_TRIM=="2003_3"
replace CH04=2 if CH03==1 & HOGID_men=="243433  _1" & ANO_TRIM=="2003_3"

replace CH03=1 if CH03==9 & HOGID_men=="267099  _1" & ANO_TRIM=="2009_1"


/*******************************************************************************
********************************************************************************
STEP 1: Control variables
********************************************************************************
*******************************************************************************/

**age and age_sq variable
replace CH06 = . if CH06==99 //recode age variable
replace CH06 = 98 if CH06>=98
replace CH06 = 0 if CH06==-1
gen age = CH06
label variable age "Age of the hh member"
gen age_sq = age*age
label variable age_sq "Age square of the hh member"

**identification of minor and major children + disabled 
gen child_min=1 if (CH03==3|CH03==5) & age<=17 
replace child_min = 0 if child_min==. 
gen child_maj=1 if (CH03==3|CH03==5) & age>=18
replace child_maj= 0 if child_maj==. 
gen disable=1 if (CH03==3|CH03==5) & CAT_INAC==6
replace disable= 0 if disable==. 

**total number in the household
bysort HOGID_men ANO_TRIM: egen child_min_tot=total(child_min)
label variable child_min_tot "Nb of minor children in the hh"

bysort HOGID_men ANO_TRIM: egen child_maj_tot=total(child_maj)
label variable child_maj_tot "Nb of major children in the hh"

bysort HOGID_men ANO_TRIM: egen disable_tot=total(disable)
label variable disable_tot "Nb of disable person in the hh"

bysort HOGID_men ANO_TRIM: gen child_min_tot_sq=child_min_tot^2
label variable child_min_tot_sq "Nb of minor children in the hh (sq value)"

bysort HOGID_men ANO_TRIM: gen child_maj_tot_sq=child_maj_tot^2
label variable child_maj_tot_sq "Nb of major children in the hh (sq value)"
drop child_min child_maj disable


*if nieto in the household 
gen nieto = 1 if CH03==5
replace nieto = 0 if CH03!=5
bysort HOGID_men ANO_TRIM: egen total_nieto = total(nieto)
label variable total_nieto "Nb of nieto in the hh"
drop nieto

*grandparents in the household
gen gd_parent = 1 if (CH03==1|CH03==2)&total_nieto>=1
//replace gd_parent = 1 if  CH03==6 //MODIF 24/04/24
replace gd_parent = 0 if gd_parent==.
egen hog_gd_parent=max(gd_parent), by(HOGID_men ANO_TRIM)
label variable hog_gd_parent "Takes the value 1 if the grandparents are living within the household"
drop gd_parent

*age of the youngest child
egen age_min_child = min(age) if (CH03==3&total_nieto==0) |  (CH03==5&total_nieto>0), by(ID wave)
egen youngest_child = max(age_min_child) , by(ID wave)
label variable youngest_child "Age of the youngest child in the hh"

*If the household has a minor children in the hh
gen hog_child_disa = 1 if child_min_tot>0 | disable_tot>0
replace hog_child_disa = 0 if child_min_tot==0 & disable_tot==0
gen hog_child_disa_ano1 = hog_child_disa if wave==1 
gen hog_child_disa_ano2 = hog_child_disa if wave==2
egen hog_child_disa_an1=max(hog_child_disa_ano1), by(ID)
egen hog_child_disa_an2=max(hog_child_disa_ano2), by(ID)

*Have children for the first year of interview
egen hog_child_year_an1 = min(hog_child_disa_an1), by(ID_mob)
egen hog_child_year_an2 = min(hog_child_disa_an2), by(ID_mob)
label variable hog_child_year_an1 "1 if children in the hh during the first year of the survey"
label variable hog_child_year_an2 "1 if children in the hh during the second year of the survey"

drop age_min_child hog_child_disa_ano1 hog_child_disa_ano2

**identification of domestic workers workers
gen domestic_wk = 0
recode domestic_wk (0=1) if PP04B1==1
label define domestic_wk_name 0"No" 1"Yes",replace
label values domestic_wk domestic_wk_name
label variable domestic_wk "Is the person a domestic worker?"

**identification of single-parent household
bysort HOGID_men ANO_TRIM: gen conj = 1 if CH03==2
bysort HOGID_men ANO_TRIM: replace conj = 0 if CH03!=2
bysort HOGID_men ANO_TRIM: egen conj_tot = total(conj)
drop conj

**identification of female-headed household
bysort HOGID_men ANO_TRIM: gen hh_fem = 1 if CH03==1&CH04==2
bysort HOGID_men ANO_TRIM: replace hh_fem = 0 if CH03==1&CH04==1
label variable hh_fem "Takes value 1 if the person the head of household is a woman"

**Pluriactivity of the head-household
gen pluri_simple = 0
recode pluri_simple (0=1) if PP03C==2
label define pluri_simple_name 0"No" 1"Yes",replace
label values pluri_simple pluri_simple_name
label variable pluri_simple "Having simple job or multi acitivities"
gen pluri_act = 1 if pluri_simple==1 & CH03==1
replace pluri_act = 0 if pluri_simple==0 & CH03==1
replace pluri_act = 1 if pluri_simple==1 & CH03==2
replace pluri_act = 0 if pluri_simple==0 & CH03==2
bysort HOGID_men ANO_TRIM: egen pluri_hog =  max(pluri_act)
label variable pluri_hog "The head/spouse has multi occupations"
drop pluri_simple pluri_act


*Indicates if the household received the PJJHD program during the period
gen jjhd = 1 if PJ1_1==1|PJ2_1==1|PJ3_1==1
replace jjhd=0 if PJ1_1!=1&PJ2_1!=1&PJ3_1!=1
egen jjhd_id = max(jjhd), by(HOGID_men ANO_TRIM)
egen jjhd_hog = max(jjhd_id), by(ID_mob)
label variable jjhd_hog "if the hh received the PJJHD program over the period"
drop jjhd jjhd_id

*******************************
***** Education variables *****
*******************************

**dummies education level
gen educ_prii = 1 if NIVEL_ED == 7 | NIVEL_ED==1
replace educ_prii = 0 if NIVEL_ED!=7&NIVEL_ED!=1
gen educ_pric = 1 if NIVEL_ED == 2
replace educ_pric = 0 if NIVEL_ED!=2
gen educ_seci = 1 if NIVEL_ED == 3
replace educ_seci = 0 if NIVEL_ED!=3
gen educ_secc = 1 if NIVEL_ED == 4
replace educ_secc = 0 if NIVEL_ED!=4
gen educ_supi = 1 if NIVEL_ED == 5 
replace educ_supi = 0 if NIVEL_ED!=5
gen educ_supc = 1 if NIVEL_ED == 6 
replace educ_supc = 0 if NIVEL_ED!=6

gen ed_jefe = 1 if educ_prii==1 & CH03==1
replace ed_jefe = 2 if educ_pric==1 & CH03==1
replace ed_jefe = 3 if educ_seci==1 & CH03==1
replace ed_jefe = 4 if educ_secc==1 & CH03==1
replace ed_jefe = 5 if educ_supi==1 & CH03==1
replace ed_jefe = 6 if educ_supc==1 & CH03==1
bysort HOGID_men ANO_TRIM: egen educ_jefe = total(ed_jefe)

gen ed_conj = 1 if educ_prii==1  & CH03==2
replace ed_conj = 2 if educ_pric==1 & CH03==2
replace ed_conj = 3 if educ_seci==1 & CH03==2
replace ed_conj = 4 if educ_secc==1 & CH03==2
replace ed_conj = 5 if educ_supi==1 & CH03==2
replace ed_conj = 6 if educ_supc==1 & CH03==2
bysort HOGID_men ANO_TRIM: egen educ_conj = total(ed_conj) if conj_tot==1 

gen ed_parent = 1 if educ_prii==1 & CH03==1
replace ed_parent = 2 if educ_pric==1 & CH03==1
replace ed_parent = 3 if educ_seci==1 & CH03==1
replace ed_parent = 4 if educ_secc==1 & CH03==1
replace ed_parent = 5 if educ_supi==1 & CH03==1
replace ed_parent = 6 if educ_supc==1 & CH03==1
replace ed_parent = 1 if educ_prii==1 & CH03==2
replace ed_parent = 2 if educ_pric==1 & CH03==2
replace ed_parent = 3 if educ_seci==1 & CH03==2
replace ed_parent = 4 if educ_secc==1 & CH03==2
replace ed_parent = 5 if educ_supi==1 & CH03==2
replace ed_parent = 6 if educ_supc==1 & CH03==2

**maximum education level of the parents
bysort HOGID_men ANO_TRIM: egen educ_hog =  max(ed_parent)
gen educ_hog_prii = 1 if educ_hog==1
replace educ_hog_prii = 0 if educ_hog!=1
gen educ_hog_pric = 1 if educ_hog==2
replace educ_hog_pric = 0 if educ_hog!=2
gen educ_hog_seci = 1 if educ_hog==3
replace educ_hog_seci = 0 if educ_hog!=3
gen educ_hog_secc = 1 if educ_hog==4
replace educ_hog_secc = 0 if educ_hog!=4
gen educ_hog_supi = 1 if educ_hog==5
replace educ_hog_supi = 0 if educ_hog!=5
gen educ_hog_supc = 1 if educ_hog==6
replace educ_hog_supc = 0 if educ_hog!=6
label variable educ_hog_prii "Parents' education level: primary incomplete at most"
label variable educ_hog_pric "Parents' education level: primary complete at most"
label variable educ_hog_seci "Parents' education level: secondary inc. at most"
label variable educ_hog_secc "Parents' education level: secondary comp. at most"
label variable educ_hog_supi "Parents' education level: post-sec inc. at most"
label variable educ_hog_supc "Parents' education level: post-sec comp. at most"

**education simplified
gen educ_hog_pri = 1 if educ_hog_prii==1|educ_hog_pric==1
replace educ_hog_pri=0 if educ_hog_prii==0&educ_hog_pric==0
gen educ_hog_sec = 1 if educ_hog_seci==1|educ_hog_secc==1
replace educ_hog_sec=0 if educ_hog_seci==0&educ_hog_secc==0
gen educ_hog_sup = 1 if educ_hog_supi==1|educ_hog_supc==1
replace educ_hog_sup=0 if educ_hog_supi==0&educ_hog_supc==0
label variable educ_hog_pri "Parents' education level: primary at most"
label variable educ_hog_sec "Parents' education level: secondary at most"
label variable educ_hog_sup "Parents' education level: post-secondary at most"




*****************************************
***** Other covariates for analysis *****
*****************************************

gen trim1 = 1 if TRIMESTRE==1
replace trim1 = 0 if TRIMESTRE!=1
gen trim2 = 1 if TRIMESTRE==2
replace trim2 = 0 if TRIMESTRE!=2
gen trim3 = 1 if TRIMESTRE==3
replace trim3 = 0 if TRIMESTRE!=3
gen trim4 = 1 if TRIMESTRE==4
replace trim4 = 0 if TRIMESTRE!=4

gen large_hh = 1 if IX_TOT>=6
replace large_hh = 0 if IX_TOT<=5
label variable large_hh "Large household: 6 and more members"
gen married = 1 if CH07==2
replace married = 0 if CH07!=2
label variable married "Married parents"
gen single = 1 if CH07==3|CH07==4|CH07==5
replace single = 0 if CH07!=3&CH07!=4&CH07!=5
label variable single "Single parent/divorced/widowed"
gen age30 = 1 if age<=30
replace age30 = 0 if age>=31
label variable age30 "Head of hh under 31"
gen age60=1 if age>=60
replace age60 = 0 if age<=59
label variable age60 "Head of hh 60 and above"
gen young_child5 = 1 if youngest_child<=5
replace young_child5 = 0 if youngest_child>5
label variable young_child5 "Young child under 6 in the hh"
gen more_children_3 = 1 if child_min_tot>=3
replace more_children_3 = 0 if child_min_tot<3
label variable age30 "Household with 3 or more minor children"
gen young_head = 1 if age<=30
replace young_head = 0 if age>=31
gen big_city = 1 if MAS_500=="S"
replace big_city = 0 if MAS_500 =="N"
gen proprietario = 1 if II7==1
replace proprietario = II7!=1


**************************************
***** Income stability variables *****
**************************************

**Variables for the standard deviation of arc percentage change in income
gen IPCF_period_1 = IPCF_cpi if CH03==1 & hh_count==1
gen IPCF_period_2 = IPCF_cpi if CH03==1 & hh_count==2
gen IPCF_period_3 = IPCF_cpi if CH03==1 & hh_count==3
gen IPCF_period_4 = IPCF_cpi if CH03==1 & hh_count==4

egen IPCF_p1 = max(IPCF_period_1), by(ID_mob)
egen IPCF_p2 = max(IPCF_period_2), by(ID_mob)
egen IPCF_p3 = max(IPCF_period_3), by(ID_mob)
egen IPCF_p4 = max(IPCF_period_4), by(ID_mob)

gen arc_percentage_change_1_2 = ((IPCF_p2 - IPCF_p1) / ((IPCF_p1 + IPCF_p2) / 2)) * 100
gen arc_percentage_change_2_3 = ((IPCF_p3 - IPCF_p2) / ((IPCF_p2 + IPCF_p3) / 2)) * 100
gen arc_percentage_change_3_4 = ((IPCF_p4 - IPCF_p3) / ((IPCF_p3 + IPCF_p4) / 2)) * 100

replace arc_percentage_change_1_2 = 0 if IPCF_p1==0 & IPCF_p2==0
replace arc_percentage_change_2_3 = 0 if IPCF_p2==0 & IPCF_p3==0
replace arc_percentage_change_3_4 = 0 if IPCF_p3==0 & IPCF_p4==0

*Mean arc percentage change for each household
egen mean_arc_percentage_change = rowmean(arc_percentage_change_1_2 arc_percentage_change_2_3 arc_percentage_change_3_4) if hog_obs_jefe==1 
egen sd_arcper_change = rowsd(arc_percentage_change_1_2 arc_percentage_change_2_3 arc_percentage_change_3_4) if hog_obs_jefe==1 
label variable sd_arcper_change "Standard deviation of the arc-percentage change in income"


**Income decomposition
foreach var in  ITF P47T V2_M V5_M V10_M V9_M V8_M V12_M V3_M V4_M V11_M V18_M V19_AM V21_M P21 TOT_P12 T_VI PP08J1 PP08J2 PP08J3 {
	gen `var'_cpi = `var'/cpi
	}
foreach var in  V2_M_cpi V5_M_cpi V10_M_cpi V9_M_cpi V8_M_cpi V12_M_cpi V3_M_cpi V4_M_cpi V11_M_cpi V18_M_cpi V19_AM_cpi V21_M_cpi {
bysort HOGID_men ANO_TRIM: 	egen `var'_tot = total(`var')
	}	
foreach var in  V2_M_cpi_tot V5_M_cpi_tot V10_M_cpi_tot V9_M_cpi_tot V8_M_cpi_tot V12_M_cpi_tot V3_M_cpi_tot V4_M_cpi_tot V11_M_cpi_tot V18_M_cpi_tot V19_AM_cpi_tot V21_M_cpi_tot {
bysort HOGID_men ANO_TRIM: 	gen `var'_pc = `var'/IX_TOT
	}	

gen ln_IPCF_cpi = ln(IPCF_cpi)
gen ln_IPCF_cpi_sq = ln_IPCF_cpi^2

**Labor and non labor income

*individual level
gen income_labor = P47T_cpi - T_VI_cpi 
gen income_nolabor = P47T_cpi - income_labor
gen income = income_labor + income_nolabor

*total income in the household
bysort HOGID_men ANO_TRIM: egen income_labor_tot = total(income_labor)
bysort HOGID_men ANO_TRIM: egen income_nolabor_tot = total(income_nolabor)
bysort HOGID_men ANO_TRIM: egen income_tot = total(income)

*per capita
gen income_labor_pc = income_labor_tot/IX_TOT
gen income_nolabor_pc = income_nolabor_tot/IX_TOT
gen income_pc = income_tot/IX_TOT

*share of income from labor, nonlabor, income from friends, and income from the state in the total household income
gen income_labor_prop = income_labor_tot/income_tot if CH03==1
gen income_nolab_prop = income_nolabor_tot/income_tot if CH03==1
gen V12_M_prop= V12_M_cpi_tot/income_tot if CH03==1
gen V5_M_prop = V5_M_cpi_tot/income_tot if CH03==1

*income from labor including pensions from retirement
gen income_labor_pen = income_labor + V2_M_cpi
*total
bysort HOGID_men ANO_TRIM: egen income_labor_pen_tot = total(income_labor_pen)
*per capita
gen income_labor_pen_pc = income_labor_pen_tot/IX_TOT

*income from nonlabor sources minus pensions from retirement
gen income_nolabor_pen = income_nolabor - V2_M_cpi
*total 
bysort HOGID_men ANO_TRIM: egen income_nolabor_pen_tot = total(income_nolabor_pen)
*per capita
gen income_nolabor_pen_pc = income_nolabor_pen_tot/IX_TOT
*share in the total household income
gen income_labor_pen_prop = income_labor_pen_tot/income_tot
gen income_nolab_pen_prop = income_nolabor_pen_tot/income_tot


*Mean across all the observation period
egen mean_income_tot_full = mean(income_tot) if CH03==1, by(ID_mob)
egen mean_V5_M_full = mean(V5_M_cpi_tot) if CH03==1, by(ID_mob)
egen mean_V12_M_full = mean(V12_M_cpi_tot) if CH03==1, by(ID_mob)
egen mean_income_lab_full = mean(income_labor_tot) if CH03==1 , by(ID_mob)
egen mean_income_nolab_full = mean(income_nolabor_tot) if CH03==1 , by(ID_mob)
egen mean_income_lab_pen_full = mean(income_labor_pen_tot) if CH03==1 , by(ID_mob)
egen mean_income_nolab_pen_full = mean(income_nolabor_pen_tot) if CH03==1 , by(ID_mob)
*per capita
egen mean_income_lab_pc_full = mean(income_labor_pc) if CH03==1 , by(ID_mob)
egen mean_income_nolab_pc_full = mean(income_nolabor_pc) if CH03==1 , by(ID_mob)

*share of the labor/nonlabor income  
gen m_income_lab_full_prop = mean_income_lab_full/mean_income_tot_full if CH03==1
replace m_income_lab_full_prop = 0 if mean_income_tot_full==0 & CH03==1
gen m_income_nolab_full_prop = mean_income_nolab_full/mean_income_tot_full if CH03==1
replace m_income_nolab_full_prop = 0 if mean_income_tot_full==0 & CH03==1

*share of the labor/nonlabor income  (including pensions in labor income)
gen m_income_lab_pen_full_prop = mean_income_lab_pen_full/mean_income_tot_full if CH03==1
replace m_income_lab_pen_full_prop = 0 if mean_income_tot_full==0 & CH03==1
gen m_income_nolab_pen_full_prop = mean_income_nolab_pen_full/mean_income_tot_full if CH03==1
replace m_income_nolab_pen_full_prop = 0 if mean_income_tot_full==0 & CH03==1

*share of income from friends + state
gen m_V12_M_full_prop = mean_V12_M_full/mean_income_tot_full if CH03==1
replace m_V12_M_full_prop=0 if mean_income_tot_full==0 & CH03==1
gen m_V5_M_full_prop = mean_V5_M_full/mean_income_tot_full if CH03==1
replace m_V5_M_full_prop=0 if mean_income_tot_full==0 & CH03==1


//Variables for equivalised income (modified OECD scale)
gen eq_weights = .
replace eq_weights = 1 if CH03 ==1
replace eq_weights = 0.5 if CH03!=1 & age>=14
replace eq_weights = 0.3 if CH03!=1 & age<14
bysort HOGID_men ANO_TRIM: egen tot_eq_weights = sum(eq_weights)

*Total household income in $PPP 2011 (2018 Argentina WB)
gen ITF_US = ITF_cpi/14.23
gen eq_inc = ITF_US/tot_eq_weights

*mean equivalised income over waves
egen m_eq_inc_ano1 = mean(eq_inc) if wave==1, by(ID_mob)
egen m_eq_inc_ano2 = mean(eq_inc) if wave==2, by(ID_mob)
egen m_eq_inc_an1 = max(m_eq_inc_ano1), by(ID_mob)
egen m_eq_inc_an2 = max(m_eq_inc_ano2), by(ID_mob)
*mean equivalised income over the period and standard deviation 
bysort ID_mob: egen mean_eq_inc = mean(eq_inc) 
bysort ID_mob: egen sd_eq_inc = sd(eq_inc) 
gen CV_eq_inc = sd_eq_inc/mean_eq_inc
replace CV_eq_inc = 0 if CV_eq_inc==. & nb_dupli!=1

//generation an equivalised income variable of $US PPP per day 
gen eq_inc_pd = eq_inc/30
gen eq_inc_pd_an1 = m_eq_inc_an1/30
gen eq_inc_pd_an2 = m_eq_inc_an2/30


//Variables for the standard deviation of arc percentage change in income in equivalised income
gen IPCF_eq_period_1 = eq_inc if CH03==1 & hh_count==1
gen IPCF_eq_period_2 = eq_inc if CH03==1 & hh_count==2
gen IPCF_eq_period_3 = eq_inc if CH03==1 & hh_count==3
gen IPCF_eq_period_4 = eq_inc if CH03==1 & hh_count==4

egen IPCF_eq_p1 = max(IPCF_eq_period_1), by(ID_mob)
egen IPCF_eq_p2 = max(IPCF_eq_period_2), by(ID_mob)
egen IPCF_eq_p3 = max(IPCF_eq_period_3), by(ID_mob)
egen IPCF_eq_p4 = max(IPCF_eq_period_4), by(ID_mob)



gen arc_percentage_change_eq_1_2 = ((IPCF_eq_p2 - IPCF_eq_p1) / ((IPCF_eq_p1 + IPCF_eq_p2) / 2)) * 100
gen arc_percentage_change_eq_2_3 = ((IPCF_eq_p3 - IPCF_eq_p2) / ((IPCF_eq_p2 + IPCF_eq_p3) / 2)) * 100
gen arc_percentage_change_eq_3_4 = ((IPCF_eq_p4 - IPCF_eq_p3) / ((IPCF_eq_p3 + IPCF_eq_p4) / 2)) * 100

replace arc_percentage_change_eq_1_2 = 0 if IPCF_eq_p1==0 & IPCF_eq_p2==0
replace arc_percentage_change_eq_2_3 = 0 if IPCF_eq_p2==0 & IPCF_eq_p3==0
replace arc_percentage_change_eq_3_4 = 0 if IPCF_eq_p3==0 & IPCF_eq_p4==0

*Mean arc percentage change for each household
egen mean_arc_percentage_change_eq = rowmean(arc_percentage_change_eq_1_2 arc_percentage_change_eq_2_3 arc_percentage_change_eq_3_4) if hog_obs_jefe==1 
egen sd_arcper_change_eq = rowsd(arc_percentage_change_eq_1_2 arc_percentage_change_eq_2_3 arc_percentage_change_eq_3_4) if hog_obs_jefe==1 
label variable sd_arcper_change_eq "Standard deviation of the arc-percentage change in equivalised income"


*SD indicator in equivalised income
egen sd_IPCF_US_eq = rowsd( IPCF_eq_p1 IPCF_eq_p2 IPCF_eq_p3 IPCF_eq_p4)


**************************************************
***** Income stability: source decomposition *****
**************************************************

//CV indicators
bysort ID_mob: egen mean_inc_lab_pc = mean(income_labor_pc) if CH03==1
bysort ID_mob: egen sd_inc_lab_pc = sd(income_labor_pc) if CH03==1
gen CV_inc_lab = sd_inc_lab_pc/mean_inc_lab_pc if CH03==1
label variable CV_inc_lab "CV in labour source income"

bysort ID_mob: egen mean_inc_nolab_pc = mean(income_nolabor_pc) if CH03==1
bysort ID_mob: egen sd_inc_nolab_pc = sd(income_nolabor_pc) if CH03==1
gen CV_inc_nolab = sd_inc_nolab_pc/mean_inc_nolab_pc if CH03==1
label variable CV_inc_nolab "CV in non-labour source income"


//Variables for the standard deviation of arc percentage change in income
gen income_labor_pc_period_1 = income_labor_pc if CH03==1 & hh_count==1
gen income_labor_pc_period_2 = income_labor_pc if CH03==1 & hh_count==2
gen income_labor_pc_period_3 = income_labor_pc if CH03==1 & hh_count==3
gen income_labor_pc_period_4 = income_labor_pc if CH03==1 & hh_count==4

egen income_labor_pc_p1 = max(income_labor_pc_period_1), by(ID_mob)
egen income_labor_pc_p2 = max(income_labor_pc_period_2), by(ID_mob)
egen income_labor_pc_p3 = max(income_labor_pc_period_3), by(ID_mob)
egen income_labor_pc_p4 = max(income_labor_pc_period_4), by(ID_mob)

egen income_labor_pc_an1 = rowmean(income_labor_pc_p1 income_labor_pc_p2) if hog_obs_jefe==1
egen income_labor_pc_an2 = rowmean(income_labor_pc_p3 income_labor_pc_p4) if hog_obs_jefe==1

gen arc_per_change_inc_lab_1_2 = ((income_labor_pc_p2 - income_labor_pc_p1) / ((income_labor_pc_p1 + income_labor_pc_p2) / 2)) * 100
gen arc_per_change_inc_lab_2_3 = ((income_labor_pc_p3 - income_labor_pc_p2) / ((income_labor_pc_p2 + income_labor_pc_p3) / 2)) * 100
gen arc_per_change_inc_lab_3_4 = ((income_labor_pc_p4 - income_labor_pc_p3) / ((income_labor_pc_p3 + income_labor_pc_p4) / 2)) * 100

replace arc_per_change_inc_lab_1_2 = 0 if income_labor_pc_p1==0 & income_labor_pc_p2==0
replace arc_per_change_inc_lab_2_3 = 0 if income_labor_pc_p2==0 & income_labor_pc_p3==0
replace arc_per_change_inc_lab_3_4 = 0 if income_labor_pc_p3==0 & income_labor_pc_p4==0

* Summary statistics: Calculate mean arc percentage change for each household
egen mean_arc_per_change_inc_lab = rowmean(arc_per_change_inc_lab_1_2 arc_per_change_inc_lab_2_3 arc_per_change_inc_lab_3_4) if hog_obs_jefe==1 
egen sd_arcper_change_inc_lab = rowsd(arc_per_change_inc_lab_1_2 arc_per_change_inc_lab_2_3 arc_per_change_inc_lab_3_4) if hog_obs_jefe==1 
replace sd_arcper_change_inc_lab = . if (mean_inc_lab_pc==0)
label variable sd_arcper_change_inc_lab "Standard deviation of the arc-percentage change in labour income"


**Attempt to correct for attrition:
gen long_followup = 1 if nb_dupli>=3
replace long_followup = 0 if nb_dupli<=2

*Probability of staying more than 2 periods in the survey based on covariates
probit long_followup young_head child_min_tot child_min_tot_sq child_maj_tot child_maj_tot_sq large_hh young_child5 single married hh_fem educ_hog_sec educ_hog_sup proprietario ln_IPCF_cpi ln_IPCF_cpi_sq imput i.TRIMESTRE i.REGION if hog_obs_jefe==1 [pw=PONDERA], cluster(AGLOMERADO)

predict p_long_follow , pr
*Compute the inverse probability of staying and reweight the survey weights to keep national representativity
gen ipw= 1/p_long_follow
gen PONDERA_c = PONDERA*ipw


***********************************
***** Vulnerability variables *****
***********************************

gen vuln_6 = 1 if V6==1 & CH03==1
replace vuln_6 = 0 if (V6==2|V6==9|V6==0) & CH03==1
gen vuln_7 = 1 if V7==1 & CH03==1
replace vuln_7 = 0 if (V7==2|V7==9|V7==0) & CH03==1
gen vuln_12 = 1 if V12==1 & CH03==1
replace vuln_12 = 0 if (V12==2|V12==9|V12==0) & CH03==1
gen vuln_13 = 1 if V13==1 & CH03==1
replace vuln_13 = 0 if (V13==2|V13==9|V13==0) & CH03==1
gen vuln_14 = 1 if V14==1 & CH03==1
replace vuln_14 = 0 if (V14==2|V14==9|V14==0) & CH03==1
gen vuln_16 = 1 if V16==1 & CH03==1
replace vuln_16 = 0 if (V16==2|V16==9|V16==0) & CH03==1
gen vuln_15 = 1 if V15==1 & CH03==1
replace vuln_15 = 0 if (V15==2|V15==9|V15==0) & CH03==1
gen vuln_17 = 1 if V17==1 & CH03==1
replace vuln_17 = 0 if (V17==2|V17==9|V17==0) & CH03==1

*goods (food, clothes, etc.) from church, state
egen m_v6 = mean(vuln_6) if vuln_6!=., by(ID_mob)
label variable m_v6 "Received in-kind assistance (church, State, etc.) during the last month"
*goods (food, clothes, etc.) from other people 
egen m_v7 = mean(vuln_7) if vuln_7!=., by(ID_mob)
label variable m_v7 "Received in-kind assistance (family, neighbours) during the last month"
*money from other people
egen m_v12 = mean(vuln_12) if vuln_12!=., by(ID_mob)
label variable m_v12 "Received monetary assistance (family, neighbours) during the last month"
*use savings
egen m_v13 = mean(vuln_13)  if vuln_13!=., by(ID_mob)
label variable m_v13 "Withdrew his savings last month"
*informal loan
egen m_v14 = mean(vuln_14) if vuln_14!=., by(ID_mob)
label variable m_v14 "Relied on informal loan last month"
*loan bank
egen m_v15 = mean(vuln_15) if vuln_15!=., by(ID_mob)
label variable m_v15 "Relied on formal loan last month"
*card
egen m_v16 = mean(vuln_16) if vuln_16!=., by(ID_mob)
label variable m_v16 "Used credit card/deferred payment last month"
*sell goods
egen m_v17 = mean(vuln_17) if vuln_17!=., by(ID_mob)
label variable m_v17 "Sold his assets last month"

*drop vuln_6 vuln_7 vuln_12 vuln_13 vuln_14 vuln_16 vuln_15 vuln_17

/*******************************************************************************
********************************************************************************
STEP 2: Identification of the control and treatment groups
********************************************************************************
*******************************************************************************/

//individual occupation 
gen status_ocup = 0 if ESTADO==4  //minor
replace status_ocup = 1 if ESTADO==2  //unemployed
replace status_ocup = 2 if ESTADO==1 & CAT_OCUP==3 & PP07H==1 //formal worker
replace status_ocup = 3 if (ESTADO==1 & CAT_OCUP==3 & PP07H==2) | (ESTADO==1 & CAT_OCUP==3 & PP07H==0) | (ESTADO==1 & CAT_OCUP==3 & domestic_wk==1) //informal worker (informal employee, domestic worker)
replace status_ocup = 4 if ESTADO==1 & CAT_OCUP==4  //family worker (unpaid)
replace status_ocup = 5 if (ESTADO==1 & CAT_OCUP==1)  //employer
replace status_ocup = 6 if (ESTADO==3&CAT_INAC!=1) //inactive (without retired)
replace status_ocup = 7 if (ESTADO==3&CAT_INAC==1) & CH08==4 //retired informal
replace status_ocup = 8 if (ESTADO==3&CAT_INAC==1) & CH08!=4 //retired formal
replace status_ocup = 9 if (ESTADO==1 & CAT_OCUP==2) //self-employed
replace status_ocup=0 if status_ocup==. & H15!=2
replace status_ocup=0 if status_ocup==. & H15==2
gen status_ocup_ano1 = status_ocup if wave==1  
gen status_ocup_ano2 = status_ocup if wave==2 
egen status_ocup_an1=max(status_ocup_ano1) , by(ID_ind) 
egen status_ocup_an2=max(status_ocup_ano2) , by(ID_ind) 

//if the head of household/spouse are working in the informal sector (1 = informal ; 0 = formal)
gen head_inform = 1 if ((status_ocup==3|status_ocup==4|status_ocup==1|status_ocup==6|status_ocup==7|status_ocup==9|status_ocup==0)) & (CH03==1|CH03==2)
replace head_inform=0 if ((status_ocup==2 | status_ocup==5 | status_ocup==8)) & (CH03==1|CH03==2)
gen head_inform_ano1 = head_inform if wave==1 & (CH03==1|CH03==2)
gen head_inform_ano2 = head_inform if wave==2 & (CH03==1|CH03==2)
egen head_inform_an1=max(head_inform_ano1) if (CH03==1|CH03==2), by(ID_ind) 
egen head_inform_an2=max(head_inform_ano2) if (CH03==1|CH03==2), by(ID_ind) 

//Eligible household if the head of household/spouse are working in the informal sector = 1 if informal ; 0 = formal
bysort HOGID_men ANO_TRIM : egen hog_inform = min(head_inform)
gen hog_inform_ano1 = hog_inform if wave==1
gen hog_inform_ano2 = hog_inform if wave==2
egen hog_inform_an1=max(hog_inform_ano1), by(ID)
egen hog_inform_an2=max(hog_inform_ano2), by(ID)


//Specific case: if the grandparents in the household is the head of household 
*Diffenciate the parents and the grandparents:
* if the head is the father/mother of the minor child, consider the formal/informal status of the parents only 
* if the head is the grandmother/grandfather of the minor child, takes into account the occupation the parents only and not the grandparents

*gd_parents are head of hh, considered as informal, and the parents are informal : eligible
gen parent_inform = 1   if hog_gd_parent==1 & hog_inform==1 & (status_ocup==3|status_ocup==4|status_ocup==1|status_ocup==6|status_ocup==7|status_ocup==9|status_ocup==0) & (CH03==3|CH03==4) 
*gd_parents are head of hh, considered as "formal", but the parents are informal : eligible
replace parent_inform=1 if hog_gd_parent==1 & hog_inform==0 & (status_ocup==3|status_ocup==4|status_ocup==1|status_ocup==6|status_ocup==7|status_ocup==9|status_ocup==0) & (CH03==3|CH03==4) 
*gd parents are head of hh, considered as "informal", but the parents formal: not eligible
replace parent_inform=0 if hog_gd_parent==1 & hog_inform==1 & (status_ocup==2 | status_ocup==5 | status_ocup==8) & (CH03==3|CH03==4) 
*gd parents are head of hh, considered as "formal", and the parents formal : not eligibile
replace parent_inform=0 if hog_gd_parent==1 & hog_inform==0 & (status_ocup==2 | status_ocup==5 | status_ocup==8) & (CH03==3|CH03==4)
*no gd parents in the household, parents "informal" : eligible
replace parent_inform=1 if hog_gd_parent==0 & hog_inform==1 & (status_ocup==3|status_ocup==4|status_ocup==1|status_ocup==6|status_ocup==7|status_ocup==9|status_ocup==0) & (CH03==1|CH03==2)
*gd parents in the household but not head of household, parents "informal": eligible
replace parent_inform=1 if hog_gd_parent==1 & hog_inform==1 & (status_ocup==3|status_ocup==4|status_ocup==1|status_ocup==6|status_ocup==7|status_ocup==9|status_ocup==0) & (CH03==1|CH03==2)
*gd parents are not in the household, parents are "formal": not eligible
replace parent_inform=0 if hog_gd_parent==0 & hog_inform==0 & (status_ocup==2 | status_ocup==5 | status_ocup==8) & (CH03==1|CH03==2)
*gd parents are in the household but not head of household, parents "formal": not eligible
replace parent_inform=0 if hog_gd_parent==1 & hog_inform==0 & (status_ocup==2 | status_ocup==5 | status_ocup==8 ) & (CH03==1|CH03==2)

gen parent_inform_ano1 = parent_inform if wave==1 & (CH03==1|CH03==2|CH03==3|CH03==4)
gen parent_inform_ano2 = parent_inform if wave==2 & (CH03==1|CH03==2|CH03==3|CH03==4)
egen parent_inform_an1=max(parent_inform_ano1) if (CH03==1|CH03==2|CH03==3|CH03==4), by(ID_ind) 
egen parent_inform_an2=max(parent_inform_ano2) if (CH03==1|CH03==2|CH03==3|CH03==4), by(ID_ind) 

**if the head is the grandparents: only consider the status of the parents
bysort HOGID_men ANO_TRIM : egen hog_inform_par_hij = min(parent_inform) if (CH03==3|CH03==4)
gen hog_inform_par_hij_ano1 = hog_inform_par_hij if wave==1
gen hog_inform_par_hij_ano2 = hog_inform_par_hij if wave==2
egen hog_inform_par_hij_an1=max(hog_inform_par_hij_ano1), by(ID)
egen hog_inform_par_hij_an2=max(hog_inform_par_hij_ano2), by(ID)
**if the head is the parents, consider status of the parents
bysort HOGID_men ANO_TRIM : egen hog_inform_par_par = min(parent_inform) if (CH03==1|CH03==2)
gen hog_inform_par_par_ano1 = hog_inform_par_par if wave==1
gen hog_inform_par_par_ano2 = hog_inform_par_par if wave==2
egen hog_inform_par_par_an1=max(hog_inform_par_par_ano1), by(ID)
egen hog_inform_par_par_an2=max(hog_inform_par_par_ano2), by(ID)

*Eligible household:
**only for the first period
gen hog_inform_par_all_an1 = hog_inform_par_hij_an1 if hog_inform_par_hij_an1!=hog_inform_par_par_an1
replace hog_inform_par_all_an1 = hog_inform_par_par_an1 if hog_inform_par_hij_an1==.
replace hog_inform_par_all_an1 = hog_inform_par_hij_an1 if hog_inform_par_hij_an1==hog_inform_par_par_an1
gen hog_inform_par_all_an2 = hog_inform_par_hij_an2 if hog_inform_par_hij_an2!=hog_inform_par_par_an2
replace hog_inform_par_all_an2 = hog_inform_par_par_an2 if hog_inform_par_hij_an2==.
replace hog_inform_par_all_an2 = hog_inform_par_hij_an2 if hog_inform_par_hij_an2==hog_inform_par_par_an2
**for the whole period
bysort ID_mob : egen hog_inform_par_all_full_an1 = min(hog_inform_par_all_an1) 
bysort ID_mob : egen hog_inform_par_all_full_an2 = min(hog_inform_par_all_an2)

label variable hog_inform_par_all_full_an1 "1 if eligible parents during the first year of the survey"
label variable hog_inform_par_all_full_an2 "1 if eligible parents during the second year of the survey"

*interaction between eligible household and jjhd program
*gen jjhd_hog_inform = jjhd_hog*hog_inform_par_all_full_an1
*interaction jjhd_hog and time dummies
*gen jjhd_hog_t2 = jjhd_hog*t_2
*gen jjhd_hog_t3 = jjhd_hog*t_3
*gen jjhd_hog_t4 = jjhd_hog*t_4
*gen jjhd_hog_t5 = jjhd_hog*t_5
*gen jjhd_hog_t6 = jjhd_hog*t_6


**Labour variables

*Number of workers and working hours
gen active_mem = 1 if status_ocup==1|status_ocup==2|status_ocup==3|status_ocup==4|status_ocup==5|status_ocup==9
replace active_mem = 0 if active_mem==. 

gen PP3E_TOT_clean = PP3E_TOT
replace PP3E_TOT_clean = . if active_mem==1 & (PP3E_TOT_clean==999|PP3E_TOT_clean>126)
gen PP3F_TOT_clean = PP3F_TOT
replace PP3F_TOT_clean = . if active_mem==1 & (PP3F_TOT_clean==999|PP3F_TOT_clean>126)
replace PP3E_TOT_clean = 0 if PP3E_TOT_clean==.
replace PP3F_TOT_clean = 0 if PP3F_TOT_clean==.

gen tot_wk_h = PP3E_TOT_clean + PP3F_TOT_clean

bysort HOGID_men ANO_TRIM: egen tot_worker = total(active_mem) 
bysort HOGID_men ANO_TRIM: egen tot_worker_par = total(active_mem) if (CH03==1|CH03==2) 
bysort HOGID_men ANO_TRIM: egen men_tot_wk_h = total(tot_wk_h) 
bysort HOGID_men ANO_TRIM: egen men_tot_wk_h_head = total(tot_wk_h) if CH03==1
bysort HOGID_men ANO_TRIM: egen men_tot_wk_h_conj = total(tot_wk_h) if CH03==2
bysort HOGID_men ANO_TRIM: egen men_tot_wk_h_par = total(tot_wk_h) if (CH03==1|CH03==2) 

bysort ID_mob: egen mean_tot_worker = mean(tot_worker) 
bysort ID_mob: egen mean_tot_worker_par = mean(tot_worker_par) 
label variable mean_tot_worker "Average number of workers in the hh over the period"

gen mean_tot_wk_h = men_tot_wk_h/tot_worker
replace mean_tot_wk_h = 0 if mean_tot_wk_h==.
gen mean_tot_wk_h_par = men_tot_wk_h_par/tot_worker_par
replace mean_tot_wk_h_par = 0 if mean_tot_wk_h_par==.

bysort ID_mob: egen mean_period_tot_wk_h = mean(mean_tot_wk_h) if CH03==1
label variable mean_tot_wk_h "Average number of hours worked in the hh over the period"

bysort ID_mob: egen mean_period_tot_wk_h_par = mean(mean_tot_wk_h_par) if CH03==1
label variable mean_tot_wk_h_par "Average number of hours worked by parents over the period"

bysort ID_mob: egen mean_period_tot_wk_h_head = mean(men_tot_wk_h_head) if CH03==1
label variable mean_tot_wk_h_par "Average number of hours worked by the head of hh over the period"

bysort ID_mob: egen mean_period_tot_wk_h_conj = mean(men_tot_wk_h_conj) 
label variable mean_tot_wk_h_par "Average number of hours worked by the spouse over the period"


/*******************************************************************************
********************************************************************************
STEP 3: Pre-post AUH dummy and placebo
********************************************************************************
*******************************************************************************/

*post AUH variable (after 2008-2009)
gen after = 0
replace after = 1 if ano_panel >=7

//placebo AUH intervention 
gen after_placebo06 = 0 //intervention in 2006-2007
replace after_placebo06 = 1 if ano_panel>=4
gen after_placebo07 = 0 //intervention in 2007-2008
replace after_placebo07 = 1 if ano_panel>=5
gen after_placebo08 = 0 //intervention in 2008-2009
replace after_placebo08 = 1 if ano_panel>=6


//Time variables for csdid package (Doubly Robust Estimator)
gen timeToTreat_pos = 6 if ano_panel==8
replace timeToTreat_pos = 5 if ano_panel==6
replace timeToTreat_pos = 4 if ano_panel==5
replace timeToTreat_pos = 3 if ano_panel==4
replace timeToTreat_pos = 2 if ano_panel==3
replace timeToTreat_pos = 1 if ano_panel==2
replace timeToTreat_pos = 7 if ano_panel==9
replace timeToTreat_pos = 8 if ano_panel==10
replace timeToTreat_pos = 9 if ano_panel==11
replace timeToTreat_pos = 10 if ano_panel==12

gen gvarname = 6 if hog_inform_par_all_full_an1==1
replace gvarname = 0 if hog_inform_par_all_full_an1==0


**Dummies for figures
gen ano_panel_temp = 1 if ano_panel==2
replace ano_panel_temp = 2 if ano_panel==3
replace ano_panel_temp = 3 if ano_panel==4
replace ano_panel_temp = 4 if ano_panel==5
replace ano_panel_temp = 5 if ano_panel==6
replace ano_panel_temp = 6 if ano_panel==8
replace ano_panel_temp = 7 if ano_panel==9
replace ano_panel_temp = 8 if ano_panel==10
replace ano_panel_temp = 9 if ano_panel==11
replace ano_panel_temp = 10 if ano_panel==12

**Time dummies for event study
gen zero = 0
gen lead_treat_m1 = t_6*hog_inform_par_all_full_an1
gen lead_treat_m2 = t_5*hog_inform_par_all_full_an1
gen lead_treat_m3 = t_4*hog_inform_par_all_full_an1
gen lead_treat_m4 = t_3*hog_inform_par_all_full_an1
gen lead_treat_m5 = t_2*hog_inform_par_all_full_an1
gen lag_treat_p1 = t_8*hog_inform_par_all_full_an1
gen lag_treat_p2 = t_9*hog_inform_par_all_full_an1
gen lag_treat_p3 = t_10*hog_inform_par_all_full_an1
gen lag_treat_p4 = t_11*hog_inform_par_all_full_an1
gen lag_treat_p5 = t_12*hog_inform_par_all_full_an1


********************************************************************************
*Cleaning variables

drop educ_prii educ_pric educ_seci educ_secc educ_supi educ_supc ed_jefe ed_conj ed_parent educ_hog IPCF_period_1 IPCF_period_2 IPCF_period_3 IPCF_period_4 IPCF_p1 IPCF_p2 IPCF_p3 IPCF_p4 arc_percentage_change_1_2 arc_percentage_change_2_3 arc_percentage_change_3_4 income_labor income_nolabor income income_labor_tot income_nolabor_tot income_tot income_labor_pc income_nolabor_pc income_pc income_labor_prop income_nolab_prop V12_M_prop V5_M_prop income_labor_pen income_labor_pen_pc income_nolabor_pen income_nolabor_pen_pc  income_labor_pen_prop income_nolab_pen_prop mean_income_tot_full mean_V5_M_full mean_V12_M_full mean_income_lab_full mean_income_nolab_full mean_income_lab_pen_full mean_income_nolab_pen_full mean_income_lab_pc_full mean_income_nolab_pc_full IPCF_eq_period_1 IPCF_eq_period_2 IPCF_eq_period_3 IPCF_eq_period_4 IPCF_eq_p1 IPCF_eq_p2 IPCF_eq_p3 IPCF_eq_p4 arc_percentage_change_eq_1_2 arc_percentage_change_eq_2_3 arc_percentage_change_eq_3_4 status_ocup_ano1 status_ocup_ano2 head_inform_ano1 head_inform_ano2 parent_inform_ano1 parent_inform_ano2 hog_inform_par_hij_ano1 hog_inform_par_hij_ano2 hog_inform_par_par_ano1 hog_inform_par_par_ano2


********************************************************************************
********************************************************************************

*Only keep the household level for the analysis
keep if hog_obs_jefe==1

save "$AUH_argentina\data\AUH_base_reduced.dta",replace
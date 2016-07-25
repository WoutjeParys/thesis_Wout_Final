$TITLE GOA version 2.0 (December 2013) puuh
$eolcom #
# GAMS options are $included from the file GAMS.opt
# GOA options are $included from the file GOA.opt
# In order to make them apply globally, the option $ONGLOBAL will first be seet here:
$ONGLOBAL

$include '../gams/GAMS.opt';
$include '../gams/GOA.opt';


#===============================================================================
# INPUT
#===============================================================================


#-------------------------------------------------------------------------------
#* Sets
#-------------------------------------------------------------------------------

# Declaration

SETS
RCZ                 All geographical entities (R_ALL + C_ALL + Z_ALL)
R_ALL(RCZ)          All regions (i.e. W-EU & E-EU & North and Baltic Sea)
C_ALL(RCZ)          All countries
Z_ALL(RCZ)          All zones within a country
R_C(R_ALL,C_ALL)    Countries in regions
C_Z(C_ALL,Z_ALL)    Zones in countries
#R(R_ALL)           Regions in the simulation
C(C_ALL)            Countries in the simulation
Z(Z_ALL)            Zones in the simulation

Y_ALL               All years
Y(Y_ALL)            Years in the simulation
P                   Time periods
T                   Time steps within periods

G                   All generation technologies
GD(G)               Dispatchable generation technologies
GC(G)               Conventional generation technologies
GCG(GC)             Gas-fueled conventional generation technologies
GCO(GC)             Other conventional generation technologies
GR(G)               Renewable generation technologies
GRI(GR)             Intermittent renewable generation technologies
GRD(GR)             Dispatchable renewable generation technologies
G_PARAM             Generation technology parameterz
CIG_PARAM

S                   All storage technologies
SSM(S)              Short and Mid-term storage technologies
SML(S)              Mid and Long-term storage technologies
SS(S)               Short-term storage technologies
SM(S)               Mid-term storage technologies
SL(S)               Long-term storage technologies
S_PARAM             Storage technology parameterz
CIS_PARAM

D                   All demand technologies
D_PARAM             Demand response technology parameterz

POL                 Policy instruments

A                   Allocation horizon
APT(A,P,T)          Linking of allocation horizon to period and time
R                   Reserve requirements
RA(R)               Upward reserve requirements
RU(R)               Upward reserve requirements
RD(R)               Downward reserve requirements
RUF(RU)             FCR upward reserve requirements
RUA(RU)             FCR and aFRR upward reserve requirements
RDF(RD)             FCR upward reserve requirements
RDA(RD)             aFRR downward reserve requirements
;

#$GDXIN "_gams_py_gdb0.gdx" #%SupplyDataFileName%
$GDXIN %SupplyDataFileName%

$LOAD RCZ R_ALL C_ALL Z_ALL R_C C_Z C Z
$LOAD Y_ALL Y
$LOAD P T
$LOAD G GD GC GCG GCO GR GRI GRD G_PARAM
$LOAD S SSM SML SS SM SL S_PARAM
$LOAD D D_PARAM
$LOAD POL
$LOAD A APT
$LOAD R RU RD RUF RUA RDF RDA RA
$LOAD CIG_PARAM CIS_PARAM

alias(T,T_MUT,T_MDT,T_E,T_D,TT);
alias(PP,P);
SSM(S) = SS(S) + SM(S);

SETS
G_MUT(G,T_MUT)  Minimum up time per technology
G_MDT(G,T_MDT)  Minimum down time per technology

S_MUT(S,T_MUT)  Minimum up time per technology
S_MDT(S,T_MDT)  Minimum down time per technology

D_MUT(D,T_MUT)  Minimum up time per technology
D_MDT(D,T_MDT)  Minimum down time per technology
D_DT_MAX(D,T_D) Maximum duration per activation
;

$LOAD G_MUT, G_MDT
$LOAD S_MUT, S_MDT
$LOAD D_MUT, D_MDT, D_DT_MAX

PARAMETERS
G_DATA(G,G_PARAM)       Technologies characteristics
S_DATA(S,S_PARAM)       Technologies characteristics
D_DATA(D,D_PARAM)       Technologies characteristics

CAP_INST_G(Y_ALL,Z_ALL,G,CIG_PARAM)  Installed generation capacities
CAP_INST_S(Y_ALL,Z_ALL,S,CIS_PARAM)  Installed generation capacities

RG(R,GD)                Ramping ability per reserve category for generation technologies
RSC(R,SML)              Ramping ability per reserve category for storage technologies while charging
RSD(R,SM)               Ramping ability per reserve category for storage technologies while discharging
RDR(R,D)                Ramping ability per reserve category for demand response technologies

C_GAS                   Cost of imported gas

DEM(Y_ALL,Z_ALL)        Energy demand per year [MWh]
DEM_T(P,T,Z_ALL)        Relative electricity demand per hour [percentage]

RES_T(P,T,Z_ALL,GRI)    Intermittent generation profilez [MW]
REL_T(P,T,Z_ALL,GRI)    Reliable intermittent generation profilez [MW]

W(P)                    Weight of period P

POL_TARGETS(POL,Y_ALL)  Policy targets such as the desired share of renewables in production [%]

#CAP_G(Y,Z,G,C_PARAM)   Installed capacities per zone per year [MW]

RC_A_EXO(A,C_ALL,R)        Exogenous reserve capacity requirements per country
RC_A_ENDO(A,C_ALL,GRI,R)   Endogenous reserve capacity requirements per country per (renewable) generation technology
RC_O_EXO(P,T,C_ALL,R)        Exogenous reserve capacity requirements per country
RC_O_ENDO(P,T,C_ALL,GRI,R)   Endogenous reserve capacity requirements per country per (renewable) generation technology
RP_EXO(P,T,C_ALL,R)        Exogenous reserve probability of activation per country
RP_ENDO(P,T,C_ALL,GRI,R)   Endogenous reserve probability of activation per country per (renewable) generation technology

T_MARKET                Time step of the market
T_R(R)                  Time factor to calculate energy for reserve provision

EGCAPEX                 Annualized energy investment cost of gas storage
E_LP                    Energy volume of the gas line pack

TIMESTEP                Time step of the market
;

$LOAD G_DATA
$LOAD S_DATA
$LOAD D_DATA
$LOAD CAP_INST_G CAP_INST_S
$LOAD RG
$LOAD RSC
$LOAD RSD
$LOAD RDR
$LOAD DEM DEM_T
$LOAD RES_T
$LOAD REL_T
$LOAD W
$LOAD POL_TARGETS
#$LOAD CAP_G
$LOAD RC_A_EXO
$LOAD RC_A_ENDO
$LOAD RC_O_EXO
$LOAD RC_O_ENDO
$LOAD RP_EXO
$LOAD RP_ENDO
$LOAD T_R

#C_GAS = 25.6643460843943;
C_GAS = 25.6643460843943;
TIMESTEP = 4;
T_MARKET = TIMESTEP/4;
EGCAPEX = 2000000000000000000000000;
E_LP = 7520000 + 100000;

VARIABLES
obj                         Value of objective function
;

POSITIVE VARIABLES
cap(Y,Z,G)                  Generation capacity per year, per zone and per generation technology [MW]
dr_cap(Y,Z,D)               Demand capacity per year, per zone and per generation technology [MW]
e_cap(Y,Z,S)                Energy capacity of storage technology S
p_cap_c(Y,Z,S)              Charging power capacity of storage technology S
p_cap_d(Y,Z,SM)             Discharging power capacity of storage technology SM
eg_cap                      Gas storage capacity

gen(Y,P,T,Z,G)              Electricity generation per time step, per zone and per generation technology [MWh]
curt(Y,P,T,Z,GRI)           Curtailment of renewable output

load_shedding(Y,P,T,Z)      Load shedding
load_shedding_r(Y,P,T,Z,R) Load shedding

cons(Y,P,T,Z,D)             Electricity consumption of the demand response technologies [MW]
cons_dn_act(Y,P,T,Z,D)      Downward activation of consumption [MW]

e(Y,P,Z,S)                  Energy content of storage technology S at period P
e_f(Y,P,T,Z,S)              Energy content of storage technology S at time T during the first cycle of period P
e_l(Y,P,T,Z,S)              Energy content of storage technology S at time T during the last cycle of period P
p_c(Y,P,T,Z,S)              Electricity generation per time step, per zone and per generation technology [MWh]
p_d(Y,P,T,Z,S)              Electricity generation per time step, per zone and per generation technology [MWh]

eg(Y,P,C)                   Energy content of gas storage at period P
eg_f(Y,P,T,C)               Energy content of gas storage at time T during the first cycle of period P
eg_l(Y,P,T,C)               Energy content of gas storage at time T during the last cycle of period P
pg_c(Y,P,T,C)               Charging of gas storage
pg_d(Y,P,T,C)               Discharging of gas storage

res_a_g(Y,A,Z,R,G)            Reserve allocation of generation technology GD for reserve category R
res_a_s(Y,A,Z,R,S)            Reserve allocation of storage technology S for reserve category R
res_a_t_g(Y,A,P,T,Z,R,G)            Reserve allocation of generation technology GD for reserve category R
res_a_t_s(Y,A,P,T,Z,R,S)            Reserve allocation of storage technology S for reserve category R
res_o_g(Y,P,T,Z,R,G)            Reserve allocation of generation technology GD for reserve category R
res_o_s(Y,P,T,Z,R,S)            Reserve allocation of storage technology S for reserve category R
res_g(Y,P,T,Z,R,G)            Reserve allocation of generation technology GD for reserve category R
res_s(Y,P,T,Z,R,S)            Reserve allocation of storage technology S for reserve category R
res_dr(Y,P,Z,R,D)           Reserve allocation of demand response technology D for reserve category R

act_g(Y,P,T,Z,R,G)          Reserve allocation of generation technology GD for reserve category R
act_s(Y,P,T,Z,R,S)          Reserve allocation of storage technology S for reserve category R

q_endo(Y,P,C,R,GRI)         Endogenous reserve requirements for category R
co2(Y,C,G)                  CO2-emissions per year, per zone and per generation technology [kg]
lcg(Y,C,G)                  Life cycle greenhouse gas emissions per year, per zone and per generation technology [kg]

res_g_s(Y,P,T,Z,R,GD)       Spinning reserve allocation of generation technology GD for reserve category R
res_g_ns(Y,P,T,Z,RU,GD)     Start-up reserve allocation of generation technology GD for reserve category RU
res_g_sd(Y,P,T,Z,RD,GD)     Shut-down reserve allocation of generation technology GD for reserve category RD

n(Y,P,T,Z,GD)               Number of units of each generation technology per year, time step and zone [-]
n_su(Y,P,T,Z,GD)            Number of units starting up of each generation technology
n_sd(Y,P,T,Z,GD)            Number of units shutting down of each generation technology
n_su_r(Y,P,T,Z,RU,GD)       Number of units starting up of each generation technology
n_sd_r(Y,P,T,Z,RD,GD)       Number of units shutting down of each generation technology

ramp_up(Y,P,T,Z,GD)         Increase in output by ramping up
ramp_dn(Y,P,T,Z,GD)         Decrease in output by ramping down
ramp_su(Y,P,T,Z,GD)         Increase in output by starting up additional units
ramp_sd(Y,P,T,Z,GD)         Decrease in output by shutting down units

curt_dummy(Y,P,T,Z,GRI)     Dummy variable in case RES objective cannot be reached

res_dr_s(Y,P,T,Z,R,D)       Spinning reserve allocation of generation technology GD for reserve category R
res_dr_ns(Y,P,T,Z,RD,D)     Start-up reserve allocation of generation technology GD for reserve category RU
res_dr_sd(Y,P,T,Z,RU,D)     Shut-down reserve allocation of generation technology GD for reserve category RD

n_dr(Y,P,T,Z,D)             Number of units of each generation technology per year, time step and zone [-]
n_dr_su(Y,P,T,Z,D)          Number of units starting up of each generation technology
n_dr_sd(Y,P,T,Z,D)          Number of units shutting down of each generation technology
n_dr_su_r(Y,P,T,Z,RD,D)     Number of units starting up of each generation technology
n_dr_sd_r(Y,P,T,Z,RU,D)     Number of units shutting down of each generation technology

ramp_dr_up(Y,P,T,Z,D)       Increase in output by ramping up
ramp_dr_dn(Y,P,T,Z,D)       Decrease in output by ramping down
ramp_dr_su(Y,P,T,Z,D)       Increase in output by starting up additional units
ramp_dr_sd(Y,P,T,Z,D)       Decrease in output by shutting down units

cyc_cost(Y,C,SS)            cycling cost of short-term storage

res_s_c(Y,P,T,Z,R,S)        Reserve allocation of charging storage technology S for reserve category R
res_s_c_s(Y,P,T,Z,R,SML)    Spinning reserve allocation of charging storage technology SML for reserve category R
res_s_c_ns(Y,P,T,Z,RD,SML)  Start-up reserve allocation of charging storage technology SML for reserve category RD
res_s_c_sd(Y,P,T,Z,RU,SML)  Shut-down reserve allocation of charging storage technology SML for reserve category RU
res_s_d(Y,P,T,Z,R,S)        Reserve allocation of discharging storage technology S for reserve category R
res_s_d_s(Y,P,T,Z,R,SM)     Spinning reserve allocation of discharging storage technology SM for reserve category R
res_s_d_ns(Y,P,T,Z,RU,SM)   Start-up reserve allocation of discharging storage technology SM for reserve category RU
res_s_d_sd(Y,P,T,Z,RD,SM)   Shut-down reserve allocation of discharging storage technology SM for reserve category RD

act_s_c(Y,P,T,Z,R,S)        Reserve allocation of charging storage technology S for reserve category R
act_s_d(Y,P,T,Z,R,S)        Reserve allocation of discharging storage technology S for reserve category R

n_c(Y,P,T,Z,SML)            Number of units of each generation technology per year, time step and zone [-]
n_c_su(Y,P,T,Z,SML)         Number of units starting up of each generation technology
n_c_sd(Y,P,T,Z,SML)         Number of units shutting down of each generation technology
n_c_su_r(Y,P,T,Z,RD,SML)    Number of units starting up of each generation technology
n_c_sd_r(Y,P,T,Z,RU,SML)    Number of units shutting down of each generation technology

ramp_c_up(Y,P,T,Z,S)        Increase in output by ramping up
ramp_c_dn(Y,P,T,Z,S)        Decrease in output by ramping down
ramp_c_su(Y,P,T,Z,SML)      Increase in output by starting up additional units
ramp_c_sd(Y,P,T,Z,SML)      Decrease in output by shutting down units

n_d(Y,P,T,Z,SM)             Number of units of each generation technology per year, time step and zone [-]
n_d_su(Y,P,T,Z,SM)          Number of units starting up of each generation technology
n_d_sd(Y,P,T,Z,SM)          Number of units shutting down of each generation technology
n_d_su_r(Y,P,T,Z,RU,SM)     Number of units starting up of each generation technology
n_d_sd_r(Y,P,T,Z,RD,SM)     Number of units shutting down of each generation technology

ramp_d_up(Y,P,T,Z,S)        Increase in output by ramping up
ramp_d_dn(Y,P,T,Z,S)        Decrease in output by ramping down
ramp_d_su(Y,P,T,Z,SM)       Increase in output by starting up additional units
ramp_d_sd(Y,P,T,Z,SM)       Decrease in output by shutting down units

pg_import(Y,P,T,C)          Import of gas
pg_syn(Y,P,T,Z,GCG)         Use of synthetic gas in gas-fueled conventional generation technologies GCG
pg_fos(Y,P,T,Z,GCG)         Use of natural gas in gas-fueled conventional generation technologies GCG
;

EQUATIONS
#--Objective function--#
qobj

#--System constraints--#
qbalance(Y,P,T,Z)
qresprod(Y,C)
qco2lim(Y,C)
qresa(Y,A,C,R)
qreso(Y,P,T,C,R)
qallg(Y,A,P,T,Z,R,G)
qalls(Y,A,P,T,Z,R,S)
qallgnot(Y,A,P,T,Z,R,G)
qallsnot(Y,A,P,T,Z,R,S)
qresallg(Y,P,T,Z,R,G)
qresalls(Y,P,T,Z,R,S)
qgendisp(Y,P,T,C)
qgendisppeak(Y,C)
qco2(Y,C,G)
qlcg(Y,C,G)

#--Generation technologies--#
qgcapmin(Y,C,G)
qgcapmax(Y,C,G)
qgcapminres(Y,Z,G)
qgcapmaxres(Y,Z,G)
#qggenmin(Y,C,G)
qggenmax(Y,C,G)

qresgcu(Y,P,T,Z,RU,GD)
qresgcd(Y,P,T,Z,RD,GD)
qn(Y,P,T,Z,GD)
qnmax(Y,P,T,Z,GD)
qnsu(Y,P,T,Z,GD)
qnsd(Y,P,T,Z,GD)
qgen(Y,P,T,Z,GD)
qgenmin(Y,P,T,Z,GD)
qgenmax(Y,P,T,Z,GD)
qrudyn(Y,P,T,Z,GD)
qrucap(Y,P,T,Z,GD)
qrddyn(Y,P,T,Z,GD)
qrdcap(Y,P,T,Z,GD)
qsumin(Y,P,T,Z,GD)
qsumax(Y,P,T,Z,GD)
qsdmin(Y,P,T,Z,GD)
qsdmax(Y,P,T,Z,GD)
qrufu(Y,P,T,Z,GD)
qruau(Y,P,T,Z,GD)
qrumu(Y,P,T,Z,GD)
qrdfd(Y,P,T,Z,GD)
qrdad(Y,P,T,Z,GD)
qrdmd(Y,P,T,Z,GD)
qrunsmin(Y,P,T,Z,RU,GD)
qrunsmax(Y,P,T,Z,RU,GD)
qrdsdmin(Y,P,T,Z,RD,GD)
qrdsdmax(Y,P,T,Z,RD,GD)

qresgru(Y,P,T,Z,RU,GRI)
qgenr(Y,P,T,Z,GRI)
qresgrdr(Y,P,T,Z,GRI)
qresgrdg(Y,P,T,Z,GRI)

#--Demand technologies--#
qdrcapmin(Y,C,D)
qdrcapmax(Y,C,D)
qdrconsdnact(Y,P,T,Z,D)
qdrconsmin(Y,C,D)
qdrfmax(Y,C,D)
qdrdpmax(Y,P,T,Z,D)
qdrdtmax(Y,P,T,Z,D)

qresdrcu(Y,P,T,Z,RD,D)
qresdrcd(Y,P,T,Z,RU,D)
qndr(Y,P,T,Z,D)
qndrmax(Y,P,T,Z,D)
qndrsu(Y,P,T,Z,D)
qndrsd(Y,P,T,Z,D)
qcons(Y,P,T,Z,D)
qconsmin(Y,P,T,Z,D)
qconsmax(Y,P,T,Z,D)
qdrrudyn(Y,P,T,Z,D)
qdrrucap(Y,P,T,Z,D)
qdrrddyn(Y,P,T,Z,D)
qdrrdcap(Y,P,T,Z,D)
qdrsumin(Y,P,T,Z,D)
qdrsumax(Y,P,T,Z,D)
qdrsdmin(Y,P,T,Z,D)
qdrsdmax(Y,P,T,Z,D)
qdrruad(Y,P,T,Z,D)
qdrrumds(Y,P,T,Z,D)
qdrrdfu(Y,P,T,Z,D)
qdrrdau(Y,P,T,Z,D)
qdrrdmu(Y,P,T,Z,D)
qdrrunsmin(Y,P,T,Z,RD,D)
qdrrunsmax(Y,P,T,Z,RD,D)
qdrrdsdmin(Y,P,T,Z,RU,D)
qdrrdsdmax(Y,P,T,Z,RU,D)

#--Storage technologies--#
qress(Y,P,T,Z,R,S)
qspotecapmin(Y,C,S)
qspotecapmax(Y,C,S)
qspotpccapmin(Y,C,S)
qspotpccapmax(Y,C,S)
qspotecapminres(Y,Z,S)
qspotecapmaxres(Y,Z,S)
qspotpcapminres(Y,Z,S)
qspotpcapmaxres(Y,Z,S)

qe(Y,P,Z,S)
qemax(Y,P,Z,S)
qef(Y,P,T,Z,S)
qefmin(Y,P,T,Z,S)
qefmax(Y,P,T,Z,S)
qefstart(Y,P,T,Z,S)
qel(Y,P,T,Z,S)
qelmin(Y,P,T,Z,S)
qelmax(Y,P,T,Z,S)
qelstart(Y,P,T,Z,S)
qdurmin(Y,Z,S)
qdurmax(Y,Z,S)

qsscemin(Y,C,SS)
qssccmin(Y,C,SS)
qsscdmax(Y,P,T,Z,SS)
qssc(Y,P,T,Z,SS)
qsscru(Y,P,T,Z,SS)
qsscrd(Y,P,T,Z,SS)
qssd(Y,P,T,Z,SS)
qssdru(Y,P,T,Z,SS)
qssdrd(Y,P,T,Z,SS)

qresscu(Y,P,T,Z,RU,SML)
qresscd(Y,P,T,Z,RD,SML)
qressdu(Y,P,T,Z,RU,SM)
qressdd(Y,P,T,Z,RD,SM)
qnc(Y,P,T,Z,SML)
qncmax(Y,P,T,Z,SML)
qncsu(Y,P,T,Z,SML)
qncsd(Y,P,T,Z,SML)
qsmlc(Y,P,T,Z,SML)
qsmlcmin(Y,P,T,Z,SML)
qsmlcmax(Y,P,T,Z,SML)
qcrudyn(Y,P,T,Z,SML)
qcrucap(Y,P,T,Z,SML)
qcrddyn(Y,P,T,Z,SML)
qcrdcap(Y,P,T,Z,SML)
qcsumin(Y,P,T,Z,SML)
qcsumax(Y,P,T,Z,SML)
qcsdmin(Y,P,T,Z,SML)
qcsdmax(Y,P,T,Z,SML)
qcrufd(Y,P,T,Z,SML)
qcruad(Y,P,T,Z,SML)
qcrumd(Y,P,T,Z,SML)
qcrdfu(Y,P,T,Z,SML)
qcrdau(Y,P,T,Z,SML)
qcrdmu(Y,P,T,Z,SML)
qcrunsmin(Y,P,T,Z,RD,SML)
qcrunsmax(Y,P,T,Z,RD,SML)
qcrdsdmin(Y,P,T,Z,RU,SML)
qcrdsdmax(Y,P,T,Z,RU,SML)

qcapdeqcapc(Y,Z,SM)
qnd(Y,P,T,Z,SM)
qndmax(Y,P,T,Z,SM)
qndsu(Y,P,T,Z,SM)
qndsd(Y,P,T,Z,SM)
qsmd(Y,P,T,Z,SM)
qsmdmin(Y,P,T,Z,SM)
qsmdmax(Y,P,T,Z,SM)
qdrudyn(Y,P,T,Z,SM)
qdrucap(Y,P,T,Z,SM)
qdrddyn(Y,P,T,Z,SM)
qdrdcap(Y,P,T,Z,SM)
qdsumin(Y,P,T,Z,SM)
qdsumax(Y,P,T,Z,SM)
qdsdmin(Y,P,T,Z,SM)
qdsdmax(Y,P,T,Z,SM)
qdrufu(Y,P,T,Z,SM)
qdruau(Y,P,T,Z,SM)
qdrumu(Y,P,T,Z,SM)
qdrdfd(Y,P,T,Z,SM)
qdrdad(Y,P,T,Z,SM)
qdrdmd(Y,P,T,Z,SM)
qdrunsmin(Y,P,T,Z,RU,SM)
qdrunsmax(Y,P,T,Z,RU,SM)
qdrdsdmin(Y,P,T,Z,RD,SM)
qdrdsdmax(Y,P,T,Z,RD,SM)

qslressd(Y,P,T,Z,R,SL)
qgase(Y,P,C)
qgasemax(Y,P,C)
qgasef(Y,P,T,C)
qgasefmax(Y,P,T,C)
qgasefstart(Y,P,T,C)
qgasel(Y,P,T,C)
qgaselmax(Y,P,T,C)
qgaselstart(Y,P,T,C)
qgasc(Y,P,T,C)
qgasd(Y,P,T,C)
qgasuse(Y,C)
qgasusegen(Y,P,T,Z,GCG)

#--Activation--#
#--Reserve activations--#

qactu(Y,P,T,C,R)
qactd(Y,P,T,C,R)

qactglim(Y,P,T,Z,R,G)
qactslimc(Y,P,T,Z,R,S)
qactslimd(Y,P,T,Z,R,S)

;

#-----######################---------------------------------------------------#
#-----# Objective function #---------------------------------------------------#
#-----######################---------------------------------------------------#
qobj..              obj
                    =e=
                        sum((Y,Z,G),            (G_DATA(G,'C_INV') + G_DATA(G,'C_FOM'))*1000*cap(Y,Z,G))
                        + sum((Y,Z,SS),         (S_DATA(SS,'C_E_INV')*1000*e_cap(Y,Z,SS)))
                        + sum((Y,C,SS),         (cyc_cost(Y,C,SS)))
                        + sum((Y,Z,SM),         (S_DATA(SM,'C_E_INV')*1000)*e_cap(Y,Z,SM))
                        + sum((Y,Z,S),          (S_DATA(S,'C_P_C_INV')*1000)*p_cap_c(Y,Z,S))
                        + sum((Y,Z,SM),         (S_DATA(SM,'C_P_D_INV')*1000)*p_cap_d(Y,Z,SM))
#                        +                       (EGCAPEX*1000)*eg_cap
                        +(sum((Y,P,T,Z,G),      W(P)*(G_DATA(G,'C_VOM'))*gen(Y,P,T,Z,G))
#                        + sum((Y,P,T,Z,G),      W(P)*(G_DATA(G,'C_VOM'))*(sum(RU, act_g(Y,P,T,Z,RU,G)) - sum(RD, act_g(Y,P,T,Z,RD,G))))
                        + sum((Y,P,T,Z,GD),     W(P)*(G_DATA(GD,'C_FUEL'))*gen(Y,P,T,Z,GD))
#                        + sum((Y,P,T,Z,GD),     W(P)*(G_DATA(GD,'C_FUEL'))*(sum(RU, act_g(Y,P,T,Z,RU,GD)) - sum(RD, act_g(Y,P,T,Z,RD,GD))))
#                        + sum((Y,P,T,Z,SSM),    W(P)*44*(sum(RU, act_s_c(Y,P,T,Z,RU,SSM)) - sum(RD, act_s_d(Y,P,T,Z,RD,SSM)*(S_DATA(SSM,'EFF_C')/100)*(S_DATA(SSM,'EFF_D')/100))))
#                        + sum((Y,P,T,Z,SSM),    W(P)*44*(sum(RU, act_s_d(Y,P,T,Z,RU,SSM))/(S_DATA(SSM,'EFF_C')/100)/(S_DATA(SSM,'EFF_D')/100)) - sum(RD, act_s_d(Y,P,T,Z,RD,SSM)))
#                        + sum((Y,P,T,Z,SL),     W(P)*44*(sum(RU, act_s_c(Y,P,T,Z,RU,SL))))
#                         + sum((Y,P,T,Z,GCO),    W(P)*(G_DATA(GCO,'C_FUEL'))*gen(Y,P,T,Z,GCO))
#                         + sum((Y,P,T,Z,GRD),    W(P)*(G_DATA(GRD,'C_FUEL'))*gen(Y,P,T,Z,GRD))
#                         + sum((Y,P,T,C),        W(P)*(C_GAS)*pg_import(Y,P,T,C))
                        + sum((Y,P,T,Z,GD),     W(P)*(G_DATA(GD,'RC'))*(ramp_up(Y,P,T,Z,GD)+ramp_dn(Y,P,T,Z,GD)))/(TIMESTEP/4)
                        + sum((Y,P,T,Z,GD),     W(P)*(G_DATA(GD,'SUC'))*(ramp_su(Y,P,T,Z,GD)+ramp_sd(Y,P,T,Z,GD)))/(TIMESTEP/4)
                        + sum((Y,P,T,Z,GRI),    W(P)*(0)*curt(Y,P,T,Z,GRI) + W(P)*(1000000)*curt_dummy(Y,P,T,Z,GRI))
#                        + sum((Y,P,T,Z,GRI),    W(P)*(0)*(curt_a(Y,P,T,Z,GRI)-curt(Y,P,T,Z,GRI)))
#                        + sum((Y,P,T,Z,S),      W(P)*(S_DATA(S,'OPEX'))*p_c(Y,P,T,Z,S))

                        + sum((Y,P,T,Z),        W(P)*(3000)*load_shedding(Y,P,T,Z) + sum(R, load_shedding_r(Y,P,T,Z,R)))
#                        + sum((Y,P,T,Z),        W(P)*(3000)*((load_shedding_a(Y,P,T,Z) - load_shedding(Y,P,T,Z)) + load_shedding_r(Y,P,T,Z)))
                        )*((35040/TIMESTEP)/(sum(P, W(P))*card(T)))*(TIMESTEP/4)
                        ;


#-----######################---------------------------------------------------#
#-----# System constraints #---------------------------------------------------#
#-----######################---------------------------------------------------#

#--System balance--#

qbalance(Y,P,T,Z)..
                    sum(G, gen(Y,P,T,Z,G))
                    + sum(SSM, p_d(Y,P,T,Z,SSM))
                    =e=
                        DEM_T(P,T,Z)
                        #+ sum(D, cons(Y,P,T,Z,D))
                        #- sum(D, D_DATA(D,'CONS'))
                        + sum(S, p_c(Y,P,T,Z,S))
                        - load_shedding(Y,P,T,Z)
                        ;
#DEM(Y,Z)*DEM_T(T,Z);

#--Renewable target--#

#qresprod(Y,C)..
#                    sum(Z $ C_Z(C,Z), 	sum((GCO,P,T), W(P)*gen(Y,P,T,Z,GCO)))
#					+ sum(Z $ C_Z(C,Z), sum((GCG,P,T), W(P)*pg_fos(Y,P,T,Z,GCG)*(G_DATA(GCG,'EFF')/100)))
#					=l=
#                        (100 - POL_TARGETS('RES_SHARE', Y))/100 * sum(Z $ C_Z(C,Z), sum((P,T), W(P)*DEM_T(P,T,Z)))
#                        ;

qresprod(Y,C)..
                   sum(Z $ C_Z(C,Z), sum((GR,P,T), W(P)*gen(Y,P,T,Z,GR)))
#                   + sum(Z $ C_Z(C,Z), sum((GRI,P,T), W(P)*(curt(Y,P,T,Z,GRI) - curt_r(Y,P,T,Z,GRI))))
#                   + sum(Z $ C_Z(C,Z), sum((GR,P,T,RU), W(P)*act_g(Y,P,T,Z,RU,GR)))
#                   - sum(Z $ C_Z(C,Z), sum((GR,P,T,RD), W(P)*act_g(Y,P,T,Z,RD,GR)))
                   =g=
                        POL_TARGETS('RES_SHARE', Y)/100 * sum(Z $ C_Z(C,Z), sum((P,T), W(P)*DEM_T(P,T,Z)))
                        ;

qco2lim(Y,C)..
#                   sum(Z $ C_Z(C,Z), sum((GCO,P,T), W(P)*gen(Y,P,T,Z,GCO)*G_DATA(GCO,'CO2')))
#                   + sum(Z $ C_Z(C,Z), sum((GCG,P,T), W(P)*pg_fos(Y,P,T,Z,GCG)*(G_DATA(GCG,'EFF')/100)*G_DATA(GCG,'CO2')))
                    sum(Z $ C_Z(C,Z), sum((GC,P,T), W(P)*gen(Y,P,T,Z,GC)*G_DATA(GC,'CO2')))
                    =l=
                        160000000000000
                        ;

#--Reserve requirements--#

qresa(Y,A,C,R)..
                    sum(Z $ C_Z(C,Z),   sum(G, res_a_g(Y,A,Z,R,G)))
                    + sum(Z $ C_Z(C,Z), sum(S, res_a_s(Y,A,Z,R,S)))
#                    + sum(Z $ C_Z(C,Z), sum(D, res_d(Y,P,Z,RM,D)))
                    =e=
                        RC_A_EXO(A,C,R)
                        + sum(GRI, RC_A_ENDO(A,C,GRI,R)*sum(Z $ C_Z(C,Z), cap(Y,Z,GRI)))
                        ;

qreso(Y,P,T,C,R)..
                    sum(Z $ C_Z(C,Z),   sum(G, res_o_g(Y,P,T,Z,R,G)))
                    + sum(Z $ C_Z(C,Z), sum(S, res_o_s(Y,P,T,Z,R,S)))
#                    + sum(Z $ C_Z(C,Z), sum(D, res_d(Y,P,Z,RM,D)))
                    =e=
                        RC_O_EXO(P,T,C,R)
                        + sum(GRI, RC_O_ENDO(P,T,C,GRI,R)*sum(Z $ C_Z(C,Z), cap(Y,Z,GRI)))
                        ;

qallg(Y,A,P,T,Z,R,G)$(APT(A,P,T))..
                    res_a_t_g(Y,A,P,T,Z,R,G)
                    =e=
                        res_a_g(Y,A,Z,R,G)
                        ;

qallgnot(Y,A,P,T,Z,R,G)$(not APT(A,P,T))..
                    res_a_t_g(Y,A,P,T,Z,R,G)
                    =e=
                        0
                        ;

qalls(Y,A,P,T,Z,R,S)$(APT(A,P,T))..
                    res_a_t_s(Y,A,P,T,Z,R,S)
                    =e=
                        res_a_s(Y,A,Z,R,S)
                        ;

qallsnot(Y,A,P,T,Z,R,S)$(not APT(A,P,T))..
                    res_a_t_s(Y,A,P,T,Z,R,S)
                    =e=
                        0
                        ;

qresallg(Y,P,T,Z,R,G)..
                    res_g(Y,P,T,Z,R,G)
                    =e=
                        sum(A, res_a_t_g(Y,A,P,T,Z,R,G))
                        + res_o_g(Y,P,T,Z,R,G)
                        ;

qresalls(Y,P,T,Z,R,S)..
                    res_s(Y,P,T,Z,R,S)
                    =e=
                        sum(A, res_a_t_s(Y,A,P,T,Z,R,S))
                        + res_o_s(Y,P,T,Z,R,S)
                        ;

#--Reserve activation--#

qactu(Y,P,T,C,RU)..
                    sum(Z $ C_Z(C,Z),   sum(G, act_g(Y,P,T,Z,RU,G)))
                    + sum(Z $ C_Z(C,Z), sum(S, act_s_c(Y,P,T,Z,RU,S)))
                    + sum(Z $ C_Z(C,Z), sum(SSM, act_s_d(Y,P,T,Z,RU,SSM)))
                    + sum(Z $ C_Z(C,Z), load_shedding_r(Y,P,T,Z,RU))
                    =e=
                        RP_EXO(P,T,C,RU)
#                        + sum(GRI, sum(Z $ C_Z(C,Z), q_act_g(Y,P,T,Z,RU,GRI)))
                        + sum(GRI, RP_ENDO(P,T,C,GRI,RU)*sum(Z $ C_Z(C,Z), cap(Y,Z,GRI)))
                        ;

qactd(Y,P,T,C,RD)..
                    sum(Z $ C_Z(C,Z),   sum(G, act_g(Y,P,T,Z,RD,G)))
                    + sum(Z $ C_Z(C,Z), sum(S, act_s_c(Y,P,T,Z,RD,S)))
                    + sum(Z $ C_Z(C,Z), sum(SSM, act_s_d(Y,P,T,Z,RD,SSM)))
                    + sum(Z $ C_Z(C,Z), load_shedding_r(Y,P,T,Z,RD))
                    =e=
                        RP_EXO(P,T,C,RD)
#                        + sum(GRI, sum(Z $ C_Z(C,Z), q_act_g(Y,P,T,Z,RD,GRI)))
                        + sum(GRI, RP_ENDO(P,T,C,GRI,RD)*sum(Z $ C_Z(C,Z), cap(Y,Z,GRI)))
                        ;

qactglim(Y,P,T,Z,R,G)..
                    act_g(Y,P,T,Z,R,G)
                    =l=
                        res_g(Y,P,T,Z,R,G)
                        ;

qactslimc(Y,P,T,Z,R,S)..
                    act_s_c(Y,P,T,Z,R,S)
                    =l=
                        res_s_c(Y,P,T,Z,R,S)
                        ;

qactslimd(Y,P,T,Z,R,S)..
                    act_s_d(Y,P,T,Z,R,S)
                    =l=
                        res_s_d(Y,P,T,Z,R,S)
                        ;

#--Dispatchable capacity--#

qgendisp(Y,P,T,C)..
                    sum(Z $ C_Z(C,Z), sum(GD, gen(Y,P,T,Z,GD)))
                    =g=
                        sum(Z $ C_Z(C,Z), DEM_T(P,T,Z))*0.20
                        ;

qgendisppeak(Y,C)..
                    sum(Z $ C_Z(C,Z), sum(GD, cap(Y,Z,GD)))
                    =g=
                        10000*1.20
                        ;

#--Emissions--#

qco2(Y,C,G)..
                    co2(Y,C,G)
                    =e=
                        sum(Z $ C_Z(C,Z), sum((P,T), W(P)*gen(Y,P,T,Z,G)*G_DATA(G,'CO2')))*((35040/TIMESTEP)/(sum(P, W(P))*card(T)))*(TIMESTEP/4)
                        ;

qlcg(Y,C,G)..
                    lcg(Y,C,G)
                    =e=
                        sum(Z $ C_Z(C,Z), sum((P,T), gen(Y,P,T,Z,G)*G_DATA(G,'LCG')))*((35040/TIMESTEP)/(sum(P, W(P))*card(T)))*(TIMESTEP/4)
                        ;


#-----###########################----------------------------------------------#
#-----# Generation technologies #----------------------------------------------#
#-----###########################----------------------------------------------#

##--Installed generation capacities--#

qgcapmin(Y,C,G)..
                    sum(Z $ C_Z(C,Z), cap(Y,Z,G))
                    =g=
                        G_DATA(G,'CAP_MIN')
                        ;

qgcapmax(Y,C,G)..
                    sum(Z $ C_Z(C,Z), cap(Y,Z,G))
                    =l=
                        G_DATA(G,'CAP_MAX')
                        ;

qgcapminres(Y,Z,G)..
                   cap(Y,Z,G)
                   =g=
                        CAP_INST_G(Y,Z,G,'CAP_MIN')
                        ;

qgcapmaxres(Y,Z,G)..
                   cap(Y,Z,G)
                   =l=
                        CAP_INST_G(Y,Z,G,'CAP_MAX')
                        ;

#qggenmin(Y,C,G)..
#                                       sum(Z $ C_Z(C,Z), sum(T, gen(Y,T,Z,G)))
#                                       =g=
#                                               CAP_G(Y,Z,G,'GEN_MIN')*(TIMESTEP/4)
#                                               ;
#
qggenmax(Y,C,G)..
                    sum(Z $ C_Z(C,Z), sum((P,T), gen(Y,P,T,Z,G)*W(P)))
                    =l=
                        G_DATA(G,'GEN_MAX')*((35040/TIMESTEP)/(sum(P, W(P))*card(T)))*(TIMESTEP/4)
                        ;

#-------Dispatchable generation technologies-----------------------------------#

#--Reserve allocation--#

qresgcu(Y,P,T,Z,RU,GD)..
                    res_g(Y,P,T,Z,RU,GD)
                    =e=
                        res_g_s(Y,P,T,Z,RU,GD)
                        + res_g_ns(Y,P,T,Z,RU,GD)
                        ;

qresgcd(Y,P,T,Z,RD,GD)..
                    res_g(Y,P,T,Z,RD,GD)
                    =e=
                        res_g_s(Y,P,T,Z,RD,GD)
                        + res_g_sd(Y,P,T,Z,RD,GD)
                        ;

#--Clustering logical constraints--#

qn(Y,P,T,Z,GD)$(ord(T)<card(T))..
                    n(Y,P,T+1,Z,GD)
                    =e=
                        n(Y,P,T,Z,GD)
                        + n_su(Y,P,T,Z,GD)
                        - n_sd(Y,P,T,Z,GD)
                        ;

qnmax(Y,P,T,Z,GD)..
                    n(Y,P,T,Z,GD)
                    =l=
                        cap(Y,Z,GD)/G_DATA(GD,'P_MAX')
                        ;

qnsu(Y,P,T,Z,GD)..
                    n_su(Y,P,T,Z,GD)
                    + sum(RU, n_su_r(Y,P,T,Z,RU,GD))
                    =l=
                        cap(Y,Z,GD)/G_DATA(GD,'P_MAX')
                        - n(Y,P,T,Z,GD)
                        - sum(G_MDT(GD,T_MDT), n_sd(Y,P, T-(ord(T_MDT)-1), Z, GD))
                        ;

qnsd(Y,P,T,Z,GD)..
                    n_sd(Y,P,T,Z,GD)
                    + sum(RD, n_sd_r(Y,P,T,Z,RD,GD))
                    =l=
                        n(Y,P,T,Z,GD)
                        - sum(G_MUT(GD,T_MUT), n_su(Y,P, T-(ord(T_MUT)-1), Z, GD))
                        ;

#--Generation constraints--#

qgen(Y,P,T,Z,GD)$(ord(T)<card(T))..
                    gen(Y,P,T+1,Z,GD)
                    =e=
                        gen(Y,P,T,Z,GD)
                        + ramp_up(Y,P,T,Z,GD)
                        - ramp_dn(Y,P,T,Z,GD)
                        + ramp_su(Y,P,T,Z,GD)
                        - ramp_sd(Y,P,T,Z,GD)
                        ;

qgenmin(Y,P,T,Z,GD)..
                    gen(Y,P,T,Z,GD)
                    =g=
                        n(Y,P,T,Z,GD)*G_DATA(GD,'P_MIN')
                        ;

qgenmax(Y,P,T,Z,GD)..
                    gen(Y,P,T,Z,GD)
                    =l=
                        n(Y,P,T,Z,GD)*G_DATA(GD,'P_MAX')
                        ;
                        #*G_DATA(G,'PM')/100;

#--Ramping constraints--#

qrudyn(Y,P,T,Z,GD)..
                    ramp_up(Y,P,T,Z,GD)
                    + sum(RU, res_g_s(Y,P,T,Z,RU,GD))
                    =l=
                        (n(Y,P,T,Z,GD)-n_sd(Y,P,T,Z,GD))*G_DATA(GD,'RH')/100*G_DATA(GD,'P_MAX')
                        ;

qrucap(Y,P,T,Z,GD)..
                    ramp_up(Y,P,T,Z,GD)
                    + sum(RU, res_g_s(Y,P,T,Z,RU,GD))
                    =l=
                        (n(Y,P,T,Z,GD)-n_sd(Y,P,T,Z,GD))*G_DATA(GD,'P_MAX')
                        - (gen(Y,P,T,Z,GD)-ramp_sd(Y,P,T,Z,GD))
                        ;

qrddyn(Y,P,T,Z,GD)..
                    ramp_dn(Y,P,T,Z,GD)
                    + sum(RD, res_g_s(Y,P,T,Z,RD,GD))
                    =l=
                        (n(Y,P,T,Z,GD)-n_sd(Y,P,T,Z,GD)-sum(RD, n_sd_r(Y,P,T,Z,RD,GD)))*G_DATA(GD,'RH')/100*G_DATA(GD,'P_MAX')
                        ;

qrdcap(Y,P,T,Z,GD)..
                    ramp_dn(Y,P,T,Z,GD)
                    + sum(RD, res_g_s(Y,P,T,Z,RD,GD))
                    =l=
                        (gen(Y,P,T,Z,GD)-ramp_sd(Y,P,T,Z,GD)-sum(RD, res_g_sd(Y,P,T,Z,RD,GD)))
                        - (n(Y,P,T,Z,GD)-n_sd(Y,P,T,Z,GD)-sum(RD, n_sd_r(Y,P,T,Z,RD,GD)))*G_DATA(GD,'P_MIN')
                        ;

qsumin(Y,P,T,Z,GD)..
                    ramp_su(Y,P,T,Z,GD)
                    =g=
                        n_su(Y,P,T,Z,GD)*G_DATA(GD,'P_MIN')
                        ;

qsumax(Y,P,T,Z,GD)..
                    ramp_su(Y,P,T,Z,GD)
                    =l=
                        n_su(Y,P,T,Z,GD)*G_DATA(GD,'P_MIN')
                        + n_su(Y,P,T,Z,GD)*G_DATA(GD,'RHNS')/100*G_DATA(GD,'P_MAX')
                        ;

qsdmin(Y,P,T,Z,GD)..
                    ramp_sd(Y,P,T,Z,GD)
                    =g=
                        n_sd(Y,P,T,Z,GD)*G_DATA(GD,'P_MIN')
                        ;

qsdmax(Y,P,T,Z,GD)..
                    ramp_sd(Y,P,T,Z,GD)
                    =l=
                        n_sd(Y,P,T,Z,GD)*G_DATA(GD,'P_MIN')
                        + n_sd(Y,P,T,Z,GD)*G_DATA(GD,'RHNS')/100*G_DATA(GD,'P_MAX')
                        ;

#--Reserve allocation constraints--#

qrufu(Y,P,T,Z,GD)..
                    sum(RUF, res_g_s(Y,P,T,Z,RUF,GD))
                    =l=
                        (n(Y,P,T,Z,GD)-n_sd(Y,P,T,Z,GD))*G_DATA(GD,'RF')/100*G_DATA(GD,'P_MAX')
                        ;

qruau(Y,P,T,Z,GD)..
                    sum(RUA, res_g_s(Y,P,T,Z,RUA,GD))
                    =l=
                        (n(Y,P,T,Z,GD)-n_sd(Y,P,T,Z,GD))*G_DATA(GD,'RA')/100*G_DATA(GD,'P_MAX')
                        ;

qrumu(Y,P,T,Z,GD)..
                    sum(RU, res_g_s(Y,P,T,Z,RU,GD))
                    =l=
                        (n(Y,P,T,Z,GD)-n_sd(Y,P,T,Z,GD))*G_DATA(GD,'RM')/100*G_DATA(GD,'P_MAX')
                        ;

qrdfd(Y,P,T,Z,GD)..
                    sum(RDF, res_g_s(Y,P,T,Z,RDF,GD))
                    =l=
                        (n(Y,P,T,Z,GD)-n_sd(Y,P,T,Z,GD)-sum(RD, n_sd_r(Y,P,T,Z,RD,GD)))*G_DATA(GD,'RF')/100*G_DATA(GD,'P_MAX')
                        ;

qrdad(Y,P,T,Z,GD)..
                    sum(RDA, res_g_s(Y,P,T,Z,RDA,GD))
                    =l=
                        (n(Y,P,T,Z,GD)-n_sd(Y,P,T,Z,GD)-sum(RD, n_sd_r(Y,P,T,Z,RD,GD)))*G_DATA(GD,'RA')/100*G_DATA(GD,'P_MAX')
                        ;

qrdmd(Y,P,T,Z,GD)..
                    sum(RD, res_g_s(Y,P,T,Z,RD,GD))
                    =l=
                        (n(Y,P,T,Z,GD)-n_sd(Y,P,T,Z,GD)-sum(RD, n_sd_r(Y,P,T,Z,RD,GD)))*G_DATA(GD,'RM')/100*G_DATA(GD,'P_MAX')
                        ;

qrunsmin(Y,P,T,Z,RU,GD)..
                    res_g_ns(Y,P,T,Z,RU,GD)
                    =g=
                        n_su_r(Y,P,T,Z,RU,GD)*G_DATA(GD,'P_MIN')
                        ;

qrunsmax(Y,P,T,Z,RU,GD)..
                    res_g_ns(Y,P,T,Z,RU,GD)
                    =l=
                        n_su_r(Y,P,T,Z,RU,GD)*RG(RU,GD)/100*G_DATA(GD,'P_MAX')
                        ;

qrdsdmin(Y,P,T,Z,RD,GD)..
                    res_g_sd(Y,P,T,Z,RD,GD)
                    =g=
                        n_sd_r(Y,P,T,Z,RD,GD)*G_DATA(GD,'P_MIN')
                        ;

qrdsdmax(Y,P,T,Z,RD,GD)..
                    res_g_sd(Y,P,T,Z,RD,GD)
                    =l=
                        n_sd_r(Y,P,T,Z,RD,GD)*RG(RD,GD)/100*G_DATA(GD,'P_MAX')
                        ;

#-------Intermittent renewable generation technologies-------------------------#

#--Reserve allocation--#

qresgru(Y,P,T,Z,RU,GRI)..
                    res_g(Y,P,T,Z,RU,GRI)
                    =e=
                        0
                        ;

#--Output and curtailment constraint--#

qgenr(Y,P,T,Z,GRI)..
                    gen(Y,P,T,Z,GRI)
                    + curt(Y,P,T,Z,GRI)
                    + curt_dummy(Y,P,T,Z,GRI)
                    =e=
                        cap(Y,Z,GRI)*RES_T(P,T,Z,GRI)
                        ;

#--Reserve allocation constraints--#

qresgrdr(Y,P,T,Z,GRI)..
                   sum(RD, res_g(Y,P,T,Z,RD,GRI))
                    =l=
                        cap(Y,Z,GRI)*REL_T(P,T,Z,GRI)
                        ;

qresgrdg(Y,P,T,Z,GRI)..
                   sum(RD, res_g(Y,P,T,Z,RD,GRI))
                    =l=
                        gen(Y,P,T,Z,GRI)
#                       0
                        ;

#-----###########################----------------------------------------------#
#-----# Demand technologies #----------------------------------------------#
#-----###########################----------------------------------------------#

##--Installed demand capacities--#

#TO DO set to zones instead of countries
qdrcapmin(Y,C,D)..
                    sum(Z $ C_Z(C,Z), dr_cap(Y,Z,D))
                    =g=
                        D_DATA(D,'CAP_MIN')
                        ;

qdrcapmax(Y,C,D)..
                    sum(Z $ C_Z(C,Z), dr_cap(Y,Z,D))
                    =l=
                        D_DATA(D,'CAP_MAX')
                        ;

qdrconsdnact(Y,P,T,Z,D)..
                    cons_dn_act(Y,P,T,Z,D)
                    =g=
                        D_DATA(D,'CONS')
                        - cons(Y,P,T,Z,D)
                        ;

qdrconsmin(Y,C,D)..
                    sum(Z $ C_Z(C,Z), sum((P,T), cons(Y,P,T,Z,D)*W(P)))
                    =g=
                        (D_DATA(D,'CONS')*8760)*((35040/TIMESTEP)/(sum(P, W(P))*card(T)))*(TIMESTEP/4)
                        ;

qdrfmax(Y,C,D)..
                    sum(Z $ C_Z(C,Z), sum((P,T), cons_dn_act(Y,P,T,Z,D)*W(P)))
                    =l=
                        (D_DATA(D,'A_MAX')*D_DATA(D,'DP_MAX')*D_DATA(D,'DT_MAX'))*((35040/TIMESTEP)/(sum(P, W(P))*card(T)))*(TIMESTEP/4)
                        ;

qdrdpmax(Y,P,T,Z,D)..
                    cons_dn_act(Y,P,T,Z,D)
                    =l=
                        D_DATA(D,'DP_MAX')
                        ;

qdrdtmax(Y,P,T,Z,D)..
                    sum(D_DT_MAX(D,T_D), cons_dn_act(Y,P,T-(ord(T_D)-1),Z,D) )
                    =l=
                        D_DATA(D,'DP_MAX')*D_DATA(D,'DT_MAX')
                        ;

#--Reserve allocation--#

qresdrcu(Y,P,T,Z,RD,D)..
                    res_dr(Y,P,Z,RD,D)
                    =e=
                        res_dr_s(Y,P,T,Z,RD,D)
                        + res_dr_ns(Y,P,T,Z,RD,D)
                        ;

qresdrcd(Y,P,T,Z,RU,D)..
                    res_dr(Y,P,Z,RU,D)
                    =e=
                        res_dr_s(Y,P,T,Z,RU,D)
                        + res_dr_sd(Y,P,T,Z,RU,D)
                        ;

#--Clustering logical constraints--#

qndr(Y,P,T,Z,D)$(ord(T)<card(T))..
                    n_dr(Y,P,T+1,Z,D)
                    =e=
                        n_dr(Y,P,T,Z,D)
                        + n_dr_su(Y,P,T,Z,D)
                        - n_dr_sd(Y,P,T,Z,D)
                        ;

qndrmax(Y,P,T,Z,D)..
                    n_dr(Y,P,T,Z,D)
                    =l=
                        dr_cap(Y,Z,D)/D_DATA(D,'P_MAX')
                        ;

qndrsu(Y,P,T,Z,D)..
                    n_dr_su(Y,P,T,Z,D)
                    + sum(RD, n_dr_su_r(Y,P,T,Z,RD,D))
                    =l=
                        dr_cap(Y,Z,D)/D_DATA(D,'P_MAX')
                        - n_dr(Y,P,T,Z,D)
                        - sum(D_MDT(D,T_MDT), n_dr_sd(Y,P, T-(ord(T_MDT)-1),Z,D))
                        ;

qndrsd(Y,P,T,Z,D)..
                    n_dr_sd(Y,P,T,Z,D)
                    + sum(RU, n_dr_sd_r(Y,P,T,Z,RU,D))
                    =l=
                        n_dr(Y,P,T,Z,D)
                        - sum(D_MUT(D,T_MUT), n_dr_su(Y,P, T-(ord(T_MUT)-1),Z,D))
                        ;

#--Consumption constraints--#

qcons(Y,P,T,Z,D)$(ord(T)<card(T))..
                    cons(Y,P,T+1,Z,D)
                    =e=
                        cons(Y,P,T,Z,D)
                        + ramp_dr_up(Y,P,T,Z,D)
                        - ramp_dr_dn(Y,P,T,Z,D)
                        + ramp_dr_su(Y,P,T,Z,D)
                        - ramp_dr_sd(Y,P,T,Z,D)
                        ;

qconsmin(Y,P,T,Z,D)..
                    cons(Y,P,T,Z,D)
                    =g=
                        n_dr(Y,P,T,Z,D)*D_DATA(D,'P_MIN')
                        ;

qconsmax(Y,P,T,Z,D)..
                    cons(Y,P,T,Z,D)
                    =l=
                        n_dr(Y,P,T,Z,D)*D_DATA(D,'P_MAX')
                        ;

#--Ramping constraints--#

qdrrudyn(Y,P,T,Z,D)..
                    ramp_dr_up(Y,P,T,Z,D)
                    + sum(RD, res_dr_s(Y,P,T,Z,RD,D))
                    =l=
                        (n_dr(Y,P,T,Z,D)-n_dr_sd(Y,P,T,Z,D))*D_DATA(D,'RH')/100*D_DATA(D,'P_MAX')
                        ;

qdrrucap(Y,P,T,Z,D)..
                    ramp_dr_up(Y,P,T,Z,D)
                    + sum(RD, res_dr_s(Y,P,T,Z,RD,D))
                    =l=
                        (n_dr(Y,P,T,Z,D)-n_dr_sd(Y,P,T,Z,D))*D_DATA(D,'P_MAX')
                        - (cons(Y,P,T,Z,D)-ramp_dr_sd(Y,P,T,Z,D))
                        ;

qdrrddyn(Y,P,T,Z,D)..
                    ramp_dr_dn(Y,P,T,Z,D)
                    + sum(RU, res_dr_s(Y,P,T,Z,RU,D))
                    =l=
                        (n_dr(Y,P,T,Z,D)-n_dr_sd(Y,P,T,Z,D)-sum(RU, n_dr_sd_r(Y,P,T,Z,RU,D)))*D_DATA(D,'RH')/100*D_DATA(D,'P_MAX')
                        ;

qdrrdcap(Y,P,T,Z,D)..
                    ramp_dr_dn(Y,P,T,Z,D)
                    + sum(RU, res_dr_s(Y,P,T,Z,RU,D))
                    =l=
                        (cons(Y,P,T,Z,D)-ramp_dr_sd(Y,P,T,Z,D)-sum(RU, res_dr_sd(Y,P,T,Z,RU,D)))
                        - (n_dr(Y,P,T,Z,D)-n_dr_sd(Y,P,T,Z,D)-sum(RU, n_dr_sd_r(Y,P,T,Z,RU,D)))*D_DATA(D,'P_MIN')
                        ;

qdrsumin(Y,P,T,Z,D)..
                    ramp_dr_su(Y,P,T,Z,D)
                    =g=
                        n_dr_su(Y,P,T,Z,D)*D_DATA(D,'P_MIN')
                        ;

qdrsumax(Y,P,T,Z,D)..
                    ramp_dr_su(Y,P,T,Z,D)
                    =l=
                        n_dr_su(Y,P,T,Z,D)*D_DATA(D,'P_MIN')
                        + n_dr_su(Y,P,T,Z,D)*D_DATA(D,'RHNS')/100*D_DATA(D,'P_MAX')
                        ;

qdrsdmin(Y,P,T,Z,D)..
                    ramp_dr_sd(Y,P,T,Z,D)
                    =g=
                        n_dr_sd(Y,P,T,Z,D)*D_DATA(D,'P_MIN')
                        ;

qdrsdmax(Y,P,T,Z,D)..
                    ramp_dr_sd(Y,P,T,Z,D)
                    =l=
                        n_dr_sd(Y,P,T,Z,D)*D_DATA(D,'P_MIN')
                        + n_dr_sd(Y,P,T,Z,D)*D_DATA(D,'RHNS')/100*D_DATA(D,'P_MAX')
                        ;

#--Reserve allocation constraints--#

#qdrruad(Y,P,T,Z,D)..
#                    sum(RDA, res_dr_s(Y,P,T,Z,RDA,D))
#                    =l=
#                        (n_dr(Y,P,T,Z,D)-n_dr_sd(Y,P,T,Z,D))*D_DATA(D,'RA')/100*D_DATA(D,'P_MAX')
#                        ;
#
#qdrrumds(Y,P,T,Z,D)..
#                    sum(RD, res_dr_s(Y,P,T,Z,RD,D))
#                    =l=
#                        (n_dr(Y,P,T,Z,D)-n_dr_sd(Y,P,T,Z,D))*D_DATA(D,'RM')/100*D_DATA(D,'P_MAX')
#                        ;
#
#qdrrdfu(Y,P,T,Z,D)..
#                    sum(RUF, res_dr_s(Y,P,T,Z,RUF,D))
#                    =l=
#                        (n_dr(Y,P,T,Z,D)-n_dr_sd(Y,P,T,Z,D)-sum(RU, n_dr_sd_r(Y,P,T,Z,RU,D)))*D_DATA(D,'RF')/100*D_DATA(D,'P_MAX')
#                        ;
#
#qdrrdau(Y,P,T,Z,D)..
#                    sum(RUA, res_dr_s(Y,P,T,Z,RUA,GD))
#                    =l=
#                        (n_dr(Y,P,T,Z,D)-n_dr_sd(Y,P,T,Z,D)-sum(RU, n_dr_sd_r(Y,P,T,Z,RU,D)))*D_DATA(D,'RA')/100*D_DATA(D,'P_MAX')
#                        ;
#
#qdrrdmu(Y,P,T,Z,D)..
#                    sum(RU, res_dr_s(Y,P,T,Z,RU,D))
#                    =l=
#                        (n_dr(Y,P,T,Z,D)-n_dr_sd(Y,P,T,Z,D)-sum(RU, n_dr_sd_r(Y,P,T,Z,RU,D)))*D_DATA(D,'RM')/100*D_DATA(D,'P_MAX')
#                        ;
#
#qdrrunsmin(Y,P,T,Z,RD,D)..
#                    res_dr_ns(Y,P,T,Z,RD,D)
#                    =g=
#                        n_dr_su_r(Y,P,T,Z,RD,D)*D_DATA(D,'P_MIN')
#                        ;
#
#qdrrunsmax(Y,P,T,Z,RD,D)..
#                    res_dr_ns(Y,P,T,Z,RD,D)
#                    =l=
#                        n_dr_su_r(Y,P,T,Z,RD,D)*RDR(RD,D)/100*D_DATA(D,'P_MAX')
#                        ;
#
#qdrrdsdmin(Y,P,T,Z,RU,D)..
#                    res_dr_sd(Y,P,T,Z,RU,D)
#                    =g=
#                        n_dr_sd_r(Y,P,T,Z,RU,D)*D_DATA(D,'P_MIN')
#                        ;
#
#qdrrdsdmax(Y,P,T,Z,RU,D)..
#                    res_dr_sd(Y,P,T,Z,RU,D)
#                    =l=
#                        n_dr_sd_r(Y,P,T,Z,RU,D)*RDR(RU,D)/100*D_DATA(D,'P_MAX')
#                        ;


#-----########################-------------------------------------------------#
#-----# Storage technologies #-------------------------------------------------#
#-----########################-------------------------------------------------#

#-------General constraints----------------------------------------------------#

#--Reserve allocation--#

qress(Y,P,T,Z,R,S)..
                    res_s(Y,P,T,Z,R,S)
                    =e=
                        res_s_c(Y,P,T,Z,R,S)
                        + res_s_d(Y,P,T,Z,R,S)
                        ;

#--Installed capacities--#

qspotecapmin(Y,C,S)..
                    sum(Z $ C_Z(C,Z), e_cap(Y,Z,S))
                    =g=
                        S_DATA(S,'E_CAP_MIN')
                        ;

qspotecapmax(Y,C,S)..
                    sum(Z $ C_Z(C,Z), e_cap(Y,Z,S))
                    =l=
                        S_DATA(S,'E_CAP_MAX')
                        ;

qspotpccapmin(Y,C,S)..
                    sum(Z $ C_Z(C,Z), p_cap_c(Y,Z,S))
                    =g=
                        S_DATA(S,'P_C_CAP_MIN')
                        ;

qspotpccapmax(Y,C,S)..
                    sum(Z $ C_Z(C,Z), p_cap_c(Y,Z,S))
                    =l=
                        S_DATA(S,'P_C_CAP_MAX')
                        ;

qspotecapminres(Y,Z,S)..
                    e_cap(Y,Z,S)
                    =g=
                        CAP_INST_S(Y,Z,S,'E_CAP_MIN')
                        ;

qspotecapmaxres(Y,Z,S)..
                    e_cap(Y,Z,S)
                    =l=
                        CAP_INST_S(Y,Z,S,'E_CAP_MAX')
                        ;

qspotpcapminres(Y,Z,S)..
                    p_cap_c(Y,Z,S)
                    =g=
                        CAP_INST_S(Y,Z,S,'P_CAP_MIN')
                        ;

qspotpcapmaxres(Y,Z,S)..
                    p_cap_c(Y,Z,S)
                    =l=
                        CAP_INST_S(Y,Z,S,'P_CAP_MAX')
                        ;

#-------Short- and mid-term storage--------------------------------------------#

#--Energy constraints--#

qe(Y,P,Z,SSM)..
                    e(Y,P++1,Z,SSM)
                    =e=
                        e(Y,P,Z,SSM)
                        + W(P)*sum(T_E, p_c(Y,P,T_E,Z,SSM)*(S_DATA(SSM,'EFF_C')/100)*(TIMESTEP/4) - p_d(Y,P,T_E,Z,SSM)/(S_DATA(SSM,'EFF_D')/100)*(TIMESTEP/4))
                        ;

qemax(Y,P,Z,SSM)..
                    e(Y,P,Z,SSM)
                    =l=
                        e_cap(Y,Z,SSM)
                        #p_cap_c(Y,Z,SSM)*S_DATA(SSM,'DUR_MIN')
                        ;

qefstart(Y,P,T,Z,SSM)$(ord(T)=1)..
                    e_f(Y,P,T,Z,SSM)
                    =e=
                        e(Y,P,Z,SSM)
                        ;

qef(Y,P,T,Z,SSM)$(ord(T)<card(T))..
                    e_f(Y,P,T+1,Z,SSM)
                    =e=
                        e_f(Y,P,T,Z,SSM)
                        + p_c(Y,P,T,Z,SSM)*(S_DATA(SSM,'EFF_C')/100)*(TIMESTEP/4)
                        - p_d(Y,P,T,Z,SSM)/(S_DATA(SSM,'EFF_D')/100)*(TIMESTEP/4)
                        ;

qefmin(Y,P,T,Z,SSM)..
                    e_f(Y,P,T,Z,SSM)
                    =g=
                        1/(S_DATA(SSM,'EFF_D')/100)*
                        (p_d(Y,P,T,Z,SSM)*(TIMESTEP/4)
                        + sum(RU, res_s_d(Y,P,T,Z,RU,SSM)*T_R(RU)))
                        ;
qefmax(Y,P,T,Z,SSM)..
                    e_f(Y,P,T,Z,SSM)
                    =l=
                        e_cap(Y,Z,SSM) - (S_DATA(SSM,'EFF_C')/100)*
                        #p_cap_c(Y,Z,SSM)*S_DATA(SSM,'DUR_MIN') - (S_DATA(SSM,'EFF_C')/100)*
                        (p_c(Y,P,T,Z,SSM)*(TIMESTEP/4)
                        + sum(RD, res_s_c(Y,P,T,Z,RD,SSM)*T_R(RD)))
                        ;

qelstart(Y,P,T,Z,SSM)$(ord(T)=1)..
                    e_l(Y,P,T,Z,SSM)
                    =e=
                        e(Y,P,Z,SSM)
                        + (W(P)-1)*sum(T_E, p_c(Y,P,T_E,Z,SSM)*(S_DATA(SSM,'EFF_C')/100)*(TIMESTEP/4) - p_d(Y,P,T_E,Z,SSM)/(S_DATA(SSM,'EFF_D')/100)*(TIMESTEP/4))
                        ;

qel(Y,P,T,Z,SSM)$(ord(T)<card(T))..
                    e_l(Y,P,T+1,Z,SSM)
                    =e=
                        e_l(Y,P,T,Z,SSM)
                        + p_c(Y,P,T,Z,SSM)*(S_DATA(SSM,'EFF_C')/100)*(TIMESTEP/4)
                        - p_d(Y,P,T,Z,SSM)/(S_DATA(SSM,'EFF_D')/100)*(TIMESTEP/4)
                        ;

qelmin(Y,P,T,Z,SSM)..
                    e_l(Y,P,T,Z,SSM)
                    =g=
                        1/(S_DATA(SSM,'EFF_D')/100)*
                        (p_d(Y,P,T,Z,SSM)*(TIMESTEP/4)
                        + sum(RU, res_s_d(Y,P,T,Z,RU,SSM)*T_R(RU)))
                        ;
qelmax(Y,P,T,Z,SSM)..
                    e_l(Y,P,T,Z,SSM)
                    =l=
                        e_cap(Y,Z,SSM) - (S_DATA(SSM,'EFF_C')/100)*
                        #p_cap_c(Y,Z,SSM)*S_DATA(SSM,'DUR_MIN') - (S_DATA(SSM,'EFF_C')/100)*
                        (p_c(Y,P,T,Z,SSM)*(TIMESTEP/4)
                        + sum(RD, res_s_c(Y,P,T,Z,RD,SSM)*T_R(RD)))
                        ;

#--Duration limits--#

qdurmin(Y,Z,SSM)..
                    e_cap(Y,Z,SSM)
                    #p_cap_c(Y,Z,SSM)*S_DATA(SSM,'DUR_MIN')
                    =g=
                        p_cap_c(Y,Z,SSM)*S_DATA(SSM,'DUR_MIN')
                        ;

qdurmax(Y,Z,SSM)..
                    e_cap(Y,Z,SSM)
                    #p_cap_c(Y,Z,SSM)*S_DATA(SSM,'DUR_MIN')
                    =l=
                        p_cap_c(Y,Z,SSM)*S_DATA(SSM,'DUR_MAX')
                        ;

#-------Short-term storage-----------------------------------------------------#

#--Cycling cost--#

qsscemin(Y,C,SS)..
                    cyc_cost(Y,C,SS)
                    =g=
                        0
                        ;

qssccmin(Y,C,SS)..
                    cyc_cost(Y,C,SS)
                    =g=
                        sum(Z $ C_Z(C,Z),
                            (S_DATA(SS,'C_E_CYCL') - S_DATA(SS,'C_E_INV'))*1000*e_cap(Y,Z,SS)
                            + sum((P,T),
                                W(P)*(S_DATA(SS,'OPEX'))*(
                                p_c(Y,P,T,Z,SS)
                                + sum(RD, act_s_c(Y,P,T,Z,RD,SS))*2
                                )*(1/2)*(S_DATA(SS,'EFF_C')/100)*(TIMESTEP/4)
                                + W(P)*(S_DATA(SS,'OPEX'))*(
                                p_d(Y,P,T,Z,SS)
                                + sum(RU, act_s_d(Y,P,T,Z,RU,SS))*2
                                )*(1/2)/(S_DATA(SS,'EFF_D')/100)*(TIMESTEP/4)))
                        ;

#--Capacity constraint--#

qsscdmax(Y,P,T,Z,SS)..
                    p_c(Y,P,T,Z,SS)
                    + sum(RD, res_s_c(Y,P,T,Z,RD,SS))
                    + p_d(Y,P,T,Z,SS)
                    + sum(RU, res_s_d(Y,P,T,Z,RU,SS))
                    =l=
                        p_cap_c(Y,Z,SS)
                        ;

#--Charging constraints--#

qssc(Y,P,T,Z,SS)$(ord(T)<card(T))..
                    p_c(Y,P,T+1,Z,SS)
                    =e=
                        p_c(Y,P,T,Z,SS)
                        + ramp_c_up(Y,P,T,Z,SS)
                        - ramp_c_dn(Y,P,T,Z,SS)
                        ;

qsscru(Y,P,T,Z,SS)..
                    ramp_c_up(Y,P,T,Z,SS)
                    + sum(RD, res_s_c(Y,P,T,Z,RD,SS))
                    =l=
                        p_cap_c(Y,Z,SS)
                        - p_c(Y,P,T,Z,SS)
                        ;

qsscrd(Y,P,T,Z,SS)..
                    ramp_c_dn(Y,P,T,Z,SS)
                    + sum(RU, res_s_c(Y,P,T,Z,RU,SS))
                    =l=
                        p_c(Y,P,T,Z,SS)
                        ;

#--Discharging constraints--#

qssd(Y,P,T,Z,SS)$(ord(T)<card(T))..
                    p_d(Y,P,T+1,Z,SS)
                    =e=
                        p_d(Y,P,T,Z,SS)
                        + ramp_d_up(Y,P,T,Z,SS)
                        - ramp_d_dn(Y,P,T,Z,SS)
                        ;

qssdru(Y,P,T,Z,SS)..
                    ramp_d_up(Y,P,T,Z,SS)
                    + sum(RU, res_s_d(Y,P,T,Z,RU,SS))
                    =l=
                        p_cap_c(Y,Z,SS)
                        - p_d(Y,P,T,Z,SS)
                        ;

qssdrd(Y,P,T,Z,SS)..
                    ramp_d_dn(Y,P,T,Z,SS)
                    + sum(RD, res_s_d(Y,P,T,Z,RD,SS))
                    =l=
                        p_d(Y,P,T,Z,SS)
                        ;

#-------Mid and long-term storage----------------------------------------------#

#--Reserve allocation--#

qresscu(Y,P,T,Z,RU,SML)..
                    res_s_c(Y,P,T,Z,RU,SML)
                    =e=
                        res_s_c_s(Y,P,T,Z,RU,SML)
                        + res_s_c_sd(Y,P,T,Z,RU,SML)
                        ;

qresscd(Y,P,T,Z,RD,SML)..
                    res_s_c(Y,P,T,Z,RD,SML)
                    =e=
                        res_s_c_s(Y,P,T,Z,RD,SML)
                        + res_s_c_ns(Y,P,T,Z,RD,SML)
                        ;

qressdu(Y,P,T,Z,RU,SM)..
                    res_s_d(Y,P,T,Z,RU,SM)
                    =e=
                        res_s_d_s(Y,P,T,Z,RU,SM)
                        + res_s_d_ns(Y,P,T,Z,RU,SM)
                        ;

qressdd(Y,P,T,Z,RD,SM)..
                    res_s_d(Y,P,T,Z,RD,SM)
                    =e=
                        res_s_d_s(Y,P,T,Z,RD,SM)
                        + res_s_d_sd(Y,P,T,Z,RD,SM)
                        ;

#--Charging logical constraints--#

qnc(Y,P,T,Z,SML)$(ord(T)<card(T))..
                    n_c(Y,P,T+1,Z,SML)
                    =e=
                        n_c(Y,P,T,Z,SML)
                        + n_c_su(Y,P,T,Z,SML)
                        - n_c_sd(Y,P,T,Z,SML)
                        ;

qncmax(Y,P,T,Z,SML)..
                    n_c(Y,P,T,Z,SML)
                    =l=
                        p_cap_c(Y,Z,SML)/S_DATA(SML,'P_C_MAX')
                        ;

qncsu(Y,P,T,Z,SML)..
                    n_c_su(Y,P,T,Z,SML)
                    + sum(RD, n_c_su_r(Y,P,T,Z,RD,SML))
                    =l=
                        p_cap_c(Y,Z,SML)/S_DATA(SML,'P_C_MAX')
                        - n_c(Y,P,T,Z,SML)
                        ;

qncsd(Y,P,T,Z,SML)..
                    n_c_sd(Y,P,T,Z,SML)
                    + sum(RU, n_c_sd_r(Y,P,T,Z,RU,SML))
                    =l=
                        n_c(Y,P,T,Z,SML)
                        ;

#--Charging constraints--#

qsmlc(Y,P,T,Z,SML)$(ord(T)<card(T))..
                    p_c(Y,P,T+1,Z,SML)
                    =e=
                        p_c(Y,P,T,Z,SML)
                        + ramp_c_up(Y,P,T,Z,SML)
                        - ramp_c_dn(Y,P,T,Z,SML)
                        + ramp_c_su(Y,P,T,Z,SML)
                        - ramp_c_sd(Y,P,T,Z,SML)
                        ;

qsmlcmin(Y,P,T,Z,SML)..
                    p_c(Y,P,T,Z,SML)
                    =g=
                        n_c(Y,P,T,Z,SML)*S_DATA(SML,'P_C_MIN')
                        ;

qsmlcmax(Y,P,T,Z,SML)..
                    p_c(Y,P,T,Z,SML)
                    =l=
                        n_c(Y,P,T,Z,SML)*S_DATA(SML,'P_C_MAX')
                        ;

#--Charging ramping constraints--#

qcrudyn(Y,P,T,Z,SML)..
                    ramp_c_up(Y,P,T,Z,SML)
                    + sum(RD, res_s_c_s(Y,P,T,Z,RD,SML))
                    =l=
                        (n_c(Y,P,T,Z,SML)-n_c_sd(Y,P,T,Z,SML))*S_DATA(SML,'RCH')/100*S_DATA(SML,'P_C_MAX')
                        ;

qcrucap(Y,P,T,Z,SML)..
                    ramp_c_up(Y,P,T,Z,SML)
                    + sum(RD, res_s_c_s(Y,P,T,Z,RD,SML))
                    =l=
                        (n_c(Y,P,T,Z,SML)-n_c_sd(Y,P,T,Z,SML))*S_DATA(SML,'P_C_MAX')
                        - (p_c(Y,P,T,Z,SML)-ramp_c_sd(Y,P,T,Z,SML))
                        ;

qcrddyn(Y,P,T,Z,SML)..
                    ramp_c_dn(Y,P,T,Z,SML)
                    + sum(RU, res_s_c_s(Y,P,T,Z,RU,SML))
                    =l=
                        (n_c(Y,P,T,Z,SML)-n_c_sd(Y,P,T,Z,SML)-sum(RU, n_c_sd_r(Y,P,T,Z,RU,SML)))*S_DATA(SML,'RCH')/100*S_DATA(SML,'P_C_MAX')
                        ;

qcrdcap(Y,P,T,Z,SML)..
                    ramp_c_dn(Y,P,T,Z,SML)
                    + sum(RU, res_s_c_s(Y,P,T,Z,RU,SML))
                    =l=
                        (p_c(Y,P,T,Z,SML)-ramp_c_sd(Y,P,T,Z,SML)-sum(RU, res_s_c_sd(Y,P,T,Z,RU,SML)))
                        - (n_c(Y,P,T,Z,SML)-n_c_sd(Y,P,T,Z,SML)-sum(RU, n_c_sd_r(Y,P,T,Z,RU,SML)))*S_DATA(SML,'P_C_MIN')
                        ;

qcsumin(Y,P,T,Z,SML)..
                    ramp_c_su(Y,P,T,Z,SML)
                    =g=
                        n_c_su(Y,P,T,Z,SML)*S_DATA(SML,'P_C_MIN')
                        ;

qcsumax(Y,P,T,Z,SML)..
                    ramp_c_su(Y,P,T,Z,SML)
                    =l=
                        n_c_su(Y,P,T,Z,SML)*S_DATA(SML,'P_C_MIN')
                        + n_c_su(Y,P,T,Z,SML)*S_DATA(SML,'RCHNS')/100*S_DATA(SML,'P_C_MAX')
                        ;

qcsdmin(Y,P,T,Z,SML)..
                    ramp_c_sd(Y,P,T,Z,SML)
                    =g=
                        n_c_sd(Y,P,T,Z,SML)*S_DATA(SML,'P_C_MIN')
                        ;

qcsdmax(Y,P,T,Z,SML)..
                    ramp_c_sd(Y,P,T,Z,SML)
                    =l=
                        n_c_sd(Y,P,T,Z,SML)*S_DATA(SML,'P_C_MIN')
                        + n_c_sd(Y,P,T,Z,SML)*S_DATA(SML,'RCHNS')/100*S_DATA(SML,'P_C_MAX')
                        ;

#--Reserve allocation constraints--#

qcrufd(Y,P,T,Z,SML)..
                    sum(RDF, res_s_c_s(Y,P,T,Z,RDF,SML))
                    =l=
                        (n_c(Y,P,T,Z,SML)-n_c_sd(Y,P,T,Z,SML))*S_DATA(SML,'RCF')/100*S_DATA(SML,'P_C_MAX')
                        ;

qcruad(Y,P,T,Z,SML)..
                    sum(RDA, res_s_c_s(Y,P,T,Z,RDA,SML))
                    =l=
                        (n_c(Y,P,T,Z,SML)-n_c_sd(Y,P,T,Z,SML))*S_DATA(SML,'RCA')/100*S_DATA(SML,'P_C_MAX')
                        ;

qcrumd(Y,P,T,Z,SML)..
                    sum(RD, res_s_c_s(Y,P,T,Z,RD,SML))
                    =l=
                        (n_c(Y,P,T,Z,SML)-n_c_sd(Y,P,T,Z,SML))*S_DATA(SML,'RCM')/100*S_DATA(SML,'P_C_MAX')
                        ;

qcrdfu(Y,P,T,Z,SML)..
                    sum(RUF, res_s_c_s(Y,P,T,Z,RUF,SML))
                    =l=
                        (n_c(Y,P,T,Z,SML)-n_c_sd(Y,P,T,Z,SML)-sum(RU, n_c_sd_r(Y,P,T,Z,RU,SML)))*S_DATA(SML,'RCF')/100*S_DATA(SML,'P_C_MAX')
                        ;

qcrdau(Y,P,T,Z,SML)..
                    sum(RUA, res_s_c_s(Y,P,T,Z,RUA,SML))
                    =l=
                        (n_c(Y,P,T,Z,SML)-n_c_sd(Y,P,T,Z,SML)-sum(RU, n_c_sd_r(Y,P,T,Z,RU,SML)))*S_DATA(SML,'RCA')/100*S_DATA(SML,'P_C_MAX')
                        ;

qcrdmu(Y,P,T,Z,SML)..
                    sum(RU, res_s_c_s(Y,P,T,Z,RU,SML))
                    =l=
                        (n_c(Y,P,T,Z,SML)-n_c_sd(Y,P,T,Z,SML)-sum(RU, n_c_sd_r(Y,P,T,Z,RU,SML)))*S_DATA(SML,'RCM')/100*S_DATA(SML,'P_C_MAX')
                        ;

qcrunsmin(Y,P,T,Z,RD,SML)..
                    res_s_c_ns(Y,P,T,Z,RD,SML)
                    =g=
                        n_c_su_r(Y,P,T,Z,RD,SML)*S_DATA(SML,'P_C_MIN')
                        ;

qcrunsmax(Y,P,T,Z,RD,SML)..
                    res_s_c_ns(Y,P,T,Z,RD,SML)
                    =l=
                        n_c_su_r(Y,P,T,Z,RD,SML)*RSC(RD,SML)/100*S_DATA(SML,'P_C_MAX')
                        ;

qcrdsdmin(Y,P,T,Z,RU,SML)..
                    res_s_c_sd(Y,P,T,Z,RU,SML)
                    =g=
                        n_c_sd_r(Y,P,T,Z,RU,SML)*S_DATA(SML,'P_C_MIN')
                        ;

qcrdsdmax(Y,P,T,Z,RU,SML)..
                    res_s_c_sd(Y,P,T,Z,RU,SML)
                    =l=
                        n_c_sd_r(Y,P,T,Z,RU,SML)*RSC(RU,SML)/100*S_DATA(SML,'P_C_MAX')
                        ;

#-------Mid-term storage-------------------------------------------------------#

qcapdeqcapc(Y,Z,SM)..
                    p_cap_d(Y,Z,SM)
                    =e=
                        p_cap_c(Y,Z,SM)
                        ;

#--Discharging logical constraints--#

qnd(Y,P,T,Z,SM)$(ord(T)<card(T))..
                    n_d(Y,P,T+1,Z,SM)
                    =e=
                        n_d(Y,P,T,Z,SM)
                        + n_d_su(Y,P,T,Z,SM)
                        - n_d_sd(Y,P,T,Z,SM)
                        ;

qndmax(Y,P,T,Z,SM)..
                    n_d(Y,P,T,Z,SM)
                    =l=
                        p_cap_d(Y,Z,SM)/S_DATA(SM,'P_D_MAX')
                        ;

qndsu(Y,P,T,Z,SM)..
                    n_d_su(Y,P,T,Z,SM)
                    + sum(RU, n_d_su_r(Y,P,T,Z,RU,SM))
                    =l=
                        p_cap_d(Y,Z,SM)/S_DATA(SM,'P_D_MAX')
                        - n_d(Y,P,T,Z,SM)
                        ;

qndsd(Y,P,T,Z,SM)..
                    n_d_sd(Y,P,T,Z,SM)
                    + sum(RD, n_d_sd_r(Y,P,T,Z,RD,SM))
                    =l=
                        n_d(Y,P,T,Z,SM)
                        ;

#--Discharging constraints--#

qsmd(Y,P,T,Z,SM)$(ord(T)<card(T))..
                    p_d(Y,P,T+1,Z,SM)
                    =e=
                        p_d(Y,P,T,Z,SM)
                        + ramp_d_up(Y,P,T,Z,SM)
                        - ramp_d_dn(Y,P,T,Z,SM)
                        + ramp_d_su(Y,P,T,Z,SM)
                        - ramp_d_sd(Y,P,T,Z,SM)
                        ;

qsmdmin(Y,P,T,Z,SM)..
                    p_d(Y,P,T,Z,SM)
                    =g=
                        n_d(Y,P,T,Z,SM)*S_DATA(SM,'P_D_MIN')
                        ;

qsmdmax(Y,P,T,Z,SM)..
                    p_d(Y,P,T,Z,SM)
                    =l=
                        n_d(Y,P,T,Z,SM)*S_DATA(SM,'P_D_MAX')
                        ;

#--Discharging ramping constraints--#

qdrudyn(Y,P,T,Z,SM)..
                    ramp_d_up(Y,P,T,Z,SM)
                    + sum(RU, res_s_d_s(Y,P,T,Z,RU,SM))
                    =l=
                        (n_d(Y,P,T,Z,SM)-n_d_sd(Y,P,T,Z,SM))*S_DATA(SM,'RDH')/100*S_DATA(SM,'P_D_MAX')
                        ;

qdrucap(Y,P,T,Z,SM)..
                    ramp_d_up(Y,P,T,Z,SM)
                    + sum(RU, res_s_d_s(Y,P,T,Z,RU,SM))
                    =l=
                        (n_d(Y,P,T,Z,SM)-n_d_sd(Y,P,T,Z,SM))*S_DATA(SM,'P_D_MAX')
                        - (p_d(Y,P,T,Z,SM)-ramp_d_sd(Y,P,T,Z,SM))
                        ;

qdrddyn(Y,P,T,Z,SM)..
                    ramp_d_dn(Y,P,T,Z,SM)
                    + sum(RD, res_s_d_s(Y,P,T,Z,RD,SM))
                    =l=
                        (n_d(Y,P,T,Z,SM)-n_d_sd(Y,P,T,Z,SM)-sum(RD, n_d_sd_r(Y,P,T,Z,RD,SM)))*S_DATA(SM,'RDH')/100*S_DATA(SM,'P_D_MAX')
                        ;

qdrdcap(Y,P,T,Z,SM)..
                    ramp_d_dn(Y,P,T,Z,SM)
                    + sum(RD, res_s_d_s(Y,P,T,Z,RD,SM))
                    =l=
                        (p_d(Y,P,T,Z,SM)-ramp_d_sd(Y,P,T,Z,SM)-sum(RD, res_s_d_sd(Y,P,T,Z,RD,SM)))
                        - (n_d(Y,P,T,Z,SM)-n_d_sd(Y,P,T,Z,SM)-sum(RD, n_d_sd_r(Y,P,T,Z,RD,SM)))*S_DATA(SM,'P_D_MIN')
                        ;

qdsumin(Y,P,T,Z,SM)..
                    ramp_d_su(Y,P,T,Z,SM)
                    =g=
                        n_d_su(Y,P,T,Z,SM)*S_DATA(SM,'P_D_MIN')
                        ;

qdsumax(Y,P,T,Z,SM)..
                    ramp_d_su(Y,P,T,Z,SM)
                    =l=
                        n_d_su(Y,P,T,Z,SM)*S_DATA(SM,'P_D_MIN')
                        + n_d_su(Y,P,T,Z,SM)*S_DATA(SM,'RDHNS')/100*S_DATA(SM,'P_D_MAX')
                        ;

qdsdmin(Y,P,T,Z,SM)..
                    ramp_d_sd(Y,P,T,Z,SM)
                    =g=
                        n_d_sd(Y,P,T,Z,SM)*S_DATA(SM,'P_D_MIN')
                        ;

qdsdmax(Y,P,T,Z,SM)..
                    ramp_d_sd(Y,P,T,Z,SM)
                    =l=
                        n_d_sd(Y,P,T,Z,SM)*S_DATA(SM,'P_D_MIN')
                        + n_d_sd(Y,P,T,Z,SM)*S_DATA(SM,'RDHNS')/100*S_DATA(SM,'P_D_MAX')
                        ;

#--Reserve allocation constraints--#

qdrufu(Y,P,T,Z,SM)..
                    sum(RUF, res_s_d_s(Y,P,T,Z,RUF,SM))
                    =l=
                        (n_d(Y,P,T,Z,SM)-n_d_sd(Y,P,T,Z,SM))*S_DATA(SM,'RDF')/100*S_DATA(SM,'P_D_MAX')
                        ;

qdruau(Y,P,T,Z,SM)..
                    sum(RUA, res_s_d_s(Y,P,T,Z,RUA,SM))
                    =l=
                        (n_d(Y,P,T,Z,SM)-n_d_sd(Y,P,T,Z,SM))*S_DATA(SM,'RDA')/100*S_DATA(SM,'P_D_MAX')
                        ;

qdrumu(Y,P,T,Z,SM)..
                    sum(RU, res_s_d_s(Y,P,T,Z,RU,SM))
                    =l=
                        (n_d(Y,P,T,Z,SM)-n_d_sd(Y,P,T,Z,SM))*S_DATA(SM,'RDM')/100*S_DATA(SM,'P_D_MAX')
                        ;

qdrdfd(Y,P,T,Z,SM)..
                    sum(RDF, res_s_d_s(Y,P,T,Z,RDF,SM))
                    =l=
                        (n_d(Y,P,T,Z,SM)-n_d_sd(Y,P,T,Z,SM)-sum(RD, n_d_sd_r(Y,P,T,Z,RD,SM)))*S_DATA(SM,'RDA')/100*S_DATA(SM,'P_D_MAX')
                        ;

qdrdad(Y,P,T,Z,SM)..
                    sum(RDA, res_s_d_s(Y,P,T,Z,RDA,SM))
                    =l=
                        (n_d(Y,P,T,Z,SM)-n_d_sd(Y,P,T,Z,SM)-sum(RD, n_d_sd_r(Y,P,T,Z,RD,SM)))*S_DATA(SM,'RDA')/100*S_DATA(SM,'P_D_MAX')
                        ;

qdrdmd(Y,P,T,Z,SM)..
                    sum(RD, res_s_d_s(Y,P,T,Z,RD,SM))
                    =l=
                        (n_d(Y,P,T,Z,SM)-n_d_sd(Y,P,T,Z,SM)-sum(RD, n_d_sd_r(Y,P,T,Z,RD,SM)))*S_DATA(SM,'RDM')/100*S_DATA(SM,'P_D_MAX')
                        ;

qdrunsmin(Y,P,T,Z,RU,SM)..
                    res_s_d_ns(Y,P,T,Z,RU,SM)
                    =g=
                        n_d_su_r(Y,P,T,Z,RU,SM)*S_DATA(SM,'P_D_MIN')
                        ;

qdrunsmax(Y,P,T,Z,RU,SM)..
                    res_s_d_ns(Y,P,T,Z,RU,SM)
                    =l=
                        n_d_su_r(Y,P,T,Z,RU,SM)*RSD(RU,SM)/100*S_DATA(SM,'P_D_MAX')
                        ;

qdrdsdmin(Y,P,T,Z,RD,SM)..
                    res_s_d_sd(Y,P,T,Z,RD,SM)
                    =g=
                        n_d_sd_r(Y,P,T,Z,RD,SM)*S_DATA(SM,'P_D_MIN')
                        ;

qdrdsdmax(Y,P,T,Z,RD,SM)..
                    res_s_d_sd(Y,P,T,Z,RD,SM)
                    =l=
                        n_d_sd_r(Y,P,T,Z,RD,SM)*RSD(RD,SM)/100*S_DATA(SM,'P_D_MAX')
                        ;

#-------Long-term storage------------------------------------------------------#

#--Discharging reserve allocation--#

qslressd(Y,P,T,Z,R,SL)..
                    res_s_d(Y,P,T,Z,R,SL)
                    =e=
                        0
                        ;

#--Gas energy balance--#

qgase(Y,P,C)..
                    eg(Y,P++1,C)
                    =e=
                        eg(Y,P,C)
                        + W(P)*sum(T_E, pg_c(Y,P,T_E,C)*(TIMESTEP/4) - pg_d(Y,P,T_E,C)*(TIMESTEP/4))
                        ;

qgasemax(Y,P,C)..
                    eg(Y,P,C)
                    =l=
                        E_LP
#                        + eg_cap
                        ;

qgasef(Y,P,T,C)$(ord(T)<card(T))..
                    eg_f(Y,P,T+1,C)
                    =e=
                        eg_f(Y,P,T,C)
                        + pg_c(Y,P,T,C)*(TIMESTEP/4)
                        - pg_d(Y,P,T,C)*(TIMESTEP/4)
                        ;

qgasefmax(Y,P,T,C)..
                eg_f(Y,P,T,C)
                =l=
                    E_LP
#                    + eg_cap
                    ;

qgasefstart(Y,P,T,C)$(ord(T)=1)..
                eg_f(Y,P,T,C)
                =e=
                    eg(Y,P,C)
                    ;

qgasel(Y,P,T,C)$(ord(T)<card(T))..
                eg_l(Y,P,T+1,C)
                =e=
                    eg_l(Y,P,T,C)
                    + pg_c(Y,P,T,C)*(TIMESTEP/4)
                    - pg_d(Y,P,T,C)*(TIMESTEP/4)
                    ;

qgaselmax(Y,P,T,C)..
                eg_l(Y,P,T,C)
                =l=
                    E_LP
#                    + eg_cap
                    ;

qgaselstart(Y,P,T,C)$(ord(T)=1)..
                eg_l(Y,P,T,C)
                =e=
                    eg(Y,P,C)
                    + (W(P)-1)*sum(T_E, pg_c(Y,P,T_E,C)*(TIMESTEP/4) - pg_d(Y,P,T_E,C)*(TIMESTEP/4))
                    ;

#--Gas charging constraints--#

qgasc(Y,P,T,C)..
                pg_c(Y,P,T,C)
                =e=
                    sum(Z $ C_Z(C,Z), sum(SL, p_c(Y,P,T,Z,SL)*(S_DATA(SL,'EFF_C')/100)))
                    + pg_import(Y,P,T,C)
                    ;

#--Gas discharging constraints--#

qgasd(Y,P,T,C)..
                pg_d(Y,P,T,C)
                =e=
                    sum(Z $ C_Z(C,Z), sum(GCG, pg_syn(Y,P,T,Z,GCG) + pg_fos(Y,P,T,Z,GCG)))
                    ;

#--Gas usage--#

qgasuse(Y,C)..
                sum(Z $ C_Z(C,Z), sum((GCG,P,T), W(P)*pg_syn(Y,P,T,Z,GCG)))
                =l=
                    sum(Z $ C_Z(C,Z), sum((SL,P,T), W(P)*p_c(Y,P,T,Z,SL)*(S_DATA(SL,'EFF_C')/100)))
                    ;

qgasusegen(Y,P,T,Z,GCG)..
                gen(Y,P,T,Z,GCG)/(G_DATA(GCG,'EFF')/100)
                =e=
                        pg_syn(Y,P,T,Z,GCG)
                        + pg_fos(Y,P,T,Z,GCG)
                        ;

MODEL GOA GOA model /

#-------Objective function-----------------------------------------------------#
        qobj

#-------System constraints-----------------------------------------------------#
        qbalance

        qresprod
#        qco2lim

        qresa
        qreso
        qallg
        qalls
        qallgnot
        qallsnot
        qresallg
        qresalls

        #qgendisp
        #qgendisppeak

        qco2
        qlcg

#-------Generation technologies------------------------------------------------#
        qgcapmin
        qgcapmax
        qgcapminres
        qgcapmaxres
#        qggenmin
        qggenmax

#--Conventional generation technologies--#
        qresgcu
        qresgcd

        qn
        qnmax
        qnsu
        qnsd

        qgen
        qgenmin
        qgenmax

        qrudyn
        qrucap
        qrddyn
        qrdcap
        qsumin
        qsumax
        qsdmin
        qsdmax

        qrufu
        qruau
        qrumu
        qrdfd
        qrdad
        qrdmd
        qrunsmin
        qrunsmax
        qrdsdmin
        qrdsdmax

#--Intermittent renewable generation technologies--#
        qresgru

        qgenr

        qresgrdr
        qresgrdg

#-------Demand technologies------------------------------------------------#
#        qdrcapmin
#        qdrcapmax
#        qdrconsdnact
#        qdrconsmin
#        qdrfmax
#        qdrdpmax
#        qdrdtmax
#
#        qresdrcu
#        qresdrcd
#        qndr
#        qndrmax
#        qndrsu
#        qndrsd
#        qcons
#        qconsmin
#        qconsmax
#        qdrrudyn
#        qdrrucap
#        qdrrddyn
#        qdrrdcap
#        qdrsumin
#        qdrsumax
#        qdrsdmin
#        qdrsdmax
#        qdrruad
#        qdrrumds
#        qdrrdfu
#        qdrrdau
#        qdrrdmu
#        qdrrunsmin
#        qdrrunsmax
#        qdrrdsdmin
#        qdrrdsdmax

#-------Storage technologies---------------------------------------------------#
#--General constraints--#
        qress
        qspotecapmin
        qspotecapmax
        qspotpccapmin
        qspotpccapmax

        qspotecapminres
        qspotecapmaxres
        qspotpcapminres
        qspotpcapmaxres

        qe
        qemax
        qef
        qefmin
        qefmax
        qefstart
        qel
        qelmin
        qelmax
        qelstart

        qdurmin
        qdurmax

#--Short-term storage--#
        qsscemin
        qssccmin

        qsscdmax

        qssc
        qsscru
        qsscrd

        qssd
        qssdru
        qssdrd

#--Mid and long-term storage--#
        qresscu
        qresscd
        qressdd
        qressdu

        qnc
        qncmax
        qncsu
        qncsd

        qsmlc
        qsmlcmin
        qsmlcmax

        qcrudyn
        qcrucap
        qcrddyn
        qcrdcap
        qcsumin
        qcsumax
        qcsdmin
        qcsdmax

        qcrufd
        qcruad
        qcrumd
        qcrdfu
        qcrdau
        qcrdmu
        qcrunsmin
        qcrunsmax
        qcrdsdmin
        qcrdsdmax

#--Mid-term storage--#
        qcapdeqcapc

        qnd
        qndmax
        qndsu
        qndsd

        qsmd
        qsmdmin
        qsmdmax

        qdrudyn
        qdrucap
        qdrddyn
        qdrdcap
        qdsumin
        qdsumax
        qdsdmin
        qdsdmax

        qdrufu
        qdruau
        qdrumu
        qdrdfd
        qdrdad
        qdrdmd
        qdrunsmin
        qdrunsmax
        qdrdsdmin
        qdrdsdmax

#--Long-term storage--#
#        qslressd
#
#        qgase
#        qgasemax
#        qgasef
#        qgasefmax
#        qgasefstart
#        qgasel
#        qgaselmax
#        qgaselstart
#
#        qgasc
#
#        qgasd
#
#        qgasuse
#        qgasusegen

#-------Activation---------------------------------------------------------#
#--Reserve activations--#

#        qactu
#        qactd
#
#        qactglim
#        qactslimc
#        qactslimd

/;
option limrow = 200;
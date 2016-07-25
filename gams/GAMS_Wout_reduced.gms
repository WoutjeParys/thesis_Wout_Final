###################
#   Things that need to be added to GAMS file
###################

SETS
H           Time steps within period (clone of T)
;

$LOAD H


PARAMETERS

ELAST(P,T,H)           Elasticity relative to hour one and hour two (T & H)

DIAG(T,H)              a matrix to include the controlled hour
TRI_UP(T,H)            a matrix to include the eleven earlier hours
TRI_LOW(T,H)           a matrix to include the twelve later hours

P_REF                  reference price (calculated in advance)
TOTDEM                 The sum of the demand over all hours
LIMITPRICE             absolute value of price difference that is allowed
SHIFTMIN(H,T)          matrix to constraint shifting of energy inner window
SHIFTMAX(H,T)          matrix to constraint shifting of energy outer window
LENGTH_P               the length of the period as programmed in main and init (.py)

ELAST_NEW(P,T,H)       the new calculated elasticity matrix, taking into account the compensation factor
DEM_NON_RES(P,T,Z)     amount of non residential demand
ELAST_COMP(P,T,H)      compensation PEM
RATIO_H(P,H)           inbalance ratio
LINEARPEM(T,H)         compensation PEM linear
OWNELAST(T,H)          compensation PEM elast

# data from DR model
DEM_RES_MAX(P,T,Z)     max residential demand
DEM_RES_MIN(P,T,Z)     min residential demand
DEM_OPTIMAL(P,T,Z)     anchor point demand
PRICE_REF(P,H,Z)       anchor point price
DEM_RES_FP(P,T,Z)      prospected demand under flat price

# factor of reserve allocation flexible damand
FACTOR_RES_DR         factor that determines which part of the flexible band is used for system reserves

DR_CAP_PRICE          a fictive price for mobilised DR capacity
DR_EN_PRICE           a fictive price for mobilised DR energy
;

$LOAD ELAST
$LOAD DIAG
$LOAD TRI_UP TRI_LOW
$LOAD SHIFTMIN
$LOAD SHIFTMAX
$LOAD DEM_NON_RES
$LOAD RATIO_H
$LOAD LINEARPEM
$LOAD DEM_OPTIMAL DEM_RES_MIN DEM_RES_MAX DEM_RES_FP PRICE_REF

P_REF = 55.5;
TOTDEM = sum((P,T,Z),DEM_T(P,T,Z));
LIMITPRICE = 1.5;
LENGTH_P = card(T);
FACTOR_RES_DR = 0;

DR_CAP_PRICE = 0;
DR_EN_PRICE = 0;

############################
## CHANGE STARTING DEMAND CURVE (Only for case without DR, activated in Wout_program.py, no need to change here)
###############
#PRICE_REF(P,H,Z) = P_REF;
#DEM_OPTIMAL(P,T,Z) = DEM_RES_FP(P,T,Z);


#####
# 4 options for DR inclusion (compensation matrix (3) - moving time frames (1) )
####

## 1) flat compensation PEM
#RATIO_H(P,H) = (-sum((T,Z),DIAG(T,H)*ELAST(P,T,H)*DEM_OPTIMAL(P,T,Z))-sum((T,Z),(TRI_UP(T,H)+TRI_LOW(T,H))*ELAST(P,T,H)*DEM_OPTIMAL(P,T,Z))) /
#                (sum((T,Z),(TRI_LOW(T,H)+TRI_UP(T,H))*DEM_OPTIMAL(P,T,Z)));
#ELAST_COMP(P,T,H) = (TRI_LOW(T,H)+TRI_UP(T,H))*RATIO_H(P,H);

## 2) linear compensation PEM
#RATIO_H(P,H) = (-sum((T,Z),DIAG(T,H)*ELAST(P,T,H)*DEM_OPTIMAL(P,T,Z))-sum((T,Z),(TRI_UP(T,H)+TRI_LOW(T,H))*ELAST(P,T,H)*DEM_OPTIMAL(P,T,Z))) /
#                (sum((T,Z),(TRI_LOW(T,H)+TRI_UP(T,H))*LINEARPEM(T,H)*DEM_OPTIMAL(P,T,Z)));
#ELAST_COMP(P,T,H) = (LINEARPEM(T,H))*RATIO_H(P,H);

## 3) compensation PEM based on own-elasticities
OWNELASTPEM(P,T) = -sum(H,DIAG(T,H)*ELAST(P,T,H));
RATIO_H(P,H) = (-sum((T,Z),DIAG(T,H)*ELAST(P,T,H)*DEM_OPTIMAL(P,T,Z))-sum((T,Z),(TRI_UP(T,H)+TRI_LOW(T,H))*ELAST(P,T,H)*DEM_OPTIMAL(P,T,Z))) /
                (sum((T,Z),(TRI_LOW(T,H)+TRI_UP(T,H))*OWNELASTPEM(P,T)*DEM_OPTIMAL(P,T,Z)));
ELAST_COMP(P,T,H) = (TRI_LOW(T,H)+TRI_UP(T,H))*OWNELASTPEM(P,T)*RATIO_H(P,H);

## 4) Moving frames compensation PEM = 0
# Also need additional equations included in model, see bottom of this file!
#ELAST_COMP(P,T,H) = 0;

ELAST_NEW(P,T,H) = ELAST(P,T,H)+ELAST_COMP(P,T,H);


VARIABLES
price_unit(P,H,Z)                               Residential price signal for the electricity
price_unit_clone(P,T,Z)

genDR(P,T,Z)            shifted amount in each hour
capDR(Z)                max shifte amount of demand
costgDR(Z)              total cost for shifted demand based on energy (price in €/KWh)
costcDR(Z)              total cost for shifted demand based on capacity (price in €/KW)
;

POSITIVE VARIABLES
demand_new_res(P,T,Z)       Residential demand after price signal applied
demand_new_res_clone(P,H,Z)
demand_unit(P,T,Z)          demand of the electricity (sum residential & non-residential)
demand_unit_clone(P,H,Z)
demand_tot(P,Z)             sum of the demand, based on demand_unit(P,T,Z)
demand_ref(P,T,Z)           the reference demand with flat price
;

EQUATIONS

# elasticity equations to get new demand and corresponding price
demand(P,T,Z)
price_clone(P,T,Z)
demand_clone(P,H,Z)

# auxiliary equations for demand profiles
sum_demand(P,T,Z)
totdemand(P,Z)
refdemand(P,T,Z)

# keep residential demand between min-max boundaries
demand_max(P,T,Z)
demand_min(P,T,Z)

# reserve allocation
qresdrup(Y,P,T,Z)
qresdrdo(Y,P,T,Z)

# cost of DR
gdr(P,T,Z)
gdr2(P,T,Z)
cdr(P,T,Z)
cgdr(Z)
ccdr(Z)

# limit price deviation
priceconstraint1(P,H,Z)
priceconstraint2(P,H,Z)

# only include when working with moving time frames
shiftconstraint_frame_1(P,H,Z)
shiftconstraint_frame_2(P,H,Z)
totdemandmf(P,Z)
;


#-----######################---------------------------------------------------#
#-----# Objective function #---------------------------------------------------#
#-----######################---------------------------------------------------#
qobj..         obj
                =e=
                    sum((Y,Z,G),            (G_DATA(G,'C_INV') + G_DATA(G,'C_FOM'))*1000*cap(Y,Z,G))
                    + sum((Y,Z,SS),         (S_DATA(SS,'C_E_INV')*1000*e_cap(Y,Z,SS)))
                    + sum((Y,Z,SS),         (cyc_cost(Y,Z,SS)))
                    + sum((Y,Z,SM),         (S_DATA(SM,'C_E_INV')*1000)*e_cap(Y,Z,SM))
                    + sum((Y,Z,S),          (S_DATA(S,'C_P_C_INV')*1000)*p_cap_c(Y,Z,S))
                    + sum((Y,Z,SM),         (S_DATA(SM,'C_P_D_INV')*1000)*p_cap_d(Y,Z,SM))
                    + sum(Z,                DR_CAP_PRICE*1000*capDR(Z))
                    +
                    (sum((Y,P,T,Z,G),       W(P)*(G_DATA(G,'C_VOM'))*gen(Y,P,T,Z,G))
                    + sum((Y,P,T,Z,GC),     W(P)*(G_DATA(GC,'C_FUEL'))*gen(Y,P,T,Z,GC))
                    + sum((Y,P,T,Z,GRI),    W(P)*(0)*curt(Y,P,T,Z,GRI) + W(P)*(1000000)*curt_dummy(Y,P,T,Z,GRI))
                    + sum((Y,P,T,Z),        W(P)*(10000)*load_shedding(Y,P,T,Z))
                    + sum((P,T,Z),          W(P)*genDR(P,T,Z)*DR_EN_PRICE)
                    )
                    *(168/card(T));
                    ;


#-----######################---------------------------------------------------#
#-----# System constraints #---------------------------------------------------#
#-----######################---------------------------------------------------#

#--System balance--#

# balance with demand response
qbalance(Y,P,T,Z)..
                    sum(G, gen(Y,P,T,Z,G))
                    + sum(SSM, p_d(Y,P,T,Z,SSM))
                            =e=
                                    demand_unit(P,T,Z)
                                    - load_shedding(Y,P,T,Z)
                                    + sum(S, p_c(Y,P,T,Z,S))
                                    ;


#-----###################---------------------------------------------------#
#-----# Demand Response #---------------------------------------------------#
#-----###################---------------------------------------------------#

sum_demand(P,T,Z)..
                    demand_unit(P,T,Z) =e= DEM_NON_RES(P,T,Z) + demand_new_res(P,T,Z)
                    ;

totdemand(P,Z)..
                    demand_tot(P,Z) =e= sum(T,demand_new_res(P,T,Z) + DEM_NON_RES(P,T,Z))
                    ;

refdemand(P,T,Z)..
                    demand_ref(P,T,Z) =e= DEM_OPTIMAL(P,T,Z) + DEM_NON_RES(P,T,Z)
                    ;



##################################

demand(P,T,Z)..
                                        demand_new_res(P,T,Z) =e= DEM_OPTIMAL(P,T,Z) + sum(H,ELAST_NEW(P,T,H)*(DEM_OPTIMAL(P,T,Z)/PRICE_REF(P,H,Z))*(price_unit(P,H,Z)-PRICE_REF(P,H,Z)))
                                        ;

totdemandmf(P,Z)..
                                        sum(T,DEM_OPTIMAL(P,T,Z)) =l= sum(T,demand_new_res(P,T,Z))
                                        ;

##################################

gdr(P,T,Z)..
            genDR(P,T,Z) =g= DEM_RES_FP(P,T,Z)-demand_new_res(P,T,Z)
            ;

gdr2(P,T,Z)..
            genDR(P,T,Z) =g= 0
            ;

cdr(P,T,Z)..
            capDR(Z) =g= genDR(P,T,Z)
            ;

cgdr(Z)..
            costgDR(Z) =e= sum((T,P),genDR(P,T,Z)*W(P)*DR_EN_PRICE)
            ;

ccdr(Z)..
            costcDR(Z) =e= capDR(Z)*1000*DR_CAP_PRICE
            ;


# reserve allocation

qresdrup(Y,P,T,Z)..
                    sum(RU,res_DR(Y,P,T,Z,RU)) =l= (demand_new_res(P,T,Z) - DEM_RES_MIN(P,T,Z))*FACTOR_RES_DR
                    ;

qresdrdo(Y,P,T,Z)..
                    sum(RD,res_DR(Y,P,T,Z,RD)) =l= (DEM_RES_MAX(P,T,Z) - demand_new_res(P,T,Z))*FACTOR_RES_DR
                    ;

# residential consumption upper and lower limit

demand_max(P,T,Z)..
                    demand_new_res(P,T,Z) =l= DEM_RES_MAX(P,T,Z)
                    ;

demand_min(P,T,Z)..
                    demand_new_res(P,T,Z) =g= DEM_RES_MIN(P,T,Z)
                    ;

# auxilliary

demand_clone(P,H,Z)..
                    demand_new_res_clone(P,H,Z) =e= sum(T,demand_new_res(P,T,Z)*DIAG(T,H))
                    ;

price_clone(P,T,Z)..
                    price_unit_clone(P,T,Z) =e= sum(H,price_unit(P,H,Z)*DIAG(T,H))
                    ;

shiftconstraint_frame_1(P,H,Z)..
                    sum(T,DEM_OPTIMAL(P,T,Z)*SHIFTMIN(H,T)) =l= sum(T,demand_new_res(P,T,Z)*SHIFTMAX(H,T))
                    ;

shiftconstraint_frame_2(P,H,Z)..
                    sum(T,DEM_OPTIMAL(P,T,Z)*SHIFTMAX(H,T)) =g= sum(T,demand_new_res(P,T,Z)*SHIFTMIN(H,T))
                    ;

priceconstraint1(P,H,Z)..
                    price_unit(P,H,Z) =l= PRICE_REF(P,H,Z)+PRICE_REF(P,H,Z)*LIMITPRICE
                    ;

priceconstraint2(P,H,Z)..
                    price_unit(P,H,Z) =g= PRICE_REF(P,H,Z)-PRICE_REF(P,H,Z)*LIMITPRICE
                    ;


MODEL GOA GOA model /
#-- Demand response--#

        totdemand
        refdemand
        sum_demand

        demand
        price_clone
#        demand_clone

        #reserve allocation of flex demand
        qresdrup
        qresdrdo

        #keeps demand between boundaries
        demand_max
        demand_min

        # add cost for DR
        gdr
        gdr2
        cdr
        cgdr
        ccdr

        # limit price deviation from reference
        priceconstraint1
        priceconstraint2

       ##########
       # include when working with moving frames, and set in wout_program -> factor back to 1
#       shiftconstraint_frame_1
#       shiftconstraint_frame_2
#       totdemandmf



POL_TARGETS('RES_SHARE', '2050') = 40;
LIMITPRICE = 1.5;
FACTOR_RES_DR = 0;
SOLVE GOA using lp minimizing obj;
parameter marg(Y,P,T,Z) shadow prices of production;
marg(Y,P,T,Z) = qbalance.m(Y,P,T,Z)/W(P);

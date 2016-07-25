###################
#   Things that need to be added in main.py
###################

__author__ = 'Wout'

import gams
import os, sys
import sqlite3 as sq

length_period = 168

folder = 'gams'

file = '../gams/LinearModel_Wout_comp.gms'

# 1. Setup Gams Workspace
# ws = gams.GamsWorkspace(working_directory=os.getcwd(), debug=gams.DebugLevel.ShowLog)
print os.getcwd() + '\gams'
ws = gams.GamsWorkspace(working_directory=os.path.join(os.getcwd() , 'run'), debug=gams.DebugLevel.ShowLog)
# 2. Initialize Job
job = ws.add_job_from_file('%s' % file)
opt = ws.add_options()

db = ws.add_database()
cp = ws.add_checkpoint()

opt.defines["SupplyDataFileName"] = db.name
opt.threads = 0
# opt.defines["F"] = "12"

#===============================================================================
# 5. Define and add Sets, Parameters,...
H = db.add_set('H',1,'All hours')

############################################

for h in range(1,length_period+1):
    H.add_record('%d' % h)

############################################

conn = sq.connect('database/database.sqlite')
cur = conn.cursor()

#full elasticity matrix based on seasons of different periods
ELAST = db.add_parameter_dc('ELAST', [P,T,H], 'Elasticity relative to hour one and hour two')
#auxiliary matrices to compute with matrices in GAMS
DIAG = db.add_parameter_dc('DIAG', [T,H], 'Diagonal matrix with ones and zeros')
TRI_UP = db.add_parameter_dc('TRI_UP', [T,H], 'Upper triangle with ones and zeros')
TRI_LOW = db.add_parameter_dc('TRI_LOW', [T,H], 'Lower triangle with ones and zeros')
#time frames in moving time frame method
SHIFTMIN = db.add_parameter_dc('SHIFTMIN', [H,T], 'matrix to constraint shifting of energy inner window')
SHIFTMAX = db.add_parameter_dc('SHIFTMAX', [H,T], 'matrix to constraint shifting of energy outer window')

#non-residential demand profile (elia data)
DEM_NON_RES = db.add_parameter_dc('DEM_NON_RES', [P,T,Z], 'amount of non residential demand')

#auxiliary matrix for linear compensation matrix
LINEARPEM = db.add_parameter_dc('LINEARPEM', [T,H], 'compensation PEM linear')

#limits demand resposne
DEM_RES_MAX = db.add_parameter_dc('DEM_RES_MAX', [P,T,Z], 'max residential demand')
DEM_RES_MIN = db.add_parameter_dc('DEM_RES_MIN', [P,T,Z], 'min residential demand')
#reference demand profile out of DR model
DEM_OPTIMAL = db.add_parameter_dc('DEM_OPTIMAL', [P,T,Z], 'anchor point demand')
#reference price profile of DR model
PRICE_REF = db.add_parameter_dc('PRICE_REF', [P,H,Z], 'anchor point price')
#prospected demand profile under flat price
DEM_RES_FP = db.add_parameter_dc('DEM_RES_FP', [P,T,Z], 'prospected demand under flat price')


########################
#   set gdx database   #
########################

# needed to get right season for elasticities and demands
sql = 'Select First_hour,Season from Time_steps;'
cur.execute(sql)
periods = cur.fetchall()
print 'periods: ',periods

sql = 'Select Season, Hour1, Hour2, Price_Elasticity from Elasticity;'
cur.execute(sql)
elasticities = cur.fetchall()
count_per = 1
for per in periods:
    print 'season: ', per[1]
    for e in elasticities:
        if e[0] == per[1]:
            # print (str(count_per),str(e[1]), str(e[2])), e[3]
            ELAST.add_record((str(count_per),str(e[1]), str(e[2]))).value = e[3]
    count_per = count_per+1

###########################################

sql = 'Select Hour1, Hour2, Include_Value from C_Diagonal;'
cur.execute(sql)
diagonal = cur.fetchall()
for d in diagonal:
    DIAG.add_record((str(d[0]), str(d[1]))).value = d[2]

###########################################

sql = 'Select Hour1, Hour2, Include_Value from C_UpperT;'
cur.execute(sql)
triangleU = cur.fetchall()
for t in triangleU:
    TRI_UP.add_record((str(t[0]), str(t[1]))).value = t[2]

###########################################

sql = 'Select Hour1, Hour2, Include_Value from C_LowerT;'
cur.execute(sql)
triangleL = cur.fetchall()
for t in triangleL:
    TRI_LOW.add_record((str(t[0]), str(t[1]))).value = t[2]

############################################

sql = 'Select Hour1, Hour2, Inner_frame from Minframe;'
cur.execute(sql)
innerbooleans = cur.fetchall()
for e in innerbooleans:
    SHIFTMIN.add_record((str(e[0]), str(e[1]))).value = e[2]

############################################

sql = 'Select Hour1, Hour2, Outer_frame from Maxframe;'
cur.execute(sql)
outerbooleans = cur.fetchall()
for e in outerbooleans:
    SHIFTMAX.add_record((str(e[0]), str(e[1]))).value = e[2]

############################################

sql = 'Select First_hour from Time_steps;'
cur.execute(sql)
periods = cur.fetchall()
sql = 'Select Time, Zone, Demand from Demand_non_residential;'
cur.execute(sql)
profile = cur.fetchall()
for per in enumerate(periods, start=1):
    # print 'per: ',per
    # print per[0],per[1][0]
    for p in range(0,length_period):
        # print str(int(per[0])), str(p+1), str(profile[(int(per[1][0])-1 + p)*4][1]), profile[(int(per[1][0])-1 + p)*4][2]
        # print int(per[0]), int(per[1][0]), (int(per[1][0])-1 + p)*4, profile[(int(per[1][0])-1 + p)*4][2]
        DEM_NON_RES.add_record((str(int(per[0])), str(p+1), str(profile[(int(per[1][0])-1 + p)*4][1]))).value = profile[(int(per[1][0])-1 + p)*4][2]

############################################

sql = 'Select Hour1, Hour2, Include_Value from Linear;'
cur.execute(sql)
linearpems = cur.fetchall()
for l in linearpems:
    LINEARPEM.add_record((str(l[0]), str(l[1]))).value = l[2]


# the different demand profiles, limits and prices
sql = 'Select Season, Zone, Hour, Demand from Dem_ref_profile;'
cur.execute(sql)
demands = cur.fetchall()
count_per = 1
for per in periods:
    print 'season: ', per[1]
    for d in demands:
        if d[0] == per[1]:
            # print str(d[1]), str(count_per), str(d[2]), str(d[3])
            DEM_OPTIMAL.add_record((str(count_per), str(d[2]), str(d[1]))).value = d[3]
    count_per = count_per+1

sql = 'Select Season, Zone, Hour, Demand from Dem_min_profile;'
cur.execute(sql)
demands = cur.fetchall()
count_per = 1
for per in periods:
    print 'season: ', per[1]
    for d in demands:
        if d[0] == per[1]:
            # print (str(d[1]), str(count_per), str(d[2])), d[3]
            DEM_RES_MIN.add_record((str(count_per), str(d[2]), str(d[1]))).value = d[3]
    count_per = count_per+1

sql = 'Select Season, Zone, Hour, Demand from Dem_max_profile;'
cur.execute(sql)
demands = cur.fetchall()
count_per = 1
for per in periods:
    print 'season: ', per[1]
    for d in demands:
        if d[0] == per[1]:
            # print (str(d[1]), str(count_per), str(d[2])), d[3]
            DEM_RES_MAX.add_record((str(count_per), str(d[2]), str(d[1]))).value = d[3]
    count_per = count_per+1

sql = 'Select Season, Zone, Hour, Demand from Dem_flat_profile;'
cur.execute(sql)
demands = cur.fetchall()
count_per = 1
for per in periods:
    print 'season: ', per[1]
    for d in demands:
        if d[0] == per[1]:
            # print (str(d[1]), str(count_per), str(d[2])), d[3]
            DEM_RES_FP.add_record((str(count_per), str(d[2]), str(d[1]))).value = d[3]
    count_per = count_per+1

sql = 'Select Season, Zone, Hour, Price from PriceProfile;'
cur.execute(sql)
prices = cur.fetchall()
count_per = 1
for per in periods:
    print 'season: ', per[1]
    for d in prices:
        if d[0] == per[1]:
            # print (str(d[1]), str(count_per), str(d[2])), d[3]
            PRICE_REF.add_record((str(count_per), str(d[2]), str(d[1]))).value = d[3]
    count_per = count_per+1
###################
# Script to simulate different scenarios over the full range
#
#   scenario1: no demand response
#   scenario2: DR without incorporation of DR in system reserves
#   scenario3: DR with incorporation of DR in system reserves
#   scenario4: DR with limited incorporation of DR in system reserves
#       (only part of the band between min and max demand can be used for system reserves)
#
#   scenario5: a cost for demand response is included (for capacity as well energy)
#
#   scenario6: a different DR penetration rate is adopted
#
####################

__author__ = 'Wout'

import sqlite3 as sq
import xlrd
import os
import Wout_initialise
import Wout_main

#length period needs to be a multiple of 24
length_period = 24*1
#elasticities depend on weekday-weekendday, so startday weekend in period needs to be determined
startday_weekend = 2

#####
# DEFINE INPUT PARAMETERS FOR DIFFERENT SCENARIOS
#####

### SCENARIO 1
# list of renewable targets [%] for scenario 1
noDR_targets = []
### SCENARIO 2
# list of renewable targets [%] for scenario 2
DR_targets = [40]
### SCENARIO 3
# list of renewable targets [%] for scenario 3
DRres_targets = []

### SCENARIO 4
# list of renewable targets [%] for scenario 4
DRres0_x_targets = []
# determine the magnitude of the incorporation of DR in system reserves (fraction) ('0.1' = 10%)
bandwidth_4 = '0.1'
note_res0_x_4 = 'DRres0_1'

### SCENARIO 5
# list of relative costs [%] for scenario 5
DRcosts = [100]
# list of renewable targets [%] for scenario 5
DR_targets_5 = []
# base values for energy and capacity cost for DR
en_cost = 17.31*1
c_cost = 30.07*1
# determine the magnitude of the incorporation of DR in system reserves (fraction) ('0.1' = 10%)
bandwidth_5 = '0'

### SCENARIO 6
# list of penetration rates [%] for scenario 6
# only demand profiles for 25-50-75 % penetration are currently possible
DRrates = [50]
# list of renewable targets [%] for scenario 6
DR_targets_6 = []
# determine the magnitude of the incorporation of DR in system reserves (fraction) ('0.1' = 10%)
bandwidth_6 = '0.1'

# function to set demand profiles for different penetration rates
def set_demandprofiles(case):

    print os.getcwd()
    conn = sq.connect("database/database.sqlite")
    cur = conn.cursor()
    print os.getcwd()

    file = "excel\DemR\penetrationDR\DemAllProfiles0_" + str(case) + ".xlsx"

    book = xlrd.open_workbook(os.path.join(os.getcwd() , file))
    sqlref = 'DROP TABLE IF EXISTS Dem_ref_profile;'
    sqlmin = 'DROP TABLE IF EXISTS Dem_min_profile;'
    sqlmax = 'DROP TABLE IF EXISTS Dem_max_profile;'
    sqlflat = 'DROP TABLE IF EXISTS Dem_flat_profile;'
    cur.execute(sqlref)
    cur.execute(sqlmin)
    cur.execute(sqlflat)
    cur.execute(sqlmax)
    sqlref = 'CREATE TABLE IF NOT EXISTS Dem_ref_profile (Season FLOAT, Zone TEXT, Hour TEXT, Demand FLOAT);'
    sqlmin = 'CREATE TABLE IF NOT EXISTS Dem_min_profile (Season FLOAT, Zone TEXT, Hour TEXT, Demand FLOAT);'
    sqlmax = 'CREATE TABLE IF NOT EXISTS Dem_max_profile (Season FLOAT, Zone TEXT, Hour TEXT, Demand FLOAT);'
    sqlflat = 'CREATE TABLE IF NOT EXISTS Dem_flat_profile (Season FLOAT, Zone TEXT, Hour TEXT, Demand FLOAT);'
    cur.execute(sqlref)
    cur.execute(sqlmin)
    cur.execute(sqlmax)
    cur.execute(sqlflat)
    demref = list()
    demmin = list()
    demmax = list()
    demflp = list()
    zone = 'BEL_Z'
    shmin=book.sheet_by_index(0)
    shmax=book.sheet_by_index(1)
    shref=book.sheet_by_index(2)
    shflp=book.sheet_by_index(3)
    amount_of_days = length_period/24
    for season in range (0,4):
        print 'season: ', season
        for day in range(0,amount_of_days):
            if day == startday_weekend or day == startday_weekend+1:
                print 'weekendday with row = ', season*2+1
                row = season*2+2
            else:
                print 'weekday with sheet index = ', season*2
                row = season*2+1
            for col in range(1,shref.ncols):
                hour = int(shref.cell_value(0,col)) + 24*day
                valueref = shref.cell_value(row,col)
                valuemin = shmin.cell_value(row,col)
                valuemax = shmax.cell_value(row,col)
                valueflp = shflp.cell_value(row,col)
                demref.append((season+1,zone,hour,valueref))
                demmin.append((season+1,zone,hour,valuemin))
                demmax.append((season+1,zone,hour,valuemax))
                demflp.append((season+1,zone,hour,valueflp))
    cur.executemany('INSERT INTO Dem_ref_profile VALUES (?,?,?,?)', demref)
    cur.executemany('INSERT INTO Dem_min_profile VALUES (?,?,?,?)', demmin)
    cur.executemany('INSERT INTO Dem_max_profile VALUES (?,?,?,?)', demmax)
    cur.executemany('INSERT INTO Dem_flat_profile VALUES (?,?,?,?)', demflp)
    conn.commit()
    print 'Done price profiles'

# function to set elasticity for different penetration rates
def set_elasticity(case):
    print os.getcwd()
    conn = sq.connect("database/database.sqlite")
    cur = conn.cursor()
    print os.getcwd()

    file = "excel\DemR\penetrationDR\Elasticity0_" + str(case) + ".xlsx"

    book = xlrd.open_workbook(os.path.join(os.getcwd() , file))
    sql = 'DROP TABLE IF EXISTS Elasticity;'
    cur.execute(sql)
    sql = 'CREATE TABLE IF NOT EXISTS Elasticity (Season FLOAT, Hour1 TEXT, Hour2 TEXT, Price_Elasticity FLOAT);'
    cur.execute(sql)
    elasticity = list()
    # TODO
    # check how to handle elasticity, for now, only Hour1 - Hour2 and matrix 168-168
    # amount of days should be 7 to work with right elasticities weekday-weekend
    amount_of_days = length_period/24
    for season in range (0,4):
        print 'season: ', season
        print 'season: ', season
        for day in range(0,amount_of_days):
            if day == startday_weekend or day == startday_weekend+1:
                print 'in if, and index = ', season*2+1
                sh=book.sheet_by_index(season*2+1)
            else:
                print 'in else, and index = ', season*2
                sh=book.sheet_by_index(season*2)
            for row in range(3,sh.nrows):
                hour1 = int(sh.cell_value(row, 0)) + 24*day
                for col in range(1,sh.ncols):
                    if col < 13:
                        if row > 14 + col:
                            hour2 = int(sh.cell_value(2, col)) + 24*(day+1)
                        else:
                            hour2 = int(sh.cell_value(2, col)) + 24*(day)
                        if hour2 > length_period:
                            hour2 = hour2 - length_period
                    else:
                        if col > 11 + row-2:
                            hour2 = int(sh.cell_value(2, col)) + 24*(day-1)
                        else:
                            hour2 = int(sh.cell_value(2, col)) + 24*(day)
                        if hour2 < 1:
                            hour2 = hour2 + length_period
                    value = sh.cell_value(row,col)
                    elasticity.append((season+1,hour1,hour2,value))
    cur.executemany('INSERT INTO Elasticity VALUES (?,?,?,?)', elasticity)
    conn.commit()
    print 'Done elasticities'

Wout_initialise.initialise(length_period)


##############
# SCENARIO 1
##############

note = 'noDR'
string1 = 'PRICE_REF(P,H,Z) = P_REF;\n'
string2 = 'DEM_OPTIMAL(P,T,Z) = DEM_RES_FP(P,T,Z);\n'
string3 = 'LIMITPRICE = 0;\n'
string4 = 'FACTOR_RES_DR = 0;\n'
stringtot = string1+string2+string3+string4
for res_target_extern in noDR_targets:
    Wout_main.main(length_period,res_target_extern,note,stringtot)

print '-------------------------'
print 'NO DEMAND RESPONSE CASES ARE DONE!'
print '-------------------------'

##############
# SCENARIO 2
##############

note = 'DR'
string3 = 'LIMITPRICE = 1.5;\n'
string4 = 'FACTOR_RES_DR = 0;\n'
stringtot = string3+string4

for res_target_extern in DR_targets:
    Wout_main.main(length_period,res_target_extern,note,stringtot)

##############
# SCENARIO 3
##############
note = 'DRres'
string3 = 'LIMITPRICE = 1.5;\n'
string4 = 'FACTOR_RES_DR = 1;\n'
stringtot = string3+string4

for res_target_extern in DRres_targets:
    Wout_main.main(length_period,res_target_extern,note,stringtot)

##############
# SCENARIO 4
##############

note = note_res0_x_4
string3 = 'LIMITPRICE = 1.5;\n'
string4 = 'FACTOR_RES_DR = ' + bandwidth_4 + ';\n'
stringtot = string3+string4

for res_target_extern in DRres0_x_targets:
    Wout_main.main(length_period,res_target_extern,note,stringtot)


print '-------------------------'
print 'CASES WITH DEMAND RESPONSE ARE DONE!'
print '-------------------------'

##############
# SCENARIO 5
##############

for res_target_extern in DR_targets_5:
    for cost in DRcosts:
        note = 'cost_' + str(cost)
        string1 = 'DR_EN_PRICE = ' + str(en_cost*cost/100) + ';\n'
        string2 = 'DR_CAP_PRICE = ' + str(c_cost*cost/100) + ';\n'
        string3 = 'LIMITPRICE = 1.5;\n'
        string4 = 'FACTOR_RES_DR = '+ bandwidth_5 + ';\n'
        stringtot = string1+string2+string3+string4
        Wout_main.main(length_period,res_target_extern,note,stringtot)


print '-------------------------'
print 'SCENARIO 5 IS DONE!'
print '-------------------------'


##############
# SCENARIO 6
##############

for penetration in DRrates:
    set_demandprofiles(penetration)
    set_elasticity(penetration)
    note = 'DRpen_' + str(penetration)
    string3 = 'LIMITPRICE = 1.5;\n'
    string4 = 'FACTOR_RES_DR = ' + bandwidth_6 + ';\n'
    stringtot = string3+string4
    for res_target_extern in DR_targets_6:
        Wout_main.main(length_period,res_target_extern,note,stringtot)

print '-------------------------'
print 'SCENARIO 6 IS DONE!'
print '-------------------------'

print '-------------------------'
print 'AND WE ARE COMPLETELY FINISHED!'
print '-------------------------'

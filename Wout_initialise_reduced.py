###################
#   Things that need to be added to init_db_reduced
#       - Non-residential demand from excel file (Demand.xlsx - Profile_2015 - Elia data)
#       - Set price elasticity matrix based on the season of each period (Elasticity.xlsx)
#       - Auxiliary matrices: diagonal - lower triangle - upper triangle - linear profile (auxiliary/correction.xlsx)
#       - Create time frames for moving time frame method (magnitude and overlap is defined in code itself)
#       - Set reference price profile based on the season of each period (DemR/PriceProf.xlsx)
#       - Residential demand: reference and flat price demand profile & DR limits for each period
#               (DemR/DemAllProfilesFull.xlsx)
###################

__author__ = 'Wout'

import sqlite3 as sq
import csv
import xlrd
import os
from matplotlib import pyplot as plt
import openpyxl

# Need to define the location of the weekend inside a period due different profiles and elasticities
# for weekdays and weekend days
startday_weekend = 2
# length period needs to be a multiple of 24, because the 24 hour base of the elasticity matrix and demand profiles
length_period = 24*7

include = False
include_when_period_changed = True

geographical_entities = include
generation_technologies = include
storage_technologies = include
time_periods = include_when_period_changed
demand_ref = include
intermittent_renewables = include
reliable_intermittent = include
policy = include
installed_capacities = include
reserves_techn = include
fixed_tariffs = include
elasticity_matrix = include_when_period_changed
shiftingconstraints = include_when_period_changed
correction_matrix = include_when_period_changed
price_profiles = include_when_period_changed
demand_profiles = include_when_period_changed

print os.getcwd()
conn = sq.connect("database/database.sqlite")
cur = conn.cursor()
print os.getcwd()

if demand_ref:
    book = xlrd.open_workbook(os.path.join(os.getcwd() , "excel\Demand.xlsx"))
    sh = book.sheet_by_index(2)
    sql = 'DROP TABLE IF EXISTS Demand_non_residential;'
    cur.execute(sql)
    sql = 'CREATE TABLE IF NOT EXISTS Demand_non_residential (Zone TEXT, Time TEXT, Demand FLOAT);'
    cur.execute(sql)
    profile = list()
    #print zones
    zone = 'BEL_Z'
    col = 3
    for row in range(1, sh.nrows - 2):
        time = '%d' % row
        demand = sh.cell_value(row-1, col)
        # print hour, zone, demand
        profile.append((zone, time, demand))
    cur.executemany('INSERT INTO Demand_non_residential VALUES (?,?,?)', profile)
    conn.commit()

    ####

if elasticity_matrix:
    book = xlrd.open_workbook(os.path.join(os.getcwd() , "excel\Elasticity.xlsx"))
    sql = 'DROP TABLE IF EXISTS Elasticity;'
    cur.execute(sql)
    sql = 'CREATE TABLE IF NOT EXISTS Elasticity (Season FLOAT, Hour1 TEXT, Hour2 TEXT, Price_Elasticity FLOAT);'
    cur.execute(sql)
    elasticity = list()
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

if correction_matrix:
    book = xlrd.open_workbook(os.path.join(os.getcwd() , "excel/auxiliary/correction.xlsx"))
    #sheet 1 = "diagonal"
    sh = book.sheet_by_index(0)
    sql = 'DROP TABLE IF EXISTS C_Diagonal;'
    cur.execute(sql)
    sql = 'CREATE TABLE IF NOT EXISTS C_Diagonal (Hour1 TEXT, Hour2 TEXT, Include_Value FLOAT);'
    cur.execute(sql)
    include_value = list()
    amount_of_days = length_period/24
    for day in range(0,amount_of_days):
        for row in range(1,sh.nrows):
            hour1 = int(sh.cell_value(row, 0)) + 24*day
            for col in range(1,sh.ncols):
                if col < 13:
                    if row > 12 + col:
                        hour2 = int(sh.cell_value(0, col)) + 24*(day+1)
                    else:
                        hour2 = int(sh.cell_value(0, col)) + 24*(day)
                    if hour2 > length_period:
                        hour2 = hour2 - length_period
                else:
                    if col > 11 + row:
                        hour2 = int(sh.cell_value(0, col)) + 24*(day-1)
                        if hour2 < 1:
                            hour2 = hour2 + length_period
                    else:
                        hour2 = int(sh.cell_value(0, col)) + 24*(day)
                value = sh.cell_value(row,col)
                include_value.append((hour1,hour2,value))
    cur.executemany('INSERT INTO C_Diagonal VALUES (?,?,?)', include_value)
    conn.commit()
    print 'Done diagonal'

    #sheet 2 = "LowerT"
    sh = book.sheet_by_index(1)
    sql = 'DROP TABLE IF EXISTS C_LowerT;'
    cur.execute(sql)
    sql = 'CREATE TABLE IF NOT EXISTS C_LowerT (Hour1 TEXT, Hour2 TEXT, Include_Value FLOAT);'
    cur.execute(sql)
    include_value = list()
    amount_of_days = length_period/24
    for day in range(0,amount_of_days):
        for row in range(1,sh.nrows):
            hour1 = int(sh.cell_value(row, 0)) + 24*day
            for col in range(1,sh.ncols):
                if col < 13:
                    if row > 12 + col:
                        hour2 = int(sh.cell_value(0, col)) + 24*(day+1)
                    else:
                        hour2 = int(sh.cell_value(0, col)) + 24*(day)
                    if hour2 > length_period:
                        hour2 = hour2 - length_period
                else:
                    if col > 11 + row:
                        hour2 = int(sh.cell_value(0, col)) + 24*(day-1)
                        if hour2 < 1:
                            hour2 = hour2 + length_period
                    else:
                        hour2 = int(sh.cell_value(0, col)) + 24*(day)
                value = sh.cell_value(row,col)
                include_value.append((hour1,hour2,value))
    cur.executemany('INSERT INTO C_LowerT VALUES (?,?,?)', include_value)
    conn.commit()
    print 'Done LowerT'

    #sheet 3 = "UpperT"
    sh = book.sheet_by_index(2)
    sql = 'DROP TABLE IF EXISTS C_UpperT;'
    cur.execute(sql)
    sql = 'CREATE TABLE IF NOT EXISTS C_UpperT (Hour1 TEXT, Hour2 TEXT, Include_Value FLOAT);'
    cur.execute(sql)
    include_value = list()
    amount_of_days = length_period/24
    for day in range(0,amount_of_days):
        for row in range(1,sh.nrows):
            hour1 = int(sh.cell_value(row, 0)) + 24*day
            for col in range(1,sh.ncols):
                if col < 13:
                    if row > 12 + col:
                        hour2 = int(sh.cell_value(0, col)) + 24*(day+1)
                    else:
                        hour2 = int(sh.cell_value(0, col)) + 24*(day)
                    if hour2 > length_period:
                        hour2 = hour2 - length_period
                else:
                    if col > 11 + row:
                        hour2 = int(sh.cell_value(0, col)) + 24*(day-1)
                        if hour2 < 1:
                            hour2 = hour2 + length_period
                    else:
                        hour2 = int(sh.cell_value(0, col)) + 24*(day)
                value = sh.cell_value(row,col)
                include_value.append((hour1,hour2,value))
    cur.executemany('INSERT INTO C_UpperT VALUES (?,?,?)', include_value)
    conn.commit()
    print 'Done UpperT'

    #sheet 4 = "linear"
    sh = book.sheet_by_index(3)
    sql = 'DROP TABLE IF EXISTS Linear;'
    cur.execute(sql)
    sql = 'CREATE TABLE IF NOT EXISTS Linear (Hour1 TEXT, Hour2 TEXT, Include_Value FLOAT);'
    cur.execute(sql)
    include_value = list()
    amount_of_days = length_period/24
    for day in range(0,amount_of_days):
        for row in range(1,sh.nrows):
            hour1 = int(sh.cell_value(row, 0)) + 24*day
            for col in range(1,sh.ncols):
                if col < 13:
                    if row > 12 + col:
                        hour2 = int(sh.cell_value(0, col)) + 24*(day+1)
                    else:
                        hour2 = int(sh.cell_value(0, col)) + 24*(day)
                    if hour2 > length_period:
                        hour2 = hour2 - length_period
                else:
                    if col > 11 + row:
                        hour2 = int(sh.cell_value(0, col)) + 24*(day-1)
                        if hour2 < 1:
                            hour2 = hour2 + length_period
                    else:
                        hour2 = int(sh.cell_value(0, col)) + 24*(day)
                value = sh.cell_value(row,col)
                include_value.append((hour1,hour2,value))
    cur.executemany('INSERT INTO Linear VALUES (?,?,?)', include_value)
    conn.commit()
    print 'Done Linear'

    print 'Done correction matrices'

    #####

if shiftingconstraints:
    minframe = list()
    maxframe = list()
    #frame is amount in two directions from middlepunt that is handled
    frame = 10
    overlapbefore = 1
    overlapafter = 1
    amount_of_overlap_included = 0.5
    sql = 'DROP TABLE IF EXISTS Minframe;'
    cur.execute(sql)
    sql = 'CREATE TABLE IF NOT EXISTS Minframe (Hour1 TEXT, Hour2 TEXT, Inner_frame FLOAT);'
    cur.execute(sql)
    for i in range(1,length_period+1):
        for k in range(1-frame+(i-1),frame+1+i):
            if k<1:
                newk = length_period+k
            elif k>length_period:
                newk = k-length_period
            else:
                newk = k
            minframe.append((i,newk,1))
    sql = 'DROP TABLE IF EXISTS Maxframe;'
    cur.execute(sql)
    sql = 'CREATE TABLE IF NOT EXISTS Maxframe (Hour1 TEXT, Hour2 TEXT, Outer_frame FLOAT);'
    cur.execute(sql)
    for i in range(1,length_period+1):
        for k in range(1-frame-overlapbefore+(i-1),frame+1+overlapafter+i):
            if k<1:
                newk = length_period+k
            elif k>length_period:
                newk = k-length_period
            else:
                newk = k
            if k == frame+overlapafter+i or k == 1-frame-overlapbefore+(i-1):
                maxframe.append((i,newk,amount_of_overlap_included))
            else:
                maxframe.append((i,newk,1))
    print minframe
    print maxframe
    cur.executemany('INSERT INTO Minframe VALUES (?,?,?)', minframe)
    cur.executemany('INSERT INTO Maxframe VALUES (?,?,?)', maxframe)
    conn.commit()
    print 'Done shiftingconstraints'

if price_profiles:
    book = xlrd.open_workbook(os.path.join(os.getcwd() , "excel\DemR\PriceProf.xlsx"))
    sql = 'DROP TABLE IF EXISTS PriceProfile;'
    cur.execute(sql)
    sql = 'CREATE TABLE IF NOT EXISTS PriceProfile (Season FLOAT, Zone TEXT, Hour TEXT, Price FLOAT);'
    cur.execute(sql)
    prices = list()
    zone = 'BEL_Z'
    amount_of_days = length_period/24
    for season in range (0,4):
        print 'season: ', season
        for day in range(0,amount_of_days):
            if day == startday_weekend or day == startday_weekend+1:
                print 'weekendday with sheet index = ', season*2+1
                sh=book.sheet_by_index(season*2+1)
            else:
                print 'weekday with sheet index = ', season*2
                sh=book.sheet_by_index(season*2)
            for col in range(1,sh.ncols):
                hour = int(sh.cell_value(0,col)) + 24*day
                value = sh.cell_value(1,col)
                prices.append((season+1,zone,hour,value))
    cur.executemany('INSERT INTO PriceProfile VALUES (?,?,?,?)', prices)
    conn.commit()
    print 'Done price profiles'

if demand_profiles:
    book = xlrd.open_workbook(os.path.join(os.getcwd() , "excel\DemR\DemAllProfilesFull.xlsx"))
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
import QuantLib as ql
import numpy as np
import scipy.optimize as opt
import sys

# hard-coded calibrator for Heston model
def HestonModelCalibrator(valuationDate, calendar, spot, curveHandle, dividendHandle, 
    v0, kappa, theta, sigma, rho, expiration_dates, strikes, data, optimizer, bounds):
    
    # container for heston calibration helpers
    helpers = []
    
    # create Heston process, model and pricing engine
    # use given initial parameters for model
    process = ql.HestonProcess(curveHandle, dividendHandle, 
        ql.QuoteHandle(ql.SimpleQuote(spot)), v0, kappa, theta, sigma, rho)
    model = ql.HestonModel(process)
    engine = ql.AnalyticHestonEngine(model)
    
    # nested cost function for model optimization
    def CostFunction(x):
        parameters = ql.Array(list(x))        
        model.setParams(parameters)
        error = [helper.calibrationError() for helper in helpers]
        return np.sqrt(np.sum(np.abs(error)))

    # create Heston calibration helpers, set pricing engines
    for i in range(len(expiration_dates)):
        for j in range(len(strikes)):
            expiration = expiration_dates[i]
            days = expiration - valuationDate
            period = ql.Period(days, ql.Days)
            vol = data[i][j]
            strike = strikes[j]
            helper = ql.HestonModelHelper(period, calendar, spot, strike,
                ql.QuoteHandle(ql.SimpleQuote(vol)), curveHandle, dividendHandle)
            helper.setPricingEngine(engine)
            helpers.append(helper)
    
    # run optimization, return calibrated model and process
    optimizer(CostFunction, bounds)
    return process, model

# hard-coded generator for Heston process
def HestonPathGenerator(dates, dayCounter, process, nPaths):
    t = np.array([dayCounter.yearFraction(dates[0], d) for d in dates])
    nGridSteps = (t.shape[0] - 1) * 2
    sequenceGenerator = ql.UniformRandomSequenceGenerator(nGridSteps, ql.UniformRandomGenerator())
    gaussianSequenceGenerator = ql.GaussianRandomSequenceGenerator(sequenceGenerator)
    pathGenerator = ql.GaussianMultiPathGenerator(process, t, gaussianSequenceGenerator, False)
    paths = np.zeros(shape = (nPaths, t.shape[0]))
    
    for i in range(nPaths):
        multiPath = pathGenerator.next().value()
        paths[i,:] = np.array(list(multiPath[0]))
        
    # return array dimensions: [number of paths, number of items in t array]
    return paths

def AutoCallableNote(valuationDate, couponDates, strike, pastFixings, 
    autoCallBarrier, couponBarrier, protectionBarrier, hasMemory, finalRedemptionFormula, 
    coupon, notional, dayCounter, process, generator, nPaths, curve):    
    
    # immediate exit trigger for matured transaction
    if(valuationDate >= couponDates[-1]): return 0.0
    
    # immediate exit trigger for any past autocall event
    if(valuationDate >= couponDates[0]):
        if(max(pastFixings.values()) >= (autoCallBarrier * strike)): return 0.0

    # create date array for path generator
    # combine valuation date and all the remaining coupon dates
    dates = np.hstack((np.array([valuationDate]), couponDates[couponDates > valuationDate]))
    
    # generate paths for a given set of dates, exclude the current spot rate
    paths = generator(dates, dayCounter, process, nPaths)[:,1:]
    
    # identify the past coupon dates
    pastDates = couponDates[couponDates <= valuationDate]

    # conditionally, merge given past fixings from a given dictionary and generated paths
    if(pastDates.shape[0] > 0):
        pastFixingsArray = np.array([pastFixings[pastDate] for pastDate in pastDates])        
        pastFixingsArray = np.tile(pastFixingsArray, (paths.shape[0], 1))
        paths = np.hstack((pastFixingsArray, paths))
    
    # result accumulators
    global_pv = []
    expirationDate = couponDates[-1]
    hasMemory = int(hasMemory)
    
    # loop through all simulated paths
    for path in paths:
        payoffPV = 0.0
        unpaidCoupons = 0
        hasAutoCalled = False
        
        # loop through set of coupon dates and index ratios
        for date, index in zip(couponDates, (path / strike)):
            # if autocall event has been triggered, immediate exit from this path
            if(hasAutoCalled): break
            payoff = 0.0
                
            # payoff calculation at expiration
            if(date == expirationDate):
                # index is greater or equal to coupon barrier
                # pay 100% redemption, plus coupon, plus conditionally all unpaid coupons
                if(index >= couponBarrier):
                    payoff = notional * (1 + (coupon * (1 + unpaidCoupons * hasMemory)))
                # index is greater or equal to protection barrier and less than coupon barrier
                # pay 100% redemption, no coupon
                if((index >= protectionBarrier) & (index < couponBarrier)):
                    payoff = notional
                # index is less than protection barrier
                # pay redemption according to formula, no coupon
                if(index < protectionBarrier):
                    # note: calculate index value from index ratio
                    index = index * strike
                    payoff = notional * finalRedemptionFormula(index)
                
            # payoff calculation before expiration
            else:
                # index is greater or equal to autocall barrier
                # autocall will happen before expiration
                # pay 100% redemption, plus coupon, plus conditionally all unpaid coupons
                if(index >= autoCallBarrier):
                    payoff = notional * (1 + (coupon * (1 + unpaidCoupons * hasMemory)))
                    hasAutoCalled = True
                # index is greater or equal to coupon barrier and less than autocall barrier
                # autocall will not happen
                # pay coupon, plus conditionally all unpaid coupons
                if((index >= couponBarrier) & (index < autoCallBarrier)):
                    payoff = notional * (coupon * (1 + unpaidCoupons * hasMemory))
                    unpaidCoupons = 0
                # index is less than coupon barrier
                # autocall will not happen
                # no coupon payment, only accumulate unpaid coupons
                if(index < couponBarrier):
                    payoff = 0.0
                    unpaidCoupons += 1                    

            # conditionally, calculate PV for period payoff, add PV to local accumulator
            if(date > valuationDate):
                df = curveHandle.discount(date)
                payoffPV += payoff * df
            
        # add path PV to global accumulator
        global_pv.append(payoffPV)
        
    # return PV
    return np.mean(np.array(global_pv))

# general QuantLib-related parameters
valuationDate = ql.Date(20,11,2019)
ql.Settings.instance().evaluationDate = valuationDate
convention = ql.ModifiedFollowing
dayCounter = ql.Actual360()
calendar = ql.TARGET()

# Autocallable Memory Coupon Note
notional = float(sys.argv[1])
strike = float(sys.argv[2])
autoCallBarrier = float(sys.argv[3])

spot = 3550.0
couponBarrier = 0.8
protectionBarrier = 0.6
finalRedemptionFormula = lambda indexAtMaturity: min(1.0, indexAtMaturity / strike)
coupon = 0.05
hasMemory = True

# coupon schedule for note
startDate = ql.Date(20,11,2019)
firstCouponDate = calendar.advance(startDate, ql.Period(1, ql.Years))
lastCouponDate = calendar.advance(startDate, ql.Period(7, ql.Years))
couponDates = np.array(list(ql.Schedule(firstCouponDate, lastCouponDate, ql.Period(ql.Annual), 
    calendar, ql.ModifiedFollowing, ql.ModifiedFollowing, ql.DateGeneration.Forward, False)))

# create past fixings into dictionary
pastFixings = {}
#pastFixings = { ql.Date(20,11,2020): 99.0, ql.Date(22,11,2021): 99.0 }

# create discounting curve and dividend curve, required for Heston model
curveHandle = ql.YieldTermStructureHandle(ql.FlatForward(valuationDate, 0.01, dayCounter))
dividendHandle = ql.YieldTermStructureHandle(ql.FlatForward(valuationDate, 0.0, dayCounter))

# Eurostoxx 50 volatility surface data
expiration_dates = [ql.Date(19,6,2020), ql.Date(18,12,2020), 
    ql.Date(18,6,2021), ql.Date(17,12,2021), ql.Date(17,6,2022),
    ql.Date(16,12,2022), ql.Date(15,12,2023), ql.Date(20,12,2024), 
    ql.Date(19,12,2025), ql.Date(18,12,2026)]

strikes = [3075, 3200, 3350, 3550, 3775, 3950, 4050]

data = [[0.1753, 0.1631, 0.1493, 0.132 , 0.116 , 0.108 , 0.1052],
       [0.1683, 0.1583, 0.147 , 0.1334, 0.1212, 0.1145, 0.1117],
       [0.1673, 0.1597, 0.1517, 0.1428, 0.1346, 0.129 , 0.1262],
       [0.1659, 0.1601, 0.1541, 0.1474, 0.1417, 0.1381, 0.1363],
       [0.1678, 0.1634, 0.1588, 0.1537, 0.1493, 0.1467, 0.1455],
       [0.1678, 0.1644, 0.1609, 0.1572, 0.1541, 0.1522, 0.1513],
       [0.1694, 0.1666, 0.1638, 0.1608, 0.1584, 0.1569, 0.1562],
       [0.1701, 0.168 , 0.166 , 0.164 , 0.1623, 0.1614, 0.161 ],
       [0.1715, 0.1698, 0.1682, 0.1667, 0.1654, 0.1648, 0.1645],
       [0.1724, 0.171 , 0.1697, 0.1684, 0.1675, 0.1671, 0.1669]]

# initial parameters for Heston model
theta = 0.01
kappa = 0.01
sigma = 0.01
rho = 0.01
v0 = 0.01

# bounds for model parameters (1=theta, 2=kappa, 3=sigma, 4=rho, 5=v0)
bounds = [(0.01, 1.0), (0.01, 10.0), (0.01, 1.0), (-1.0, 1.0), (0.01, 1.0)]

# calibrate Heston model, print calibrated parameters
calibrationResult = HestonModelCalibrator(valuationDate, calendar, spot, curveHandle, dividendHandle, 
        v0, kappa, theta, sigma, rho, expiration_dates, strikes, data, opt.differential_evolution, bounds)
#print('calibrated Heston parameters', calibrationResult[1].params())

# monte carlo parameters
nPaths = 10000

# request and print PV
PV = AutoCallableNote(valuationDate, couponDates, strike, pastFixings, 
    autoCallBarrier, couponBarrier, protectionBarrier, hasMemory, finalRedemptionFormula, 
    coupon, notional, dayCounter, calibrationResult[0], HestonPathGenerator, nPaths, curveHandle)

print(PV)

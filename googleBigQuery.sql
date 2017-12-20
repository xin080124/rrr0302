SELECT w.ClaimWeek AS claimsWeek, Dist, CummDist, IF(c.actualClaimCount IS NULL, 0, c.actualClaimCount) as actualClaimCount, w.ExpectedFrequency AS expectedClaims,
  IF(c.actualClaimCost IS NULL, 0, c.actualClaimCost) as actualClaimCost
FROM [localcover-55:lc_api_dev.weekFailureDist] as w
LEFT OUTER JOIN 
(SELECT claimWeek, COUNT(ClaimWeek) AS actualClaimCount, SUM(actualClaimCost) as actualClaimCost
--   , COUNT(SalesWeek) as sales, SUM( premium_exGst ) as premium, failureRate 
  FROM [localcover-55:lc_api_dev.addClaimWeek]
  WHERE (SalesWeek = 61) && (ClaimWeek IS NOT NULL)
  GROUP BY ClaimWeek, failureRate
  ORDER BY ClaimWeek) AS c
ON 
  w.ClaimWeek = c.claimWeek
ORDER BY ClaimsWeek

SELECT SalesWeek, COUNT(SalesWeek) as sales, SUM( premium_exGst ) as totalPremium, failureRate, 93 as expectedClaims
  FROM [localcover-55:lc_api_dev.addClaimWeek]
  WHERE SalesWeek = 61 
  GROUP BY SalesWeek, failureRate
  
  SELECT claimsWeek, Dist, CummDist, expectedClaims, actualClaims, actualClaimRatio, if(preClaims is null, actualClaims, actualClaims - preClaims) AS claimRatioChange, 
  cumClaimExpected, cumClaimActual,
  if(cumClaimExpected = 0, 0, cumClaimActual/cumClaimExpected) as cummClaimRatio, 
  if(cumClaimExpected = 0, 0,cumClaimActual/cumClaimExpected) * 0.08 as cummFailureRate,  
  CummDist*31575 as premEarned, CummDist * 31575 * 0.7 as claimCummExpected, 
  if(actualClaims = 0, 0, actualClaimCost/actualClaims) as severityActual,  
  if(actualClaimRatio = 0, 0, actualClaimCost / (Dist * 31575 * 0.7 * actualClaimRatio) ) as severityRatio, claimsCummActual,
  if(CummDist = 0, 0, claimsCummActual/(CummDist*31575)) as LRActual
FROM (SELECT claimsWeek, Dist, CummDist, expectedClaims, actualClaimCount as actualClaims, actualClaimCount/expectedClaims AS actualClaimRatio, 
  LAG(actualClaimCount,1) OVER (ORDER BY claimsWeek) AS preClaims,
--   actualClaimCount/expectedClaims*0.08 as actualFailureRate,
  SUM(expectedClaims) OVER (ORDER BY claimsWeek) as cumClaimExpected,
  SUM(actualClaimCount) OVER (ORDER BY claimsWeek) as cumClaimActual,
  SUM(actualClaimCost) OVER (ORDER BY claimsWeek) as claimsCummActual,
  actualClaimCost
FROM [localcover-55:lc_api_dev.02ClaimDataByWeek]
ORDER BY claimsWeek)
GROUP BY claimsWeek, Dist, CummDist, expectedClaims, actualClaims, actualClaimRatio, claimRatioChange, cumClaimExpected, 
  cumClaimActual, cummClaimRatio, cummFailureRate, premEarned, claimCummExpected, severityActual, severityRatio, claimsCummActual, LRActual
ORDER BY claimsWeek

SELECT SalesWeek, Sales, Claims, PW1, PW2, PW3, PW4, PW5, 
  PW6, PW7, PW8, PW9, PW10, PW11, PW12, PW13, PW14, PW15, PW16, PW17, PW18, PW19, PW20, PW21, PW22, PW23, 
  PW24, PW25, PW26, PW27, PW28, PW29, PW30, PW31, PW32, PW33, PW34, PW35, PW36, PW37, PW38, PW39, PW40, PW41, 
  PW42, PW43, PW44, PW45, PW46, PW47, PW48, PW49, PW50, PW51, PW52
FROM withCumClaimsByWeek([localcover-55:ling.withClaimCountByWeek])
GROUP BY SalesWeek, Sales, Claims, PW1, PW2, PW3, PW4, PW5, 
  PW6, PW7, PW8, PW9, PW10, PW11, PW12, PW13, PW14, PW15, PW16, PW17, PW18, PW19, PW20, PW21, PW22, PW23, 
  PW24, PW25, PW26, PW27, PW28, PW29, PW30, PW31, PW32, PW33, PW34, PW35, PW36, PW37, PW38, PW39, PW40, PW41, 
  PW42, PW43, PW44, PW45, PW46, PW47, PW48, PW49, PW50, PW51, PW52
ORDER BY SalesWeek

const WEEKS = 52
const LOCALCOVER_EPOCH = new Date('2016-01-01T00:00:00Z');

function withClaimCountByWeek(row, emit) {
    const weeksToMilliSecConversionFactor = 7 * 24 * 60 * 60 * 1000;
    let claimCount = new Array(WEEKS).fill(0)
    let a = {}
    a['SalesWeek'] = row.SalesWeek
    a['Sales'] = row.Sales
    a['Claims'] = row.Claims
    for (let i = 1; i <= WEEKS; i++) {
      claimCount[i] = 0
      if (row.ClaimWeek && row.ClaimWeek === i) {
        claimCount[i] = row.Claims
        break
      }        
    }
    for (let i = 1; i <= WEEKS; i++){
      let m = 'W' + i
      a[m] = claimCount[i]
    }
    let weekNumberTimestamp = new Date(LOCALCOVER_EPOCH.getTime() + row.WeekNumber * weeksToMilliSecConversionFactor);

    emit(a)
}

function outputFields() {
    let outputFields = [
        { name: 'SalesWeek', type: 'integer' },
        { name: 'Sales', type: 'integer' },
        { name: 'Claims', type: 'integer' },
    ];
    for (let i = 1; i <= WEEKS; i++) {
        let m = { name: 'W' + i, type: 'integer' }
        outputFields.push(m);
    }
    return outputFields;
}

bigquery.defineFunction(
    'withClaimCountByWeek',
    [
        'SalesWeek',
        'Sales',
        'Claims',
        'ClaimWeek'
    ],

    outputFields(),

    withClaimCountByWeek
)

function inputCumFields() {
    let inputFields = [
        'SalesWeek',
        'Sales',
        'Claims',
    ];
    for (let i = 1; i <= WEEKS; i++) {
        inputFields.push('W' + i);
    }
    return inputFields;
}

function outputCumFields() {
    let outputFields = [
        { name: 'SalesWeek', type: 'integer' },
        { name: 'Sales', type: 'integer' },
        { name: 'Claims', type: 'integer' },
        { name: 'Frequency', type: 'float' },
    ];
    for (let i = 1; i <= WEEKS; i++) {
        let m = { name: 'W' + i, type: 'float' }
        outputFields.push(m)
    }
    for (let i = 1; i <= WEEKS; i++) {
        let m = { name: 'CW' + i, type: 'float' }
        outputFields.push(m)
    }
    for (let i = 1; i <= WEEKS; i++) {
        let m = { name: 'PW' + i, type: 'float' }
        outputFields.push(m)
    }
    return outputFields;
}

function withCumClaimsByWeek(row, emit) {
    let Frequency = row.Claims / row.Sales
    let sales = row.Sales
    let a = {}
    a['SalesWeek'] = row.SalesWeek
    a['Sales'] = row.Sales
    a['Claims'] = row.Claims
    a['Frequency'] = Frequency
    let claimCount = new Array(WEEKS).fill(0)
    let w = 'W'+1
    claimCount[1] = row[w]
    a[w] = claimCount[1]    
    for (let i = 2; i <= WEEKS; i++) {
        let w = 'W' + i
        a[w] = row[w]
        claimCount[i] = claimCount[i-1] + row[w]
    }
    for (let i = 1; i <= WEEKS; i++) {
        let cw = 'CW' + i
        let pw = 'PW' + i
        a[cw] = claimCount[i]
        a[pw] = claimCount[i]/sales
    }
    emit(a)
}

bigquery.defineFunction(
    'withCumClaimsByWeek',

    inputCumFields(),
    outputCumFields(),

    withCumClaimsByWeek
)

001getInitialAssocTable

SELECT s.PolicyId as PolicyId, s.SalesWeek as SalesWeek, Integer((SalesWeek + 1) / 52 + 1) as SalesYear, 
s.premium_exGst as Premium_exGst, c.ClaimId as ClaimId, 
  s.productClass as Class, s.productBrand as Brand, s.productModel as Model, c.claimCostexGST as ClaimCost,
  ((YEAR(ClaimDate) - YrPurchased)*12 + (MONTH(ClaimDate) - mthPurchased) ) AS MthClaim,
  WtyProductCode
FROM (SELECT PolicyId, SalesWeek, premium_exGst, productClass, productBrand, productModel, WtyProductCode, YrPurchased, mthPurchased
  FROM [localcover-55:ling.sales] 
  WHERE wtyTerm = 12) AS s
LEFT OUTER JOIN [localcover-55:ling.claims] AS c
ON s.PolicyId = c.PolicyId
ORDER BY SalesWeek

002expectedDataFromYear
SELECT SalesYear, Sales, Claims, Claims / Sales as FailureRate, TotalPremium, ClaimCost, ClaimCost / Claims as Severity, 
FROM (SELECT SalesYear, COUNT(DISTINCT PolicyId) / 52 as Sales, COUNT(DISTINCT ClaimId) / 52 AS Claims, 
    SUM(Premium_exGst ) / 52 as TotalPremium,
    SUM(ClaimCost) / 52 as ClaimCost
  FROM [localcover-55:lc_api_dev.001getInitialAssocTable]
  GROUP BY SalesYear
  ORDER BY SalesYear
  ) as t
ORDER BY salesYear

003withClaimsInMonth
SELECT SalesYear, Month0/Claims AS Month0, Month1/Claims AS Month1, Month2/Claims AS Month2, 
  Month3/Claims AS Month3, Month4/Claims AS Month4, Month5/Claims AS Month5, Month6/Claims AS Month6, 
  Month7/Claims AS Month7, Month8/Claims AS Month8, Month9/Claims AS Month9, Month10/Claims AS Month10, 
  Month11/Claims AS Month11, Month12/Claims AS Month12, 
FROM 

(SELECT SalesYear, sum(Claims) as Claims, sum(Month0) as Month0, sum(Month1) as Month1, sum(Month2) as Month2, 
     sum(Month3) as Month3, sum(Month4) as Month4, sum(Month5) as Month5, sum(Month6) as Month6,
     sum(Month7) as Month7, sum(Month8) as Month8, sum(Month9) as Month9, sum(Month10) as Month10, 
     sum(Month11) as Month11, sum(Month12) as Month12
  From withClaimCountByMonth
  (SELECT SalesYear,  COUNT(ClaimId) AS Claims,  MthClaim,
    FROM [localcover-55:lc_api_dev.001getInitialAssocTable]
    WHERE MthClaim IS NOT NULL
    GROUP BY SalesYear, MthClaim
    ORDER BY SalesYear, MthClaim) as s

	GROUP BY SalesYear
  ORDER BY SalesYear) AS t
ORDER BY SalesYear

const MONTHS = 12
const LOCALCOVER_EPOCH = new Date('2016-01-01T00:00:00Z');

function withClaimCountByMonth(row, emit) {
    let claimCount = new Array(MONTHS).fill(0)
    for (let i = 0; i <= MONTHS; i++) {
        claimCount[i] = 0
        if (row.mthClaim === i) {
            claimCount[i] = row.Claims
        }
    }
    emit({
        'SalesYear': row.SalesYear,
        'Claims': row.Claims,
        'Month0': claimCount[0],
        'Month1': claimCount[1],   
        'Month2': claimCount[2],
        'Month3': claimCount[3],   
        'Month4': claimCount[4],
        'Month5': claimCount[5],   
        'Month6': claimCount[6],
        'Month7': claimCount[7],   
        'Month8': claimCount[8],
        'Month9': claimCount[9],         
        'Month10': claimCount[10],
        'Month11': claimCount[11],  
        'Month12': claimCount[12],        
    });
}

function outputFields() {
    let outputFields = [
        {name: 'SalesYear', type: 'integer'},
        { name: 'Claims', type: 'integer' },
    ];
    for (let i = 0; i <= MONTHS; i++) {
        let m = {name: 'Month' + i, type: 'integer'}
        outputFields.push(m);
    }
    return outputFields;
}

bigquery.defineFunction(
    'withClaimCountByMonth',
    [
        'SalesYear',
        'Claims',
        'mthClaim'
    ],

    outputFields(),

    withClaimCountByMonth
)

function inputCumFields() {
    let inputFields = [
        'SalesYear',
        'Claims',
    ];
    for (let i = 0; i <= MONTHS; i++) {
      inputFields.push('Month' + i);
    }
    return inputFields;
}

function outputCumFields() {
    let outputFields = [
        {name: 'SalesYear', type: 'integer'},
        {name: 'Claims', type: 'integer'},
    ];
    for (let i = 0; i <= MONTHS; i++) {
        let m = {name: 'Month' + i, type: 'float'}
        outputFields.push(m);
    }
    return outputFields;
}

function withCumClaimsByMonth(row, emit){
    let Frequency = row.Claims / row.Sales
    let claimCount = new Array(MONTHS).fill(0)
    claimCount[0] = row.Month0
    claimCount[1] = claimCount[0] + row.Month1
    claimCount[2] = claimCount[1] + row.Month2
    claimCount[3] = claimCount[2] + row.Month3
    claimCount[4] = claimCount[3] + row.Month4
    claimCount[5] = claimCount[4] + row.Month5
    claimCount[6] = claimCount[5] + row.Month6
    claimCount[7] = claimCount[6] + row.Month7
    claimCount[8] = claimCount[7] + row.Month8
    claimCount[9] = claimCount[8] + row.Month9
    claimCount[10] = claimCount[9] + row.Month10
    claimCount[11] = claimCount[10] + row.Month11
    claimCount[12] = claimCount[11] + row.Month12
     
    emit({
        'SalesYear': row.SalesYear,
        'Claims': row.Claims,
        'Month0': claimCount[0]/sales,
        'Month1': claimCount[1]/sales,   
        'Month2': claimCount[2]/sales,
        'Month3': claimCount[3]/sales,   
        'Month4': claimCount[4]/sales,
        'Month5': claimCount[5]/sales,   
        'Month6': claimCount[6]/sales,
        'Month7': claimCount[7]/sales,   
        'Month8': claimCount[8]/sales,
        'Month9': claimCount[9]/sales,         
        'Month10': claimCount[10]/sales,
        'Month11': claimCount[11]/sales,  
        'Month12': claimCount[12]/sales,        
    })
}

bigquery.defineFunction(
    'withCumClaimsByMonth',

    inputCumFields(),    
    outputCumFields(),

    withCumClaimsByMonth
)

004expectedClaimData  
SELECT c.SalesYear as SalesYear, Sales, Claims,  FailureRate, TotalPremium, ClaimCost, Severity, Month0, Month1, Month2, Month3, Month4, Month5, Month6,
   Month7, Month8, Month9, Month10, Month11, Month12
FROM 
  [localcover-55:lc_api_dev.002expectedDataFromYear] AS c
JOIN 
  [localcover-55:lc_api_dev.003withClaimsInMonth] AS s
On
  c.SalesYear = s.SalesYear
ORDER BY 
  SalesYear
  
005withClaimsByWeek  
SELECT SalesWeek, Sales, Claims, Claims/Sales as actualFailureRate, 
Month0, Month1, Month2, Month3, Month4, Month5, Month6,
   Month7, Month8, Month9, Month10, Month11, Month12
FROM (SELECT SalesWeek, Sum(Sales) as Sales, sum(Claims) as Claims, sum(Month0) as Month0, sum(Month1) as Month1, sum(Month2) as Month2, 
   sum(Month3) as Month3, sum(Month4) as Month4, sum(Month5) as Month5, sum(Month6) as Month6,
   sum(Month7) as Month7, sum(Month8) as Month8, sum(Month9) as Month9, sum(Month10) as Month10, 
   sum(Month11) as Month11, sum(Month12) as Month12
   FROM  withClaimCountByMonth(SELECT SalesWeek, COUNT(DISTINCT PolicyId) AS Sales, 
   COUNT(DISTINCT ClaimId) AS Claims, mthClaim
     FROM [localcover-55:lc_api_dev.001getInitialAssocTable]
     GROUP BY SalesWeek, mthClaim
     ORDER BY SalesWeek, mthClaim) as s
   GROUP BY SalesWeek
   ORDER BY SalesWeek
   ) as t
GROUP BY SalesWeek, Sales, Claims, actualFailureRate, Month0, Month1, Month2, Month3, Month4, Month5, Month6,
   Month7, Month8, Month9, Month10, Month11, Month12    
ORDER BY SalesWeek

const MONTHS = 12
const LOCALCOVER_EPOCH = new Date('2016-01-01T00:00:00Z');

function withClaimCountByMonthExample(row, emit) {
    const weeksToMilliSecConversionFactor = 7 * 24 * 60 * 60 * 1000;
    let claimCount = new Array(MONTHS).fill(0)
    for (let i = 0; i <= MONTHS; i++) {
        claimCount[i] = 0
        if (row.mthClaim === i) {
            claimCount[i] = row.Claims
        }
    }
    emit({
        'SalesWeek': row.SalesWeek,
        'Sales': row.Sales,
        'Claims': row.Claims,
        'Month0': claimCount[0],
        'Month1': claimCount[1],   
        'Month2': claimCount[2],
        'Month3': claimCount[3],   
        'Month4': claimCount[4],
        'Month5': claimCount[5],   
        'Month6': claimCount[6],
        'Month7': claimCount[7],   
        'Month8': claimCount[8],
        'Month9': claimCount[9],         
        'Month10': claimCount[10],
        'Month11': claimCount[11],  
        'Month12': claimCount[12],        
    });
}

function outputFields() {
    let outputFields = [
        {name: 'SalesWeek', type: 'integer'},
        {name: 'Sales', type: 'integer'},
        { name: 'Claims', type: 'integer' },
    ];
    for (let i = 0; i <= MONTHS; i++) {
        let m = {name: 'Month' + i, type: 'integer'}
        outputFields.push(m);
    }
    return outputFields;
}

bigquery.defineFunction(
    'withClaimCountByMonth',
    [
        'SalesWeek',
        'Sales',
        'Claims',
        'mthClaim'
    ],

    outputFields(),

    withClaimCountByMonthExample
)

show_002expectedDataFrom2015

SELECT YrSales, Sales, Claims, Claims / Sales as FailureRate, Premium, ClaimCost, ClaimCost / Claims as Severity, 
FROM (SELECT YrSales, COUNT(DISTINCT PolicyId) as Sales, COUNT(DISTINCT ClaimId) AS Claims, 
    SUM(Premium_exGst) as Premium,
    SUM(ClaimCost) as ClaimCost
  FROM [localcover-55:lc_api_show.001InitialAssocTable]
  WHERE YrSales = 2015
  GROUP BY YrSales
  ORDER BY YrSales) as t

show_ 003withExpectedFailureRate

SELECT YrSales, Month0, Month1, Month2, Month3, Month4, Month5, Month6,
   Month7, Month8, Month9, Month10, Month11, Month12
FROM (SELECT YrSales, sum(Month0) as Month0, sum(Month1) as Month1, sum(Month2) as Month2, 
     sum(Month3) as Month3, sum(Month4) as Month4, sum(Month5) as Month5, sum(Month6) as Month6,
     sum(Month7) as Month7, sum(Month8) as Month8, sum(Month9) as Month9, sum(Month10) as Month10, 
     sum(Month11) as Month11, sum(Month12) as Month12
	 
  From withClaimCountByMonth(
  
  SELECT YrSales, COUNT(DISTINCT ClaimId) AS Claims,  MthClaim,
    FROM [localcover-55:lc_api_show.001InitialAssocTable] 
    WHERE YrSales=2015 AND MthClaim IS NOT NULL 
    GROUP BY YrSales, MthClaim
    ORDER BY YrSales, MthClaim
	
	) as s
  
  GROUP BY YrSales
  ORDER BY YrSales) AS t
ORDER BY YrSales

const MONTHS = 12
const LOCALCOVER_EPOCH = new Date('2016-01-01T00:00:00Z');

function withClaimCountByMonth(row, emit) {
    let claimCount = new Array(MONTHS).fill(0)
    for (let i = 0; i <= MONTHS; i++) {
        claimCount[i] = 0
        if (row.mthClaim === i) {
            claimCount[i] = row.Claims
        }
    }
    emit({
        'YrSales': row.YrSales,
        'Claims': row.Claims,
        'Month0': claimCount[0],
        'Month1': claimCount[1],   
        'Month2': claimCount[2],
        'Month3': claimCount[3],   
        'Month4': claimCount[4],
        'Month5': claimCount[5],   
        'Month6': claimCount[6],
        'Month7': claimCount[7],   
        'Month8': claimCount[8],
        'Month9': claimCount[9],         
        'Month10': claimCount[10],
        'Month11': claimCount[11],  
        'Month12': claimCount[12],        
    });
}

function outputFields() {
    let outputFields = [
        {name: 'YrSales', type: 'integer'},
        { name: 'Claims', type: 'integer' },
    ];
    for (let i = 0; i <= MONTHS; i++) {
        let m = {name: 'Month' + i, type: 'integer'}
        outputFields.push(m);
    }
    return outputFields;
}

bigquery.defineFunction(
    'withClaimCountByMonth',
    [
        'YrSales',
        'Claims',
        'mthClaim'
    ],

    outputFields(),

    withClaimCountByMonth
)

show_004expectedClaimData

SELECT c.YrSales + 1 as YrSales, Sales/12 as AvgSales, Claims/12 as AvgClaims, FailureRate as AvgFailureRate,
   Premium/12 as AvgPremium, ClaimCost/12 AvgClaimCost, Severity as AvgSeverity, 
   Month0/Sales as Month0, Month1/Sales as Month1, Month2/Sales as Month2, Month3/Sales as Month3, Month4/Sales as Month4, 
   Month5/Sales as Month5, Month6/Sales as Month6, Month7/Sales as Month7, Month8/Sales as Month8,
   Month9/Sales as Month9, Month10/Sales as Month10, Month11/Sales as Month11, Month12/Sales as Month12,
FROM 
  [localcover-55:lc_api_show.002expectedDataFrom2015] AS c
JOIN 
  [localcover-55:lc_api_show.003withExpectedFailureRate] AS s
On
  c.YrSales = s.YrSales
ORDER BY 
  YrSales







SELECT e05.salesWeek as sw, e05.LastSalesYear as lastyear,e05.Sales,  e05.Claims as c, 
e05.actualFailureRate as actFailureRate,  
b2.FailureRate as exfailureRate, e05.Month0 as m0, e05.Month1 as m1, e05.Month2 as m2, 
   e05.Month3 as m3, e05.Month4 as m4, e05.Month5 as m5, 
   e05.Month6, e05.Month7, e05.Month8, 
   e05.Month9, e05.Month10, 

FROM
(
SELECT Integer((e5.SalesWeek + 1) / 52) as LastSalesYear, 
e5.Sales, e5.salesWeek, e5.Claims, e5.actualFailureRate,  
   e5.Month0, e5.Month1, e5.Month2, 
   e5.Month3, e5.Month4, e5.Month5, 
   e5.Month6, e5.Month7, e5.Month8, 
   e5.Month9, e5.Month10, 
   e5.Month11, e5.Month12
   //FROM [localcover-55:yixin.x001_allSales] as a01,
   FROM [localcover-55:yixin.x005_saleWeeklyClaimMonthly]  as g7
)e05
   LEFT OUTER JOIN 
   [localcover-55:yixin.x002_yearExpected] as b2
   ON e05.LastSalesYear = b2.SalesYear
   //WHERE salesWeek = a01.SalesWeek
   ORDER BY sw

x001_allsales

   SELECT s.PolicyId as PolicyId, s.SalesWeek as SalesWeek, s.mthPurchased as SalesMonth, Integer((SalesWeek + 1) / 52 + 1) as SalesYear, 
s.premium_exGst as Premium_exGst, c.ClaimId as ClaimId, 
  s.productClass as Class, s.productBrand as Brand, s.productModel as Model, c.claimCostexGST as ClaimCost,
  ((YEAR(ClaimDate) - YrPurchased)*12 + (MONTH(ClaimDate) - mthPurchased) ) AS MthClaim,
  WtyProductCode
FROM (SELECT PolicyId, SalesWeek, premium_exGst, productClass, productBrand, productModel, WtyProductCode, YrPurchased, mthPurchased
  FROM [localcover-55:ling.sales] 
  WHERE wtyTerm = 12) AS s
LEFT OUTER JOIN [localcover-55:ling.claims] AS c
ON s.PolicyId = c.PolicyId
ORDER BY SalesWeek


show_001InitialAssocTable  
SELECT s.PolicyId as PolicyId, YrPurchased as YrSales, mthPurchased as MthSales, s.premium_exGst as Premium_exGst, c.ClaimId as ClaimId, 
  s.productClass as Class, s.productBrand as Brand, s.productModel as Model, c.claimCostexGST as ClaimCost,
  ((YEAR(ClaimDate) - YrPurchased)*12 + (MONTH(ClaimDate) - mthPurchased) ) AS MthClaim,
  WtyProductCode
FROM (
SELECT PolicyId, SalesWeek, premium_exGst, productClass, productBrand, productModel, WtyProductCode, YrPurchased, mthPurchased
  FROM [localcover-55:ling.sales] 
  WHERE wtyTerm = 12
  ) AS s
LEFT OUTER JOIN [localcover-55:ling.claims] AS c
ON s.PolicyId = c.PolicyId
ORDER BY SalesWeek


show_002expectedDataFrom2015
SELECT YrSales, AvgSales, AvgClaims, AvgClaims / AvgSales as AvgFailureRate, 
AvgPremium, AvgClaimCost, AvgClaimCost / AvgClaims as AvgSeverity, 

FROM (SELECT YrSales,  COUNT(DISTINCT PolicyId)/12 as AvgSales, 
COUNT(DISTINCT ClaimId)/12 AS AvgClaims, 
    SUM(Premium_exGst)/12  as AvgPremium,
    SUM(ClaimCost)/12  as AvgClaimCost
  FROM [localcover-55:lc_api_show.001InitialAssocTable]

  WHERE YrSales = 2015
  GROUP BY YrSales
  ORDER BY YrSales) as t

show_ 003withExpectedFailureRate
SELECT YrSales, Month0/Claims AS Month0, Month1/Claims AS Month1, Month2/Claims AS Month2, 
  Month3/Claims AS Month3, Month4/Claims AS Month4, Month5/Claims AS Month5, Month6/Claims AS Month6, 
  Month7/Claims AS Month7, Month8/Claims AS Month8, Month9/Claims AS Month9, Month10/Claims AS Month10, 
  Month11/Claims AS Month11, Month12/Claims AS Month12, 
FROM (SELECT YrSales, sum(Claims) as Claims, sum(Month0) as Month0, sum(Month1) as Month1, sum(Month2) as Month2, 
     sum(Month3) as Month3, sum(Month4) as Month4, sum(Month5) as Month5, sum(Month6) as Month6,
     sum(Month7) as Month7, sum(Month8) as Month8, sum(Month9) as Month9, sum(Month10) as Month10, 
     sum(Month11) as Month11, sum(Month12) as Month12
  From withClaimCountByMonth(SELECT YrSales, COUNT(DISTINCT ClaimId) AS Claims,  MthClaim,
    FROM [localcover-55:lc_api_show.001InitialAssocTable] 
    WHERE YrSales=2015 AND MthClaim IS NOT NULL 
    GROUP BY YrSales, MthClaim
    ORDER BY YrSales, MthClaim) as s
  GROUP BY YrSales
  ORDER BY YrSales) AS t
ORDER BY YrSales

show_005ClaimDataForMonth1  
SELECT MthSales, Sales, Claims, Claims/Sales as actualFailureRate, Month0
FROM (

SELECT MthSales, Sum(Sales) as Sales, sum(Claims) as Claims, sum(Month0) as Month0
   FROM  withClaimCountByMonth(SELECT MthSales, COUNT(DISTINCT PolicyId) AS Sales, COUNT(DISTINCT ClaimId) AS Claims, MthClaim
     FROM [localcover-55:lc_api_show.001InitialAssocTable]
     WHERE YrSales = 2016 AND MthSales <= 1
     GROUP BY MthSales, MthClaim
     ORDER BY MthSales, MthClaim) as s
	 
   GROUP BY MthSales
   ORDER BY MthSales
   ) as t
   
GROUP BY MthSales, Sales, Claims, actualFailureRate, Month0
ORDER BY MthSales

const MONTHS = 1
const LOCALCOVER_EPOCH = new Date('2016-01-01T00:00:00Z');

function withClaimCountByMonth(row, emit) {
    let claimCount = new Array(MONTHS).fill(0)
    for (let i = 0; i <= MONTHS; i++) {
        claimCount[i] = 0
        if (row.MthClaim === i) {
            claimCount[i] = row.Claims
        }
    }
    emit({
        'MthSales': row.MthSales,
        'Sales': row.Sales,
        'Claims': row.Claims,
        'Month0': claimCount[0],
        'Month1': claimCount[1],   
        'Month2': claimCount[2],
        'Month3': claimCount[3],   
        'Month4': claimCount[4],
        'Month5': claimCount[5],   
        'Month6': claimCount[6],
        'Month7': claimCount[7],   
        'Month8': claimCount[8],
        'Month9': claimCount[9],         
        'Month10': claimCount[10],
        'Month11': claimCount[11],  
        'Month12': claimCount[12],        
    });
}

function outputFields() {
    let outputFields = [
        {name: 'MthSales', type: 'integer'},
        {name: 'Sales', type: 'integer'},
        {name: 'Claims', type: 'integer' },
    ];
    for (let i = 0; i <= MONTHS; i++) {
        let m = {name: 'Month' + i, type: 'integer'}
        outputFields.push(m);
    }
    return outputFields;
}

bigquery.defineFunction(
    'withClaimCountByMonth',
    [
        'MthSales',
        'Sales',
        'Claims',
        'MthClaim'
    ],

    outputFields(),

    withClaimCountByMonth
)

x007_severityByMonth1
SELECT MthSales, Sales, Claims, Claims/Sales as actualFailureRate, Month0
FROM (

SELECT MthSales, Sum(Sales) as Sales, sum(Claims) as Claims, sum(Month0) as Month0
   FROM  withClaimCountByMonth(
   
   SELECT MthSales, COUNT(DISTINCT PolicyId) AS Sales, COUNT(DISTINCT ClaimId) AS Claims, MthClaim
     FROM [localcover-55:lc_api_show.001InitialAssocTable]
     WHERE YrSales = 2016 AND MthSales <= 1 AND MthClaim < 1
     GROUP BY MthSales, MthClaim
     ORDER BY MthSales, MthClaim
	 
	 ) as s
	 
   GROUP BY MthSales
   ORDER BY MthSales
   ) as t
   
GROUP BY MthSales, Sales, Claims, actualFailureRate, Month0
ORDER BY MthSales

const MONTHS = 1
const LOCALCOVER_EPOCH = new Date('2016-01-01T00:00:00Z');

function withClaimCountByMonth(row, emit) {
    let claimCount = new Array(MONTHS).fill(0)
    for (let i = 0; i <= MONTHS; i++) {
        claimCount[i] = 0
        if (row.MthClaim === i) {
            claimCount[i] = row.Claims
        }
    }
    emit({
        'MthSales': row.MthSales,
        'Sales': row.Sales,
        'Claims': row.Claims,
        'Month0': claimCount[0],
        'Month1': claimCount[1],   
        'Month2': claimCount[2],
        'Month3': claimCount[3],   
        'Month4': claimCount[4],
        'Month5': claimCount[5],   
        'Month6': claimCount[6],
        'Month7': claimCount[7],   
        'Month8': claimCount[8],
        'Month9': claimCount[9],         
        'Month10': claimCount[10],
        'Month11': claimCount[11],  
        'Month12': claimCount[12],        
    });
}

function outputFields() {
    let outputFields = [
        {name: 'MthSales', type: 'integer'},
        {name: 'Sales', type: 'integer'},
        {name: 'Claims', type: 'integer' },
    ];
    for (let i = 0; i <= MONTHS; i++) {
        let m = {name: 'Month' + i, type: 'integer'}
        outputFields.push(m);
    }
    return outputFields;
}

bigquery.defineFunction(
    'withClaimCountByMonth',
    [
        'MthSales',
        'Sales',
        'Claims',
        'MthClaim'
    ],

    outputFields(),

    withClaimCountByMonth
)

04ClaimDist  
SELECT claimsWeek, Dist, CummDist, expectedClaims, actualClaims, actualClaimRatio, if(preClaims is null, actualClaims, actualClaims - preClaims) AS claimRatioChange, 
  cumClaimExpected, cumClaimActual,
  if(cumClaimExpected = 0, 0, cumClaimActual/cumClaimExpected) as cummClaimRatio, 
  if(cumClaimExpected = 0, 0,cumClaimActual/cumClaimExpected) * 0.08 as cummFailureRate,  
  CummDist*31575 as premEarned, CummDist * 31575 * 0.7 as claimCummExpected, 
  if(actualClaims = 0, 0, actualClaimCost/actualClaims) as severityActual,  
  if(actualClaimRatio = 0, 0, actualClaimCost / (Dist * 31575 * 0.7 * actualClaimRatio) ) as severityRatio, claimsCummActual,
  if(CummDist = 0, 0, claimsCummActual/(CummDist*31575)) as LRActual
FROM (SELECT claimsWeek, Dist, CummDist, expectedClaims, actualClaimCount as actualClaims, actualClaimCount/expectedClaims AS actualClaimRatio, 
  LAG(actualClaimCount,1) OVER (ORDER BY claimsWeek) AS preClaims,
--   actualClaimCount/expectedClaims*0.08 as actualFailureRate,
  SUM(expectedClaims) OVER (ORDER BY claimsWeek) as cumClaimExpected,
  SUM(actualClaimCount) OVER (ORDER BY claimsWeek) as cumClaimActual,
  SUM(actualClaimCost) OVER (ORDER BY claimsWeek) as claimsCummActual,
  actualClaimCost
FROM [localcover-55:lc_api_dev.02ClaimDataByWeek]
ORDER BY claimsWeek)
GROUP BY claimsWeek, Dist, CummDist, expectedClaims, actualClaims, actualClaimRatio, claimRatioChange, cumClaimExpected, 
  cumClaimActual, cummClaimRatio, cummFailureRate, premEarned, claimCummExpected, severityActual, severityRatio, claimsCummActual, LRActual
ORDER BY claimsWeek

-- SELECT claimsWeek, actualClaimCount, actualClaimCount - pre as diff
-- FROM (SELECT claimsWeek, expectedClaims, actualClaimCount, actualClaimCount/expectedClaims AS actualClaimRatio, 
--   LAG(actualClaimCount,1) OVER (ORDER BY claimsWeek) AS pre,
-- --   SUM(expectedClaims) OVER (ORDER BY claimsWeek) as cumExpectedClaim,
-- --   SUM(actualClaimCount) OVER (ORDER BY claimsWeek) as cumClaimCount,
-- FROM [localcover-55:lc_api_dev.02ClaimDataByWeek]
-- ORDER BY claimsWeek)

show_006ClaimDataForMonth12  

SELECT YrSales, MthSales, Sales, Claims, Claims / Sales as actualFailureRate, Month0 / Sales as Month0, Month1 / Sales as Month1, 
   Month2 / Sales as Month2, Month3 / Sales as Month3, Month4 / Sales as Month4, Month5 / Sales as Month5, Month6 / Sales as Month6,
   Month7 / Sales as Month7, Month8 / Sales as Month8, Month9 / Sales as Month9, Month10 / Sales as Month10, Month11 / Sales as Month11, Month12 / Sales as Month12
FROM (SELECT YrSales, MthSales, sum(Sales) as Sales, sum(Claims) as Claims, sum(Sales)/sum(Claims) as actualFailureRate, sum(Month0) as Month0, sum(Month1) as Month1, sum(Month2) as Month2, 
   sum(Month3) as Month3, sum(Month4) as Month4, sum(Month5) as Month5, sum(Month6) as Month6,
   sum(Month7) as Month7, sum(Month8) as Month8, sum(Month9) as Month9, sum(Month10) as Month10, 
   sum(Month11) as Month11, sum(Month12) as Month12
FROM  withClaimCountByMonth(SELECT YrSales, MthSales, COUNT(DISTINCT PolicyId) AS Sales, COUNT(DISTINCT ClaimId) AS Claims, MthClaim
   FROM [localcover-55:lc_api_show.001InitialAssocTable]
   WHERE YrSales = 2016 AND MthSales <= 12
   GROUP BY YrSales, MthSales, MthClaim
   ORDER BY YrSales, MthSales, MthClaim) as s
  GROUP BY YrSales, MthSales
  ORDER BY YrSales, MthSales) as t
GROUP BY YrSales, MthSales, Sales, Claims, actualFailureRate, Month0, Month1, Month2, Month3, Month4, Month5, Month6,
   Month7, Month8, Month9, Month10, Month11, Month12    
ORDER BY MthSales

const MONTHS = 12
const LOCALCOVER_EPOCH = new Date('2016-01-01T00:00:00Z');

function withClaimCountByMonth(row, emit) {
    let claimCount = new Array(MONTHS).fill(0)

    let c = {
        'YrSales': row.YrSales,
        'MthSales': row.MthSales,
        'Sales': row.Sales,
        'Claims': row.Claims,
    }
    for (let i = 0; (i<= MONTHS) && (row.MthSales + row.MthClaim <= MONTHS); i++){
        claimCount[i] = 0
        if (row.MthClaim === i) {
            claimCount[i] = row.Claims
        }
        let name = 'Month' + i
        c[name] = claimCount[i]
    }
    emit(c)

}

function outputFields() {
    let outputFields = [
        {name: 'YrSales', type: 'integer'},
        {name: 'MthSales', type: 'integer'},
        {name: 'Sales', type: 'integer'},
        {name: 'Claims', type: 'integer' },
    ];
    for (let i = 0; i <= MONTHS; i++) {
        let m = {name: 'Month' + i, type: 'integer'}
        outputFields.push(m);
    }
    return outputFields;
}

bigquery.defineFunction(
    'withClaimCountByMonth',
    [
        'YrSales',
        'MthSales',
        'Sales',
        'Claims',
        'MthClaim'
    ],

    outputFields(),

    withClaimCountByMonth
)

 x007_LRDeviationTag  
 SELECT MthSales, Sales, Claims, cTimestamp, MthClaims, DeviationTag, DiffFromExpected, DiffWithActual
FROM calcDeviationTag

(
SELECT c.MthSales as MthSales, c.Sales as Sales, c.Claims as Claims, c.Month0 as cM0, c.Month1 as cM1, c.Month2 as cM2, c.Month3 as cM3, c.Month4 as cM4, c.Month5 as cM5, c.Month6 as cM6, 
  c.Month7 as cM7, c.Month8 as cM8, c.Month9 as cM9, c.Month10 as cM10, c.Month11 as cM11, c.Month12 as cM12,
  e.Month0 as eM0, e.Month1 as eM1, e.Month2 as eM2, e.Month3 as eM3, e.Month4 as eM4, e.Month5 as eM5, e.Month6 as eM6, 
  e.Month7 as eM7, e.Month8 as eM8, e.Month9 as eM9, e.Month10 as eM10, e.Month11 as eM11, e.Month12 as eM12,
FROM 
  [localcover-55:lc_api_show.006ClaimDataForMonth12] as c
FULL OUTER JOIN EACH
  [localcover-55:lc_api_show.004expectedClaimData] as e
ON c.YrSales = e.YrSales
) 
as assoc

ORDER BY MthSales, MthClaims

-- SELECT c.MthSales as MthSales, c.Sales as Sales, c.Claims as Claims, c.Month0 as cM0, c.Month1 as cM1, c.Month2 as cM2, c.Month3 as cM3, c.Month4 as cM4, c.Month5 as cM5, c.Month6 as cM6, 
--   c.Month7 as cM7, c.Month8 as cM8, c.Month9 as cM9, c.Month10 as cM10, c.Month11 as cM11, c.Month12 as cM12,
--   e.Month0 as eM0, e.Month1 as eM1, e.Month2 as eM2, e.Month3 as eM3, e.Month4 as eM4, e.Month5 as eM5, e.Month6 as eM6, 
--   e.Month7 as eM7, e.Month8 as eM8, e.Month9 as eM9, e.Month10 as eM10, e.Month11 as eM11, e.Month12 as eM12,
-- FROM 
--   [localcover-55:lc_api_show.006ClaimDataForMonth12] as c
-- FULL OUTER JOIN EACH
--   [localcover-55:lc_api_show.004expectedClaimData] as e
-- ON c.YrSales = e.YrSales 


const MONTHS = 12
const LOCALCOVER_EPOCH = new Date('2016-01-01T00:00:00Z')

function calcDeviationTag(row, emit) {
    let claimCount = new Array(MONTHS).fill(0)
    const MonthToMilliSecConversionFactor = 30 * 24 * 60 * 60 * 1000;
    for (let i = 1; i <= MONTHS; i++) {
       let actualMonth = 'cM' + i
       let preMonth = 'cM' + (i-1)
       let expectedMonth = 'eM' + i
       let a = row[actualMonth] - row[expectedMonth]
       let b = row[actualMonth] - row[preMonth]
       if (a > 0.001){
         let c = {
            'MthSales': row.MthSales,
            'Sales': row.Sales,
            'Claims': row.Claims,        
         }
        let Timestamp = new Date(LOCALCOVER_EPOCH.getTime()+ MonthToMilliSecConversionFactor * (row.MthSales * 13 + i))
        c.MthClaims = i
        c.cTimestamp = Timestamp
        c.DeviationTag  = true
        c.DiffFromExpected = a
        c.DiffWithActual = b
        emit(c)
       }
    }
    

}

function inputFields(){
  let inputFields = [
        'MthSales',
        'Sales',
        'Claims',
  ]
  
  for (let i = 0; i <= MONTHS; i++) {
    let name = 'cM'+i
    inputFields.push(name)
  }
  for (let i = 0; i <= MONTHS; i++) {
    let name = 'eM'+i
    inputFields.push(name)
  }
  return inputFields
}

function outputFields() {
    let outputFields = [
        {name: 'MthSales', type: 'integer'},
        {name: 'Sales', type: 'integer'},
        {name: 'Claims', type: 'integer' },
        {name: 'MthClaims', type: 'integer' },      
        {name: 'cTimestamp', type: 'timestamp' },
        {name: 'DeviationTag', type: 'boolean'},
        {name: 'DiffFromExpected', type: 'float'},
        {name: 'DiffWithActual', type: 'float'}
    ]
    return outputFields
}

bigquery.defineFunction(
    'calcDeviationTag',

    inputFields(),

    outputFields(),

    calcDeviationTag
)

SELECT YrSales, MthSales
FROM  withclaimCostByMonth( [localcover-55:lc_api_show.001InitialAssocTable]
   WHERE YrSales = 2016 AND MthSales <= 12
   GROUP BY YrSales, MthSales, MthClaim
   ORDER BY YrSales, MthSales, MthClaim) as s
  GROUP BY YrSales, MthSales
  ORDER BY YrSales, MthSales


x008_CostJoinDist  

data = {u'days_validated': '20', u'days_trained': '80', u'navigated_score': '1', u'description': 'First trial of top seller alg. No filter nor any condition is applied. Skus not present in train count as rank=0.5', u'init_cv_date': '2016-03-06', u'metric': 'rank', u'unix_date': '1461610020241117', u'purchased_score': '10', u'result': '0.32677139316724546', u'date': '2016-04-25', u'carted_score': '3', u'end_cv_date': '2016-03-25'}

schema = {u'fields': [{u'type': u'STRING', u'name': u'date', u'mode': u'NULLABLE'}, {u'type': u'INTEGER', u'name': u'unix_date', u'mode': u'NULLABLE'}, {u'type': u'STRING', u'name': u'init_cv_date', u'mode': u'NULLABLE'}, {u'type': u'STRING', u'name': u'end_cv_date', u'mode': u'NULLABLE'}, {u'type': u'INTEGER', u'name': u'days_trained', u'mode': u'NULLABLE'}, {u'type': u'INTEGER', u'name': u'days_validated', u'mode': u'NULLABLE'}, {u'type': u'INTEGER', u'name': u'navigated_score', u'mode': u'NULLABLE'}, {u'type': u'INTEGER', u'name': u'carted_score', u'mode': u'NULLABLE'}, {u'type': u'INTEGER', u'name': u'purchased_score', u'mode': u'NULLABLE'}, {u'type': u'STRING', u'name': u'description', u'mode': u'NULLABLE'}, {u'type': u'STRING', u'name': u'metric', u'mode': u'NULLABLE'}, {u'type': u'FLOAT', u'name': u'result', u'mode': u'NULLABLE'}]}


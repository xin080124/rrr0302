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

SELECT s.PolicyId as PolicyId, s.SalesWeek as SalesWeek, Integer((SalesWeek + 1) / 52 + 1) as SalesYear, s.premium_exGst as Premium_exGst, c.ClaimId as ClaimId, 
  s.productClass as Class, s.productBrand as Brand, s.productModel as Model, c.claimCostexGST as ClaimCost,
  ((YEAR(ClaimDate) - YrPurchased)*12 + (MONTH(ClaimDate) - mthPurchased) ) AS MthClaim,
  WtyProductCode
FROM (SELECT PolicyId, SalesWeek, premium_exGst, productClass, productBrand, productModel, WtyProductCode, YrPurchased, mthPurchased
  FROM [localcover-55:ling.sales] 
  WHERE wtyTerm = 12) AS s
LEFT OUTER JOIN [localcover-55:ling.claims] AS c
ON s.PolicyId = c.PolicyId
ORDER BY SalesWeek


step1: gather all of the data:
show_001InitialAssocTable  

From sales and claims

SELECT s.PolicyId as PolicyId, YrPurchased as YrSales, mthPurchased as MthSales, s.premium_exGst as Premium_exGst, c.ClaimId as ClaimId, 
  s.productClass as Class, s.productBrand as Brand, s.productModel as Model, c.claimCostexGST as ClaimCost,
  ((YEAR(ClaimDate) - YrPurchased)*12 + (MONTH(ClaimDate) - mthPurchased) ) AS MthClaim,
  WtyProductCode
FROM (SELECT PolicyId, SalesWeek, premium_exGst, productClass, productBrand, productModel, WtyProductCode, YrPurchased, mthPurchased
  FROM [localcover-55:ling.sales] 
  WHERE wtyTerm = 12) AS s
LEFT OUTER JOIN [localcover-55:ling.claims] AS c
ON s.PolicyId = c.PolicyId
ORDER BY SalesWeek



step2: generate expected data
002expectedDataFrom2015

from 001InitialAssocTable

SELECT YrSales, Sales, Claims, Claims / Sales as FailureRate, Premium, ClaimCost, ClaimCost / Claims as Severity, 
FROM (SELECT YrSales, COUNT(DISTINCT PolicyId) as Sales, COUNT(DISTINCT ClaimId) AS Claims, 
    SUM(Premium_exGst) as Premium,
    SUM(ClaimCost) as ClaimCost
  FROM [localcover-55:lc_api_show.001InitialAssocTable]
  WHERE YrSales = 2015
  GROUP BY YrSales
  ORDER BY YrSales) as t
  
step3 convert month claim row to month claim column
003_accExpectedFailureRate (UDF Editor) 

from 001InitialAssocTable
    
  SELECT YrSales, Month0, Month1, Month2, Month3, Month4, Month5, Month6,
   Month7, Month8, Month9, Month10, Month11, Month12
FROM (SELECT YrSales, sum(Month0) as Month0, sum(Month1) as Month1, sum(Month2) as Month2, 
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

const MONTHS = 12
const LOCALCOVER_EPOCH = new Date('2016-01-01T00:00:00Z');

function accum(index,valueArray){
    total = 0
    while(index>-1)
    {
        total += valueArray[index] 
        index--
    }
    return total
}

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
        'Month0': accum(0,claimCount),
        'Month1': accum(1,claimCount),   
        'Month2': accum(2,claimCount),
        'Month3': accum(3,claimCount),   
        'Month4': accum(4,claimCount),
        'Month5': accum(5,claimCount),   
        'Month6': accum(6,claimCount),
        'Month7': accum(7,claimCount),   
        'Month8': accum(8,claimCount),
        'Month9': accum(9,claimCount),         
        'Month10': accum(10,claimCount),
        'Month11': accum(11,claimCount),  
        'Month12': accum(12,claimCount),        
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

step5 
005_AccumulatedClaimCostForMonth

SELECT YrSales, MthSales, sum(Premium) as Premium, sum(ClaimCost) as ClaimCost, sum(Month0) as Month0, sum(Month1) as Month1, sum(Month2) as Month2, 
   sum(Month3) as Month3, sum(Month4) as Month4, sum(Month5) as Month5, sum(Month6) as Month6,
   sum(Month7) as Month7, sum(Month8) as Month8, sum(Month9) as Month9, sum(Month10) as Month10, 
   sum(Month11) as Month11, sum(Month12) as Month12

//SELECT debug1, debug2,  YrSales, MthSales, ClaimCost, Month1, Month2, Month3, Month4
   FROM  withclaimCostByMonth(SELECT YrSales, MthSales, SUM(Premium_exGst) AS Premium, SUM(ClaimCost) AS ClaimCost, MthClaim
   FROM [localcover-55:lc_api_show.001InitialAssocTable]
   WHERE YrSales = 2016
   GROUP BY YrSales, MthSales, MthClaim
   ORDER BY YrSales, MthSales, MthClaim
   
   ) as s
 GROUP BY YrSales, MthSales
 ORDER BY YrSales, MthSales
 
const MONTHS = 12
const AMONTHS = 12
const LOCALCOVER_EPOCH = new Date('2016-01-01T00:00:00Z');


function accum(index,valueArray){
    total = 0
    while(index>-1)
    {
        total += valueArray[index] 
        index--
    }
    return total
}

function withclaimCostByMonth(row, emit) {
    let claimCost = new Array(MONTHS).fill(0)

    let c = {
        'YrSales': row.YrSales,
        'MthSales': row.MthSales,
        'Premium': row.Premium,
        'ClaimCost': row.ClaimCost,
    }
    for (let i = 0; i<= MONTHS; i++){
        claimCost[i] = 0
        if(row.MthClaim === i)
        {
            claimCost[i] = row.ClaimCost
        }
        let name = 'Month' + i
        
        c['debug1'] = row.MthSales
        c['debug2'] = row.MthClaim
        
        c[name] = accum(i,claimCost)
    }
    emit(c)

}

function outputFields() {
    let outputFields = [
        {name: 'YrSales', type: 'integer'},
        {name: 'MthSales', type: 'integer'},
        {name: 'Premium', type: 'float'},
        {name: 'ClaimCost', type: 'float' },
        {name: 'debug1', type: 'integer'},
        {name: 'debug2', type: 'integer' },
    ];
    for (let i = 0; i <= MONTHS; i++) {
        let m = {name: 'Month' + i, type: 'float'}
        outputFields.push(m);
    }
    return outputFields;
}

bigquery.defineFunction(
    'withclaimCostByMonth',
    [
        'YrSales',
        'MthSales',
        'Premium',
        'ClaimCost',
        'MthClaim'
    ],

    outputFields(),

    withclaimCostByMonth
)

005marked version
x005_accClaimCostMaskVersion
SELECT  a.YrSales as YrSales, a.MthSales as MthSales,a.Premium as Premium ,a.ClaimCost as ClaimCost,
a.Month0*m.Month0 as M0, a.Month1*m.Month1 as M1, a.Month2*m.Month2 as M2,
a.Month3*m.Month3 as M3, a.Month4*m.Month4 as M4, a.Month5*m.Month5 as M5,
a.Month6*m.Month6 as M6, a.Month7*m.Month7 as M7, a.Month8*m.Month8 as M8,
a.Month9*m.Month9 as M9, a.Month10*m.Month10 as M10, a.Month11*m.Month11 as M11
FROM [localcover-55:lc_api_show.005_AccumulatedClaimCostForMonth]   as a
   LEFT OUTER JOIN 
   [localcover-55:lc_api_show.006_maskTable_12]    as m
   ON a.MthSales = m.MthSales
   //WHERE salesWeek = a01.SalesWeek
   //ORDER BY LRDiv desc
         
x008_actualLRBasedOnMarkedVersion  

SELECT MthSales,  cTimestamp, Prem, ActualLR0,ActualLR1,ActualLR2,ActualLR3,ActualLR4,ActualLR5,ActualLR6,
ActualLR7,ActualLR8,ActualLR9,ActualLR10,ActualLR11,
//MthClaims, 
DeviationTag, DiffFromExpected, 
//DiffWithActual
FROM calcDeviationTag(

SELECT c.MthSales as MthSales, c.Premium as Prem, c.ClaimCost as ClaimCost, 
  c.M0 as cM0, e.Month0 as eM0, c.M1 as cM1,e.Month1 as eM1,  c.M2 as cM2, e.Month2 as eM2, 
  c.M3 as cM3, c.M4 as cM4, c.M5 as cM5, c.M6 as cM6, 
  c.M7 as cM7, c.M8 as cM8, c.M9 as cM9, c.M10 as cM10, c.M11 as cM11, 
     e.Month3 as eM3, e.Month4 as eM4, e.Month5 as eM5, e.Month6 as eM6, 
  e.Month7 as eM7, e.Month8 as eM8, e.Month9 as eM9, e.Month10 as eM10, e.Month11 as eM11, e.Month12 as eM12,
FROM 
  [localcover-55:yixin.x005_accClaimCostMaskVersion]   as c
FULL OUTER JOIN EACH
  [localcover-55:lc_api_show.004_accFailureDistribution]  as e
ON c.YrSales = e.YrSales

) as assoc
ORDER BY MthSales, MthClaims asc

const MONTHS = 12
//for the available data for month, range from 1 to 12, for different snapshot of month
const AMONTHS = 11
const LOCALCOVER_EPOCH = new Date('2016-01-01T00:00:00Z')

function calcDeviationTag(row, emit) {
  let claimCount = new Array(MONTHS).fill(0)
  const MonthToMilliSecConversionFactor = 30 * 24 * 60 * 60 * 1000;
  let c = {
          'MthSales': row.MthSales,
        }
  
  for (let i = 0; i < MONTHS; i++) {
    //if (row.MthSales + i === AMONTHS) {
      let actualMonth = 'cM' + i
      let preMonth = 'cM' + (i - 1)
      //let expectedMonth = 'eM' + i
      let distribution = 'eM' + i
      let expectedMonth = 0.7
      //let a = row[actualMonth] - row[expectedMonth]
      let LR = row[actualMonth]/(row.Prem*row[distribution])
      let LRDiv = LR-0.7
      //let b = row[actualMonth] - row[preMonth]
      
      //if (LRDiv > 0) {
        
        let Timestamp = new Date(LOCALCOVER_EPOCH.getTime() + MonthToMilliSecConversionFactor * (row.MthSales * 13 + i))
        c.MthClaims = i
        c.cTimestamp = Timestamp
        c.Prem = row.Prem
        if (LRDiv > 0)
            c.DeviationTag = true
        else
            c.DeviationTag = false
        c.DiffFromExpected = LRDiv
        //c.DiffWithActual = b
      
        //for (let i = 0; (i<= MONTHS) && (row.MthSales + row.MthClaim <= MONTHS); i++){
        //for (let columnIndex = 0; (columnIndex<= MONTHS) ; columnIndex++){  
       
            let name = 'ActualLR' + i
            c[name] = LR
        //}
       
      }
      emit(c)
}

function inputFields() {
  let inputFields = [
    'MthSales',
    'Prem',
  ]

  for (let i = 0; i < MONTHS; i++) {
    let name = 'cM' + i
    inputFields.push(name)
  }
  for (let i = 0; i <= MONTHS; i++) {
    let name = 'eM' + i
    inputFields.push(name)
  }
  return inputFields
}

function outputFields() {
  let outputFields = [
    { name: 'MthSales', type: 'integer' },
    { name: 'Prem', type: 'float' },
    //{ name: 'Claims', type: 'integer' },
    { name: 'MthClaims', type: 'integer' },
    { name: 'cTimestamp', type: 'timestamp' },
    { name: 'DeviationTag', type: 'boolean' },
    { name: 'DiffFromExpected', type: 'float' },
    //{ name: 'DiffWithActual', type: 'float' }
   
  ]
  
   for (let i = 0; i < MONTHS; i++) {
        let m = {name: 'ActualLR' + i, type: 'float'}
       outputFields.push(m);
   }
     
  return outputFields
}

bigquery.defineFunction(
  'calcDeviationTag',

  inputFields(),

  outputFields(),

  calcDeviationTag
)
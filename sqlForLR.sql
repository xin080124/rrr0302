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
   WHERE YrSales = 2016 AND MthSales <= 9
   GROUP BY YrSales, MthSales, MthCla
   ORDER BY YrSales, MthSales, MthClaim
   
   ) as s
 GROUP BY YrSales, MthSales
 ORDER BY YrSales, MthSales



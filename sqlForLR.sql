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
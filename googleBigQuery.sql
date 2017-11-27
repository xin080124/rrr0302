SELECT SalesWeek, COUNT(SalesWeek) as sales, SUM( premium_exGst ) as totalPremium, failureRate, 93 as expectedClaims
  FROM [localcover-55:lc_api_dev.addClaimWeek]
  WHERE SalesWeek = 61 
  GROUP BY SalesWeek, failureRate
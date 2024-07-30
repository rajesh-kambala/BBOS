--
-- Repurpose the prra_Rated flag
--
UPDATE PRRating
   SET prra_Rated = NULL;

UPDATE PRRating
   SET prra_Rated = 'Y'
 WHERE prra_RatingID IN (   
		SELECT prra_RatingID
		  FROM vPRCompanyRating
		 WHERE prra_CreditWorthId IS NOT NULL      
		   OR prra_IntegrityId IS NOT NULL
		   OR prra_PayRatingId IS NOT NULL
		   OR LEN(prra_AssignedRatingNumerals) > 0);
Go   

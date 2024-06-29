WITH rfm_table as
		(
		SELECT 
				customer_id, 
				'2022-09-01'::date - max(purchase_date) recency,
				count(transaction_id) frequency,
				sum(gmv) monetary
		FROM customer_transaction ct
		JOIN customer_registered cr ON ct.customer_id = cr.id
		WHERE customer_id <> 0
		GROUP BY customer_id
		),
rfm_calculation AS 		
		(
		SELECT 
				*,
				NTILE(4) OVER (ORDER BY recency DESC) r,
				NTILE(4) OVER (ORDER BY frequency) f,
				NTILE(4) OVER (ORDER BY monetary) m
		FROM rfm_table		
		),
rfm_chart AS
		(
		SELECT 
				*,
				CAST(concat(r,f,m) AS int) AS rfm 
		FROM rfm_calculation		
		),
rfm_segmentation AS
		(
		SELECT 
				*,
				CASE WHEN rfm IN (444,443,434) THEN 'Champions'
		            WHEN rfm IN (244,243,234,344,343,334) THEN 'Loyal Customers'
		            WHEN rfm IN (313,331,314,341,324,342,323,332,322,333,413,431,414,
		            				441,424,442,423,432,422,433) THEN 'Potential Loyalist'
		            WHEN rfm IN (311,312,321) THEN 'Promising'
		            WHEN rfm IN (411,412,421) THEN 'New Customers'
		            WHEN rfm IN (144,143,134) THEN 'Can not lose them'
		            WHEN rfm IN (213,231,214,241,224,242,223,232,233) THEN 'Needs Attention'
		            WHEN rfm IN (211,212,221,222) THEN 'About to sleep'
		            WHEN rfm IN (113,131,114,141,124,142,123,132,122,133) THEN 'At risk Customer'
		            WHEN rfm IN (111,121,112) THEN 'Lost Customer'
		            END AS rfm_segmentation
      	FROM rfm_chart 
      	)
SELECT *
FROM rfm_segmentation;     	

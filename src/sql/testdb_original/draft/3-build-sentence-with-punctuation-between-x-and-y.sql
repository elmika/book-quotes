SET @x =  18;
SET @y = 46;
SELECT 
	word, 
	offset, 
	1 AS priority 
FROM words w
WHERE w.offset BETWEEN @x + 1 AND @y

UNION

select 
	p.punctuation, 
	p.offset, 
	2 AS priority 
FROM punctuations p
WHERE p.offset BETWEEN @x + 1 AND @y

ORDER BY offset, priority asc;
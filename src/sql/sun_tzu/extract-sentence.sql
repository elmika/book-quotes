SET @word_offset = 237;

SELECT @min_offset := MAX(p.offset) 
FROM punctuations p
WHERE p.offset < @word_offset 
	AND p.punctuation LIKE '.';

SELECT @max_offset := MIN(p.offset) 
FROM punctuations p
WHERE p.offset > @word_offset 
	AND p.punctuation LIKE '.';
	

/* Short */
SELECT 
	word, 
	offset, 
	1 AS priority 
FROM 
	words w
WHERE 
	w.offset BETWEEN @min_offset + 1 AND @max_offset

UNION

SELECT 
	punctuation, 
	offset, 
	2 AS priority 
FROM 
	punctuations 
WHERE
	offset BETWEEN @min_offset + 1 AND @max_offset
ORDER BY offset, priority ASC
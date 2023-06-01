SET @x =  18;
SET @y = 46;
SELECT w.word 
FROM words w
WHERE w.offset BETWEEN @x + 1 AND @y 
ORDER BY w.offset ASC;
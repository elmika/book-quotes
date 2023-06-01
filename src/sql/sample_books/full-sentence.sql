-- New generation DB.
SET @word_offset = 154;
SELECT
	word
from
	words
JOIN sentences
ON words.source = sentences.source
WHERE
	words.offset BETWEEN sentences.mybeginning AND sentences.myend
	AND @word_offset BETWEEN sentences.mybeginning AND sentences.myend
	AND words.source = 'alice_FR.txt'
	AND NOT(type='formatting' and word='lf')
ORDER BY words.offset ASC


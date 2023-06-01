SET @word_offset = 237;
select max(offset) from punctuations where offset < @word_offset and punctuation like '.';
select min(offset) from punctuations where offset > @word_offset and punctuation like '.';
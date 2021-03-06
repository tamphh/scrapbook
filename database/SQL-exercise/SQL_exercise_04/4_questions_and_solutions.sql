-- https://en.wikibooks.org/wiki/SQL_Exercises/Movie_theatres
-- 4.1 Select the title of all movies.
select title from Movies;

-- 4.2 Show all the distinct ratings in the database.
select distinct rating from Movies where rating is not null;

-- 4.3  Show all unrated movies.
select * from Movies where rating is null;

-- 4.4 Select all movie theaters that are not currently showing a movie.
select * from MoviesTheatres where movie is null;

-- 4.5 Select all data from all movie theaters 
    -- and, additionally, the data from the movie that is being shown in the theater (if one is being shown).
select * from MovieTheaters mt
left join Movies m on m.code = mt.movie
where movie is not null;

-- 4.6 Select all data from all movies and, if that movie is being shown in a theater, show the data from the theater.
select * from Movies m
  left join MovieTheaters mt
    on mt.Movie = m.code
order by m.code;

-- 4.7 Show the titles of movies not currently being shown in any theaters.
select * from Movies m
  left join MovieTheaters mt
    on mt.Movie = m.code
where mt.code is null
order by m.code;

-- 4.8 Add the unrated movie "One, Two, Three".
insert into Movies(Code, Title, Rating) values(9, 'One, Two, Three', null);

-- 4.9 Set the rating of all unrated movies to "G".
update Movies
set Rating = 'G'
where Movies.Code in (
  select m.Code from (select * from Movies) m where m.Rating is null
);

UPDATE Movies
SET Rating = 'G'
WHERE Rating is NULL;

-- 4.10 Remove movie theaters projecting movies rated "NC-17".
delete from MovieTheaters
where MovieTheaters.Movie in (
  select m.Code from (select * from Movies) m where m.Rating='NC-17'
);

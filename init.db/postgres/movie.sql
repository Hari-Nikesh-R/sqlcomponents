DROP TABLE IF EXISTS movie;

CREATE TABLE movie (
    id smallserial PRIMARY KEY,
    title VARCHAR(80),
    directed_by VARCHAR(80)
);


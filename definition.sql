CREATE DATABASE memoapp ENCODING = 'UTF8' TEMPLATE template0;

CREATE TABLE memo
(id text not null,
title text,
"text" text,
PRIMARY KEY(id));

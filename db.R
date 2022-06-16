library(dbplyr)
library(RPostgres)
library(DBI)
library(readr)
library(dplyr)

conn <- DBI::dbConnect(
                 RPostgres::Postgres(),
                 dbname = read_file("config/secrets/postgres_db"),
                 host = "localhost",
                 user = read_file("config/secrets/postgres_user"),
                 password = read_file("config/secrets/postgres_password")
             )

tx_tbl <- tbl(conn, "tx")
script_tbl <- tbl(conn, "script")
tx_in_tbl <- tbl(conn, "tx_in")
tx_out_tbl <- tbl(conn, "tx_out")
block_tbl <- tbl(conn, "block")

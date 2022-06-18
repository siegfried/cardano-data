source("db.R")

library(tidyverse)

multisig_tx <- tx_tbl %>%
    inner_join(
        script_tbl,
        by = c("id" = "tx_id"),
        suffix = c("", ".script")
    ) %>%
    inner_join(
        block_tbl,
        by = c("block_id" = "id"),
        suffix = c("", ".block")
    ) %>%
    left_join(
        ma_tx_mint_tbl,
        by = c("id" = "tx_id"),
        suffix = c("", ".ma_tx_mint")
    ) %>%
    filter(type == "timelock") %>%
    transmute(
        id,
        id.ma_tx_mint,
        slot_no,
        date = as.Date(time)
    )

non_minting_multisig_tx <- tx_tbl %>%
    inner_join(
        script_tbl,
        by = c("id" = "tx_id"),
        suffix = c("", ".script")
    ) %>%
    inner_join(
        block_tbl,
        by = c("block_id" = "id"),
        suffix = c("", ".block")
    ) %>%
    anti_join(
        ma_tx_mint_tbl,
        by = c("id" = "tx_id")
    ) %>%
    filter(type == "timelock") %>%
    transmute(
        id,
        slot_no,
        date = as.Date(time)
    )

calculate_tx_stats <- function(data) {
    data %>%
        group_by(date) %>%
        summarise(count = n())
}

plot_multisig_count <- function(data) {
    data %>%
        ggplot(aes(date, count)) +
        geom_area() +
        labs(
            title = "Multi-Sig Transactions",
            subtitle = "Transactions with native script",
            x = "Date",
            y = "Count"
        )
}

plot_multisig_cum_count <- function(data) {
    data %>%
        ggplot(aes(date, cum_count)) +
        geom_area() +
        labs(
            title = "Multi-Sig Transactions",
            subtitle = "Transactions with native script",
            x = "Date",
            y = "Cumulative Count"
        )
}

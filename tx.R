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
        mint = !is.na(id.ma_tx_mint),
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

aggregate_tx_stats <- function(data) {
    data %>%
        group_by(date, mint) %>%
        summarise(count = n()) %>%
        collect() %>%
        mutate(count = as.numeric(count)) %>%
        ungroup() %>%
        pivot_wider(names_from = mint, values_from = count, values_fill = 0) %>%
        mutate(Mint = cumsum(`TRUE`), `Not Mint` = cumsum(`FALSE`)) %>%
        pivot_longer(
            c(Mint, `Not Mint`),
            names_to = "Type",
            values_to = "count"
        )
}

plot_multisig_cum_count <- function(data) {
    data %>%
        ggplot(aes(date, count, fill = Type)) +
        geom_area() +
        labs(
            title = "Multi-sig Transactions on Cardano chain",
            subtitle = "Transactions with native script",
            x = "Date",
            y = "Cumulative Count"
        ) +
        scale_x_date(breaks = "month")
}

unspent_assets <- utxo_tbl %>%
    inner_join(
        ma_tx_out_tbl,
        by = c("id" = "tx_out_id")
    ) %>%
    left_join(multi_asset_tbl, by = c("ident" = "id"))

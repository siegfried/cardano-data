source("db.R")

multisig_tx <- tx_tbl %>%
    inner_join(script_tbl, by = c("id" = "tx_id")) %>%
    inner_join(block_tbl, by = c("block_id" = "id")) %>%
    filter(type == "timelock") %>%
    transmute(id = id.x, slot_no, date = as.Date(time)) %>%
    distinct(id, .keep_all = TRUE)

multisig_tx_stats <- mtx %>%
    group_by(date) %>%
    summarise(count = n()) %>%
    arrange(date) %>%
    mutate(cum_count = cumsum(number))

plot_multisig_tx_stats <- function(data) {
    data %>%
        ggplot(aes(date, cum_count)) +
            geom_line()
}

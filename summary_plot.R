library(data.table)
library(ggplot2)
library(dplyr)
library(plotly)
library(htmlwidgets)

data_filename <- paste0("goals_data_",Sys.Date())
github_path <- Sys.getenv("GITHUB_PATH")

data <- fread(paste0(github_path,"/goals-summary/data/", data_filename, ".csv")) %>% rename(daily_value = value)

data <- data %>% 
  mutate(daily_value = if_else(name=="running", daily_value/1.609344, daily_value)) %>% # km to miles
  mutate(daily_value = round(daily_value,2)) %>%
  mutate(date = as.Date(date)) %>% 
  filter(date>=as.Date("2024-01-01")) %>% 
  mutate(type = "progress") %>%
  arrange(name,date) %>% 
  group_by(name) %>% 
  mutate(cumulative = cumsum(daily_value)) %>% 
  ungroup()

# add yearly goals
for (name1 in unique(data$name)){
  data <- data %>% add_row(date = as.Date("2024-01-01"), 
                           name = name1,
                           type = "goal",
                           cumulative = 0)
}

data <- data %>%
  add_row(date = as.Date("2024-12-31"), name = "running", type = "goal", cumulative = 1000) %>%
  add_row(date = as.Date("2024-12-31"), name = "alcohol", type = "goal", cumulative = 365) %>%
  add_row(date = as.Date("2024-12-31"), name = "reading", type = "goal", cumulative = 3650) %>%
  add_row(date = as.Date("2024-12-31"), name = "weight lifting", type = "goal", cumulative = 78)

p <- ggplot(data, aes(x=date, y=cumulative, color=type, label=daily_value)) +
  geom_line() +
  geom_point(data = data %>% filter(row_number()%%7==0|type=="goal"), shape=1) +
  facet_wrap(~name,scales = "free_y") +
  theme(axis.title.y = element_blank(),
        axis.title.x = element_blank()) +
  theme_bw()

p <- ggplotly(p)

saveWidget(p, file = paste0(github_path,"/goals-summary/plots/goals-2024.html"))

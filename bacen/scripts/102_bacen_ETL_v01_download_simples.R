# CLEAR ENVIRONMENT ############################################################

# INSTALL AND LOAD PACKAGES ####################################################

install_and_load_packages <- function(...) {
  # Capture the arguments as a character vector
  packages <- c(...)
  
  # Check if all inputs are strings
  if (!all(sapply(packages, is.character))) {
    stop("All input arguments must be strings representing package names.")
  }
  
  for (pkg in packages) {
    if (!require(pkg, character.only = TRUE)) {
      install.packages(pkg, method = "wget")
    } 
    library(pkg, character.only = TRUE)
  } 
}

install_and_load_packages('GetBCBData', 'dplyr', 'tidyr', 'openxlsx')

# TIME CONTROL #################################################################

# Record the start time
start_time <- Sys.time()

# PARAMETERS ###################################################################

tema = "Teste"

ids_bacen = c(28183)

data_ini = '2020-01-01'

file_name = "teste"

output_folder = "bacen/lake/"

path_xlsx = paste0(output_folder, file_name, ".xlsx")

path_rdata = paste0(output_folder, file_name, ".rdata")

# FOLDER #######################################################################

# Check if the folder exists
if (!dir.exists(output_folder)) {
  # If the folder doesn't exist, create it
  dir.create(output_folder, recursive = TRUE)
}

# DOWNLOAD SIMPLES #############################################################

# comando:
df = gbcbd_get_series(
  
  # Id of time series. The name of the vector sets the name of the series in the output (e.g i.d <- c('SELIC' = 11)). You can search for ids in the official BCB-SGS webpage <http://www.bcb.gov.br/?sgs>
  id = ids_bacen,
  
  # First date of time series
  first.date = data_ini,
  
  # Last date of time series
  last.date = Sys.Date(),
  
  # The format of the datasets - long (default, series incremented by rows) or wide (series incremented by columns)
  # format.data	= wide
  
  # Logical. Should functions output messages to screen? - FALSE (default) or TRUE
  # be.quiet
  
  # Logical. Sets the use of caching system - TRUE (default) or FALSE
  # use.memoise	
  
  # Path to save cache files - 'rbcb2_cache' (default)
  # cache.path
  
  # Logical for parallel data importation - FALSE (default)
  # do.parallel
  
  )

# TRATAMENTO ###################################################################

# Delete column:
df$series.name = NULL

# Rename colnames:
df <- df %>%
  rename(
    data = ref.date,
    id_bacen = id.num,
    valor = value
  )

# Spread the dataframe:
df <- df %>%
  spread(key = id_bacen, value = valor)

# Sort the dataframe by the data column:
df <- df %>%
  arrange(data)

# UPDATE DATE ##################################################################

df$update = format(Sys.time(), "%Y-%m-%d %H:%M:%S")

# SAVE TO XLSX #################################################################

# Create a workbook and add data to a worksheet
wb <- createWorkbook()
addWorksheet(wb, tema)
writeData(wb, sheet = tema, x = df)

# Define a style for the column headers
headerStyle <- createStyle(
  fontColour = "#FFFFFF", 
  fgFill = "#0000FF", 
  textDecoration = "bold"
)

# Apply the style to the column headers
addStyle(wb, sheet = tema, style = headerStyle, rows = 1, cols = 1:ncol(df), 
         gridExpand = TRUE)

# Auto-adjust column widths to fit the content
setColWidths(wb, sheet = tema, cols = 1:ncol(df), widths = "auto")

# Save the workbook to an Excel file
saveWorkbook(wb, path_xlsx, overwrite = TRUE)

# SAVE TO RDATA ################################################################

# Write the dataframe to an rdata file
save(df, file = path_rdata)

# TIME CONTROL #################################################################

# Record the end time:
end_time <- Sys.time()

# Calculate the duration:
duration <- end_time - start_time

# Extract hours, minutes, and seconds:
hours <- as.numeric(duration, units = "hours") %/% 1
minutes <- as.numeric(duration, units = "mins") %/% 1 %% 60
seconds <- as.numeric(duration, units = "secs") %/% 1 %% 60

# Format the duration as hh:mm:ss:
duration <- sprintf("%02d:%02d:%02d", hours, minutes, seconds)

# TEMPO DE EXECUÇÃO:
print(duration)

# END ##########################################################################

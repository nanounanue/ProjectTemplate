sql.reader <- function(data.file, filename, variable.name)
{
  # A .sql file contains YAML describing the data source.
  # Two example files are shown below.
  #
  # type: mysql
  # user: sample_user
  # password: sample_password
  # host: localhost
  # dbname: sample_database
  # table: sample_table
  #
  # type: sqlite
  # dbname: /path/to/sample_database
  # table: sample_table
  #
  # type: sqlite
  # dbname: /path/to/sample_database
  # query: SELECT * FROM users WHERE user_active == 1
  #
  
  database.info <- ProjectTemplate:::translate.dcf(filename)

  if (! (database.info[['type']] %in% c('mysql', 'sqlite')))
  {
    warning('Only databases reachable through RMySQL and RSQLite
             are currently supported.')
    assign(variable.name,
           NULL,
           envir = .GlobalEnv)
    return()
  }

  if (database.info[['type']] == 'mysql')
  {
    library('RMySQL')
    mysql.driver <- dbDriver("MySQL")

    connection <- dbConnect(mysql.driver,
                            user = database.info[['user']],
                            password = database.info[['password']],
                            host = database.info[['host']],
                            dbname = database.info[['dbname']])
  }

  if (database.info[['type']] == 'sqlite')
  {
    library('RSQLite')
    sqlite.driver <- dbDriver("SQLite")

    connection <- dbConnect(sqlite.driver,
                            dbname = database.info[['dbname']])
  }

  # Added support for queries.
  # User should specify either a table name or a query to execute, but not both.
  table <- database.info[['table']]
  query <- database.info[['query']]
  
  # If both a table and a query are specified, favor the query.
  if (!is.null(table) & !is.null(query))
  {
  		warning(paste("'query' parameter in ",
  		              filename,
  		              " overrides 'table' parameter.",
  		              sep = ''))
  		table <- NULL
  }
  
  # If table is specified, read the whole table.
  # Othwrwise, execute the specified query.
  if (!is.null(table))
  {
    if (dbExistsTable(connection, table))
  	{
      data.parcel <- dbReadTable(connection,
  	                             table,
  	                             row.names = NULL)
  	  
  	  assign(variable.name,
  	         data.parcel,
  	         envir = .GlobalEnv)
  	}
  	else
  	{
  	  warning(paste('Table not found:', table))
  	  return()
  	}
  }
  else
  {
    data.parcel <- try(dbGetQuery(connection, query))
  	err <- dbGetException(connection)
    
  	if (class(data.parcel) == 'data.frame' & err$errorNum == 0)
  	{
  		assign(variable.name,
  					 data.parcel,
  					 envir = .GlobalEnv)
  	}
  	else
  	{
  		warning(paste("Error loading '",
  		              variable.name,
  		              "' with query '",
  		              query,
  							    "'\n    '",
  							    err$errorNum,
  							    "-",
  							    err$errorMsg,
  							    "'",
  							    sep = ''))
  		return()
  	}
  }

  # If the table exists but is empty, do not create a variable.
  # Or if the query returned no results, do not create a variable.
  if (nrow(data.parcel) == 0)
  {
    assign(variable.name,
           NULL,
           envir = .GlobalEnv)
    return()
  }

  # Disconnect from database resources. Warn if failure.
  disconnect.success <- dbDisconnect(connection)

  if (! disconnect.success)
  {
    warning(paste('Unable to disconnect from database:',
                  database.info[['dbname']]))
  }
}
\name{file.reader}
\alias{file.reader}
\title{Read an arbitrary file described in a .file file.}
\usage{
  file.reader(data.file, filename, variable.name)
}
\arguments{
  \item{data.file}{The name of the data file to be read.}

  \item{filename}{The path to the data set to be loaded.}

  \item{variable.name}{The name to be assigned to in the
  global environment.}
}
\value{
  No value is returned; this function is called for its
  side effects.
}
\description{
  This function will load all of the data sets described in
  the specified .file file into the global environment. A
  .file file must contain DCF that specifies the path to
  the data set and which extension should be used from the
  dispatch table to load the data set.
}
\details{
  Examples of the DCF format and settings used in a .file
  file are shown below:

  path:
  http://www.johnmyleswhite.com/ProjectTemplate/sample_data.csv
  extension: csv
}
\examples{
library('ProjectTemplate')

\dontrun{file.reader('example.file', 'data/example.file', 'example')}
}


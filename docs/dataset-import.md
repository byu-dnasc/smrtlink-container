# Dataset import

Dataset objects are imported in SMRT Link from consensusreadset.xml files.

For the import to be successful, all files referenced in the XML file (usually
called "resources") must be present on the path provided by the XML.

The Revio instrument exports files to the SMRT Link server. These files can
be copied to a filesystem the SMRT Link container has access to and then
imported. To save time and space, the files from the Revio should be modified
such that they are smaller (or empty), yet include essential content for
SMRT Link to be able to "import" them.

## import dataset jobs

An import job can be requested from the SMRT Link GUI. The web services API
has a method to do the same thing, but the method which imports a
ZIP file only responds with 404 (NOTE: try import-dataset instead of 
import-dataset-zip). I have created a case for this issue with
PacBio, but for now, they are putting it on the backburner.

## Dummy datasets

To save space and time, create dummy datasets to import. In order to trick
SMRT Link, a dummy dataset must at least have the following characteristics:

1. All "resources" mentioned in XML must exist at given paths (mostly BAM, JSON, and XML)
2. If present, ZIP files must be unmodified
3. BAM files may or may not need to have contents (definitely don't have to be unmodified)

When it comes to the BAM files, sometimes empty ones work. It seems that this
may be the case when the import job finds all the reports it wants for a
dataset, and therefore it doesn't need to analyze the BAMs to create reports.
Other times, though, empty BAM files will kill the import job.

## Make dummy script

A script has been prepared to create a dummy version of a set of files which
belong to a given dataset created by Revio. This creates a file for all the
files belonging to a dataset, but the contents vary:

- BAM files contain a single record with a mininal header and come with a PBI
- Copy all JSON, XML and ZIP files (do not modify)
- all other files are empty

## Parent, then child

If a dataset specifies pbds:ParentDataSet

## Dataset from scratch?

It may be a useful thing to create some minimal datasets from scratch. These
would be even smaller than dummy datasets, which would be somewhat convenient.
The downside to this approach would be that it would only cover the most basic
cases. It may be necessary for testing purposes to have datasets with more
complex features.
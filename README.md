# SMRTLink Container

This repository is dedicated to developing a containerized SMRTLink
server for testing the DNASC app.

## Development log

1/10/2024: The execution of the installer is designed be configurable using
variables in imported.env.

## Notes

The value of SMRT_ROOT will be built into the installation, meaning that
if you want to change where SMRT Link is installed, you have to re-install
it.

Expect issues starting SMRT Link services immediately after a fresh install.

Give services-start a minute to finish. If it decides to try to import
canned data it can take even longer.
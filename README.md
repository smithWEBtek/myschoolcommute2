# README

MySchoolCommute is a statewide platform for surveying and tracking longitudinal and spatial information about transportation modes and behavior from and to school. This platform runs surveys and analyses data collected for surveys. 

It is currently in active re-development. 

## Dependencies
This project requires Postgres, postgis, and pgrouting. See http://www.kyngchaos.com/software/postgres. The setup process will fail without these dependencies.

## PGRouting For Mac
PGRouting is needed for the School walkshed re-generation. This is a less critical feature, so it'd be acceptable to comment out the pgrouting extension in the migration. 
`brew install pgrouting`

## Setup
This project uses Git LFS to manage large seed files. Make sure you download those files before doing anything else.
Run `bin/setup` in your terminal.

## WARNING
`bin/setup` runs a seed task that creates an admin user with the following credentials: 
User: `admin@user.org`
Password: `password`

This should be deleted before moved to production!

# Submodules
Some of the view logic was complicated enough to warrant a FE framework. There are two, both using React:
1. Public survey form: https://github.com/MAPC/intersecting-streets-react
2. Map for viewing a school and its walksheds: https://github.com/MAPC/school-map

<!-- markdownlint-disable MD024 -->
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## [v15.0.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/v15.0.0) - 2023-06-19

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/v14.0.0...v15.0.0)

### Added

- (CONT-576) allow deferred function for token & secrets [#1569](https://github.com/puppetlabs/puppetlabs-mysql/pull/1569) ([Ramesh7](https://github.com/Ramesh7))

### Changed
- pdksync - (MAINT) - Require Stdlib 9.x [#1572](https://github.com/puppetlabs/puppetlabs-mysql/pull/1572) ([LukasAud](https://github.com/LukasAud))

### Fixed

- Fix broken sensitive parameter for mysql::password [#1564](https://github.com/puppetlabs/puppetlabs-mysql/pull/1564) ([cruelsmith](https://github.com/cruelsmith))

## [v14.0.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/v14.0.0) - 2023-04-17

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/v13.3.0...v14.0.0)

### Changed
- (CONT-789) Add Support for Puppet 8 / Drop Support for Puppet 6 [#1557](https://github.com/puppetlabs/puppetlabs-mysql/pull/1557) ([david22swan](https://github.com/david22swan))

## [v13.3.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/v13.3.0) - 2023-04-11

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/v13.2.0...v13.3.0)

### Added

- mysql::server: Implement reload_on_config_change [#1551](https://github.com/puppetlabs/puppetlabs-mysql/pull/1551) ([bastelfreak](https://github.com/bastelfreak))

### Fixed

- move static data from params to server class [#1552](https://github.com/puppetlabs/puppetlabs-mysql/pull/1552) ([bastelfreak](https://github.com/bastelfreak))

## [v13.2.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/v13.2.0) - 2023-02-24

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/v13.1.0...v13.2.0)

### Added

- (CONT-359) Syntax update [#1532](https://github.com/puppetlabs/puppetlabs-mysql/pull/1532) ([LukasAud](https://github.com/LukasAud))

### Fixed

- xtrabackup.sh only touch when backup_success_file_path is set [#1522](https://github.com/puppetlabs/puppetlabs-mysql/pull/1522) ([JvGinkel](https://github.com/JvGinkel))

## [v13.1.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/v13.1.0) - 2022-12-20

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/v13.0.1...v13.1.0)

### Added

- mysql::db sql parameter support filenames with multiple dots [#1505](https://github.com/puppetlabs/puppetlabs-mysql/pull/1505) ([skn-bvdh](https://github.com/skn-bvdh))

### Fixed

- (GH-1518) Declare minimum Puppet version 6.24.0 [#1519](https://github.com/puppetlabs/puppetlabs-mysql/pull/1519) ([pmcmaw](https://github.com/pmcmaw))
- (GH-1516) Update sql example to use array [#1517](https://github.com/puppetlabs/puppetlabs-mysql/pull/1517) ([pmcmaw](https://github.com/pmcmaw))
- do not emit other ssl directives when ssl = false [#1513](https://github.com/puppetlabs/puppetlabs-mysql/pull/1513) ([kjetilho](https://github.com/kjetilho))
- (GH-1491) Fix for Ubuntu 22.04 [#1508](https://github.com/puppetlabs/puppetlabs-mysql/pull/1508) ([david22swan](https://github.com/david22swan))

## [v13.0.1](https://github.com/puppetlabs/puppetlabs-mysql/tree/v13.0.1) - 2022-10-24

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/v13.0.0...v13.0.1)

### Fixed

- (CONT-173) - Updating deprecated facter instances [#1501](https://github.com/puppetlabs/puppetlabs-mysql/pull/1501) ([jordanbreen28](https://github.com/jordanbreen28))
- pdksync - (CONT-189) Remove support for RedHat6 / OracleLinux6 / Scientific6 [#1498](https://github.com/puppetlabs/puppetlabs-mysql/pull/1498) ([david22swan](https://github.com/david22swan))
- pdksync - (CONT-130) - Dropping Support for Debian 9 [#1495](https://github.com/puppetlabs/puppetlabs-mysql/pull/1495) ([jordanbreen28](https://github.com/jordanbreen28))
- MySQL 8.0: Grant required privileges to xtrabackup user [#1478](https://github.com/puppetlabs/puppetlabs-mysql/pull/1478) ([jan-win1993](https://github.com/jan-win1993))

## [v13.0.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/v13.0.0) - 2022-08-25

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/v12.0.3...v13.0.0)

### Added

- pdksync - (GH-cat-11) Certify Support for Ubuntu 22.04 [#1483](https://github.com/puppetlabs/puppetlabs-mysql/pull/1483) ([david22swan](https://github.com/david22swan))
- [Compatibility] Add Raspbian OS to provider configuration [#1481](https://github.com/puppetlabs/puppetlabs-mysql/pull/1481) ([jordi-upc](https://github.com/jordi-upc))
- Allow excludedatabases when using file_per_database [#1480](https://github.com/puppetlabs/puppetlabs-mysql/pull/1480) ([HT43-bqxFqB](https://github.com/HT43-bqxFqB))
- pdksync - (GH-cat-12) Add Support for Redhat 9 [#1477](https://github.com/puppetlabs/puppetlabs-mysql/pull/1477) ([david22swan](https://github.com/david22swan))

### Changed
- Harden db defined type [#1484](https://github.com/puppetlabs/puppetlabs-mysql/pull/1484) ([chelnak](https://github.com/chelnak))

### Fixed

- Harden config class [#1487](https://github.com/puppetlabs/puppetlabs-mysql/pull/1487) ([chelnak](https://github.com/chelnak))
- Harden service class [#1486](https://github.com/puppetlabs/puppetlabs-mysql/pull/1486) ([chelnak](https://github.com/chelnak))
- Harden root password class [#1485](https://github.com/puppetlabs/puppetlabs-mysql/pull/1485) ([chelnak](https://github.com/chelnak))
- Use MariaDB for Ubuntu 20.04 [#1449](https://github.com/puppetlabs/puppetlabs-mysql/pull/1449) ([treydock](https://github.com/treydock))
- Add support for mariabackup  [#1447](https://github.com/puppetlabs/puppetlabs-mysql/pull/1447) ([rsynnest](https://github.com/rsynnest))

## [v12.0.3](https://github.com/puppetlabs/puppetlabs-mysql/tree/v12.0.3) - 2022-05-25

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/v12.0.2...v12.0.3)

### Fixed

- (IAC-1595) MySQL maintenance [#1472](https://github.com/puppetlabs/puppetlabs-mysql/pull/1472) ([LukasAud](https://github.com/LukasAud))
- Solve issue with repeated restarts if ssl-disable is true [#1425](https://github.com/puppetlabs/puppetlabs-mysql/pull/1425) ([markasammut](https://github.com/markasammut))

## [v12.0.2](https://github.com/puppetlabs/puppetlabs-mysql/tree/v12.0.2) - 2022-04-19

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/v12.0.1...v12.0.2)

### Added

- pdksync - (IAC-1753) - Add Support for AlmaLinux 8 [#1444](https://github.com/puppetlabs/puppetlabs-mysql/pull/1444) ([david22swan](https://github.com/david22swan))
- pdksync - (IAC-1751) - Add Support for Rocky 8 [#1442](https://github.com/puppetlabs/puppetlabs-mysql/pull/1442) ([david22swan](https://github.com/david22swan))

### Fixed

- (Bugfix) Grant privileges idempotency Fix [#1466](https://github.com/puppetlabs/puppetlabs-mysql/pull/1466) ([LukasAud](https://github.com/LukasAud))
- pdksync - (GH-iac-334) Remove Support for Ubuntu 16.04 [#1457](https://github.com/puppetlabs/puppetlabs-mysql/pull/1457) ([david22swan](https://github.com/david22swan))
- pdksync - (IAC-1787) Remove Support for CentOS 6 [#1450](https://github.com/puppetlabs/puppetlabs-mysql/pull/1450) ([david22swan](https://github.com/david22swan))
- add mysql_native_password plugin to authentication_string vs password [#1441](https://github.com/puppetlabs/puppetlabs-mysql/pull/1441) ([Heidistein](https://github.com/Heidistein))
- fix Error: Transaction store file transactionstore.yaml is corrupt [#1429](https://github.com/puppetlabs/puppetlabs-mysql/pull/1429) ([andeman](https://github.com/andeman))
- Combine multiple grants into one while checking state [#1428](https://github.com/puppetlabs/puppetlabs-mysql/pull/1428) ([fuyar](https://github.com/fuyar))

## [v12.0.1](https://github.com/puppetlabs/puppetlabs-mysql/tree/v12.0.1) - 2021-08-26

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/v12.0.0...v12.0.1)

### Fixed

- (IAC-1741) Allow stdlib v8.0.0 [#1433](https://github.com/puppetlabs/puppetlabs-mysql/pull/1433) ([david22swan](https://github.com/david22swan))
- MODULES-8373 Fix mysql_grant resource to be idempodent on MySQL 8+ [#1427](https://github.com/puppetlabs/puppetlabs-mysql/pull/1427) ([theq86](https://github.com/theq86))

## [v12.0.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/v12.0.0) - 2021-07-27

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/v11.1.0...v12.0.0)

### Changed
- Deprecate mysql::server::mysqltuner and show it as an example [#1409](https://github.com/puppetlabs/puppetlabs-mysql/pull/1409) ([ghoneycutt](https://github.com/ghoneycutt))
- Deprecate mysql::server::monitor and show as an example [#1408](https://github.com/puppetlabs/puppetlabs-mysql/pull/1408) ([ghoneycutt](https://github.com/ghoneycutt))
- Remove EOL platforms Debian 8 and Ubuntu 14.04 [#1406](https://github.com/puppetlabs/puppetlabs-mysql/pull/1406) ([ghoneycutt](https://github.com/ghoneycutt))

## [v11.1.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/v11.1.0) - 2021-07-05

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/v11.0.3...v11.1.0)

### Added

- (MODULES-11115) add Rocky Linux 8 compatibility [#1405](https://github.com/puppetlabs/puppetlabs-mysql/pull/1405) ([vchepkov](https://github.com/vchepkov))
- Use Puppet-Datatype Sensitive [#1400](https://github.com/puppetlabs/puppetlabs-mysql/pull/1400) ([cocker-cc](https://github.com/cocker-cc))

### Fixed

- Fix mysql_user parameters update on modern MySQL [#1415](https://github.com/puppetlabs/puppetlabs-mysql/pull/1415) ([weastur](https://github.com/weastur))
- (IAC-1677) Fix issue with deprecated rspec [#1414](https://github.com/puppetlabs/puppetlabs-mysql/pull/1414) ([ghoneycutt](https://github.com/ghoneycutt))
- Fix broken link and style in documentation [#1403](https://github.com/puppetlabs/puppetlabs-mysql/pull/1403) ([ghoneycutt](https://github.com/ghoneycutt))

## [v11.0.3](https://github.com/puppetlabs/puppetlabs-mysql/tree/v11.0.3) - 2021-06-21

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/v11.0.2...v11.0.3)

### Fixed

- (IAC-1430) - Minor docs updating [#1401](https://github.com/puppetlabs/puppetlabs-mysql/pull/1401) ([pmcmaw](https://github.com/pmcmaw))

## [v11.0.2](https://github.com/puppetlabs/puppetlabs-mysql/tree/v11.0.2) - 2021-06-07

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/v11.0.1...v11.0.2)

### Fixed

- (bugfix) - Pull python3-mysqldb in Debian Bullseye [#1396](https://github.com/puppetlabs/puppetlabs-mysql/pull/1396) ([thomasgoirand](https://github.com/thomasgoirand))
- Update xtrabackup package name for Ubuntu 20.04 [#1387](https://github.com/puppetlabs/puppetlabs-mysql/pull/1387) ([rsynnest](https://github.com/rsynnest))

## [v11.0.1](https://github.com/puppetlabs/puppetlabs-mysql/tree/v11.0.1) - 2021-04-19

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/v11.0.0...v11.0.1)

### Fixed

- Fix: Puppet Unknown variable: 'mysql::params::exec_path' [#1378](https://github.com/puppetlabs/puppetlabs-mysql/pull/1378) ([JvGinkel](https://github.com/JvGinkel))
- (IAC-1497) - Removal of unsupported `translate` dependency [#1375](https://github.com/puppetlabs/puppetlabs-mysql/pull/1375) ([david22swan](https://github.com/david22swan))
- (MODULES-10926) Fix Java binding package for Ubuntu 20.04 [#1373](https://github.com/puppetlabs/puppetlabs-mysql/pull/1373) ([treydock](https://github.com/treydock))

## [v11.0.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/v11.0.0) - 2021-03-01

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/v10.10.0...v11.0.0)

### Added

- Support compression command and extension [#1363](https://github.com/puppetlabs/puppetlabs-mysql/pull/1363) ([dploeger](https://github.com/dploeger))

### Changed
- pdksync - Remove Puppet 5 from testing and bump minimal version to 6.0.0 [#1366](https://github.com/puppetlabs/puppetlabs-mysql/pull/1366) ([carabasdaniel](https://github.com/carabasdaniel))

### Fixed

- pdksync - (MAINT) Remove SLES 11 support [#1370](https://github.com/puppetlabs/puppetlabs-mysql/pull/1370) ([sanfrancrisko](https://github.com/sanfrancrisko))
- pdksync - (MAINT) Remove RHEL 5 family support [#1369](https://github.com/puppetlabs/puppetlabs-mysql/pull/1369) ([sanfrancrisko](https://github.com/sanfrancrisko))

## [v10.10.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/v10.10.0) - 2021-02-12

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/v10.9.1...v10.10.0)

### Added

- Set default MySQL version for FreeBSD [#1360](https://github.com/puppetlabs/puppetlabs-mysql/pull/1360) ([olevole](https://github.com/olevole))

## [v10.9.1](https://github.com/puppetlabs/puppetlabs-mysql/tree/v10.9.1) - 2021-01-07

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/v10.9.0...v10.9.1)

### Fixed

- Repair check of logbindir [#1348](https://github.com/puppetlabs/puppetlabs-mysql/pull/1348) ([qha](https://github.com/qha))

## [v10.9.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/v10.9.0) - 2020-12-16

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/v10.8.0...v10.9.0)

### Added

- (FEAT) Add support for Puppet 7 [#1347](https://github.com/puppetlabs/puppetlabs-mysql/pull/1347) ([daianamezdrea](https://github.com/daianamezdrea))
- (IAC-996) Removal of inappropriate terminology [#1340](https://github.com/puppetlabs/puppetlabs-mysql/pull/1340) ([pmcmaw](https://github.com/pmcmaw))

## [v10.8.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/v10.8.0) - 2020-11-04

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/"v10.8.0"...v10.8.0)

## ["v10.8.0"](https://github.com/puppetlabs/puppetlabs-mysql/tree/"v10.8.0") - 2020-11-04

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/v10.7.1..."v10.8.0")

### Added

- Add compatibility for Amazon Linux 2 [#1328](https://github.com/puppetlabs/puppetlabs-mysql/pull/1328) ([greno2](https://github.com/greno2))

### Fixed

- (IAC-1137) Ensure curl package is installed for xtrabackup tests [#1338](https://github.com/puppetlabs/puppetlabs-mysql/pull/1338) ([pmcmaw](https://github.com/pmcmaw))
- (MODULES-10788) - fix for password prompt when creating mysql_login_path resource [#1334](https://github.com/puppetlabs/puppetlabs-mysql/pull/1334) ([andeman](https://github.com/andeman))
- (MODULES-10790) - Setting logbin results in error Unknown variable: 'managed_dirs_path' [#1325](https://github.com/puppetlabs/puppetlabs-mysql/pull/1325) ([pmcmaw](https://github.com/pmcmaw))
- Fix package for python bindings on Ubuntu 20.04 [#1323](https://github.com/puppetlabs/puppetlabs-mysql/pull/1323) ([tobias-urdin](https://github.com/tobias-urdin))

## [v10.7.1](https://github.com/puppetlabs/puppetlabs-mysql/tree/v10.7.1) - 2020-09-28

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/v10.7.0...v10.7.1)

### Fixed

- (IAC-1175) Pin percona-release to version 1.0-22 for Debian 8  [#1329](https://github.com/puppetlabs/puppetlabs-mysql/pull/1329) ([pmcmaw](https://github.com/pmcmaw))
- [MODULES-10773] Fix for rh-mysql80 [#1322](https://github.com/puppetlabs/puppetlabs-mysql/pull/1322) ([carabasdaniel](https://github.com/carabasdaniel))

## [v10.7.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/v10.7.0) - 2020-08-13

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/v10.6.0...v10.7.0)

### Added

- pdksync - (IAC-973) - Update travis/appveyor to run on new default branch `main` [#1316](https://github.com/puppetlabs/puppetlabs-mysql/pull/1316) ([david22swan](https://github.com/david22swan))
- add package provider and source [#1314](https://github.com/puppetlabs/puppetlabs-mysql/pull/1314) ([fe80](https://github.com/fe80))

### Fixed

- Remove non printable characters [#1315](https://github.com/puppetlabs/puppetlabs-mysql/pull/1315) ([elmobp](https://github.com/elmobp))
- Remove control character from manifests/server.pp [#1312](https://github.com/puppetlabs/puppetlabs-mysql/pull/1312) ([tomkrouper](https://github.com/tomkrouper))

## [v10.6.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/v10.6.0) - 2020-06-23

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/v10.5.0...v10.6.0)

### Added

- Handle cron package from different module [#1306](https://github.com/puppetlabs/puppetlabs-mysql/pull/1306) ([ashish1099](https://github.com/ashish1099))
- (IAC-746) - Add ubuntu 20.04 support [#1303](https://github.com/puppetlabs/puppetlabs-mysql/pull/1303) ([david22swan](https://github.com/david22swan))
- (MODULES-1550) add new Feature MySQL login paths [#1295](https://github.com/puppetlabs/puppetlabs-mysql/pull/1295) ([andeman](https://github.com/andeman))

### Fixed

- Add managed_dirs parameter [#1305](https://github.com/puppetlabs/puppetlabs-mysql/pull/1305) ([evgenkisel](https://github.com/evgenkisel))
- change split on whitespace to split on tab in mysql_user [#1233](https://github.com/puppetlabs/puppetlabs-mysql/pull/1233) ([koshatul](https://github.com/koshatul))

## [v10.5.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/v10.5.0) - 2020-05-13

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/v10.4.0...v10.5.0)

### Added

- Support mariadb's ed25519-based authentication [#1292](https://github.com/puppetlabs/puppetlabs-mysql/pull/1292) ([dciabrin](https://github.com/dciabrin))
- Allow changing the mysql-config-file group-ownership [#1284](https://github.com/puppetlabs/puppetlabs-mysql/pull/1284) ([unki](https://github.com/unki))

### Fixed

- Remove legacy (old API) `mysql_password` function [#1299](https://github.com/puppetlabs/puppetlabs-mysql/pull/1299) ([alexjfisher](https://github.com/alexjfisher))
- Improve differences between generated mysql service id values [#1293](https://github.com/puppetlabs/puppetlabs-mysql/pull/1293) ([ryaner](https://github.com/ryaner))
- (MODULES-10023) Fix multiple xtrabackup regressions [#1245](https://github.com/puppetlabs/puppetlabs-mysql/pull/1245) ([fraenki](https://github.com/fraenki))
- Fix binarylog by allowing users to specify managed directories [#1194](https://github.com/puppetlabs/puppetlabs-mysql/pull/1194) ([elfranne](https://github.com/elfranne))

## [v10.4.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/v10.4.0) - 2020-03-03

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/v10.3.0...v10.4.0)

### Added

- Allow adapting MySQL configuration file's permissions mode [#1278](https://github.com/puppetlabs/puppetlabs-mysql/pull/1278) ([unki](https://github.com/unki))
- pdksync - (FM-8581) - Debian 10 added to travis and provision file refactored [#1275](https://github.com/puppetlabs/puppetlabs-mysql/pull/1275) ([david22swan](https://github.com/david22swan))
- Allow backupcompress for xtrabackup profile [#1196](https://github.com/puppetlabs/puppetlabs-mysql/pull/1196) ([Spuffnduff](https://github.com/Spuffnduff))
- Enable module to not use default options [#1192](https://github.com/puppetlabs/puppetlabs-mysql/pull/1192) ([morremeyer](https://github.com/morremeyer))

## [v10.3.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/v10.3.0) - 2019-12-11

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/v10.2.1...v10.3.0)

### Added

- (FM-8677) - Support added for CentOS 8 [#1254](https://github.com/puppetlabs/puppetlabs-mysql/pull/1254) ([david22swan](https://github.com/david22swan))

### Fixed

- Fix java and ruby binding packages for Debian 10 [#1264](https://github.com/puppetlabs/puppetlabs-mysql/pull/1264) ([treydock](https://github.com/treydock))
- (MODULES-10114) Confine fact for only when mysql is in PATH [#1256](https://github.com/puppetlabs/puppetlabs-mysql/pull/1256) ([bFekete](https://github.com/bFekete))

## [v10.2.1](https://github.com/puppetlabs/puppetlabs-mysql/tree/v10.2.1) - 2019-10-31

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/v10.2.0...v10.2.1)

### Fixed

- Fix mysql::sql task error message [#1243](https://github.com/puppetlabs/puppetlabs-mysql/pull/1243) ([alexjfisher](https://github.com/alexjfisher))
- Fix xtrabackup regression introduced in #1207 [#1242](https://github.com/puppetlabs/puppetlabs-mysql/pull/1242) ([fraenki](https://github.com/fraenki))
- Repair mysql_grant docs and diagnostics [#1237](https://github.com/puppetlabs/puppetlabs-mysql/pull/1237) ([qha](https://github.com/qha))

## [v10.2.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/v10.2.0) - 2019-09-24

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/v10.1.0...v10.2.0)

### Added

- FM-8406 add support on Debian10 [#1230](https://github.com/puppetlabs/puppetlabs-mysql/pull/1230) ([lionce](https://github.com/lionce))
- Make backup success file path configurable [#1207](https://github.com/puppetlabs/puppetlabs-mysql/pull/1207) ([HT43-bqxFqB](https://github.com/HT43-bqxFqB))

### Fixed

- No package under FreeBSD [#1227](https://github.com/puppetlabs/puppetlabs-mysql/pull/1227) ([jas01](https://github.com/jas01))
- Fix group on FreeBSD [#1226](https://github.com/puppetlabs/puppetlabs-mysql/pull/1226) ([jas01](https://github.com/jas01))
- Don't run fact when you can't find mysqld [#1224](https://github.com/puppetlabs/puppetlabs-mysql/pull/1224) ([jstewart612](https://github.com/jstewart612))
-  Bugfix on Debian 9 : ruby_package_name must be ruby-mysql2 [#1223](https://github.com/puppetlabs/puppetlabs-mysql/pull/1223) ([leopoiroux](https://github.com/leopoiroux))
- Fix errors for /bin/sh with the xtrabackup cron [#1222](https://github.com/puppetlabs/puppetlabs-mysql/pull/1222) ([baldurmen](https://github.com/baldurmen))
- Fix/fix dependency issue in freebsd with log error file creation from 10.0.0 [#1221](https://github.com/puppetlabs/puppetlabs-mysql/pull/1221) ([rick-pri](https://github.com/rick-pri))

## [v10.1.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/v10.1.0) - 2019-07-31

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/v10.0.0...v10.1.0)

### Added

- Allow backup::mysqldump::time to accept monthday, month, weekday [#1214](https://github.com/puppetlabs/puppetlabs-mysql/pull/1214) ([malakai97](https://github.com/malakai97))

## [v10.0.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/v10.0.0) - 2019-06-26

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/v9.1.0...v10.0.0)

### Added

- add support for rh-mariadb102 [#1209](https://github.com/puppetlabs/puppetlabs-mysql/pull/1209) ([martin-schlossarek](https://github.com/martin-schlossarek))
- Freebsd compat [#1208](https://github.com/puppetlabs/puppetlabs-mysql/pull/1208) ([kapouik](https://github.com/kapouik))

### Fixed

- FM-7982 - update provisioner to docker_exp [#1205](https://github.com/puppetlabs/puppetlabs-mysql/pull/1205) ([lionce](https://github.com/lionce))

## [v9.1.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/v9.1.0) - 2019-06-11

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/v9.0.0...v9.1.0)

### Added

- Add option to specify $backupdir as a symlink target, for use with dm… [#1200](https://github.com/puppetlabs/puppetlabs-mysql/pull/1200) ([comport3](https://github.com/comport3))
- (FM-8029) Add RedHat 8 support [#1199](https://github.com/puppetlabs/puppetlabs-mysql/pull/1199) ([eimlav](https://github.com/eimlav))
- Allow own Xtrabackup script [#1189](https://github.com/puppetlabs/puppetlabs-mysql/pull/1189) ([SaschaDoering](https://github.com/SaschaDoering))
- Litmus conversion [#1175](https://github.com/puppetlabs/puppetlabs-mysql/pull/1175) ([pmcmaw](https://github.com/pmcmaw))

### Fixed

- (MODULES-6875,MODULES-7487) - Fix mariadb mysql_user password idempotency [#1195](https://github.com/puppetlabs/puppetlabs-mysql/pull/1195) ([alexjfisher](https://github.com/alexjfisher))

## [v9.0.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/v9.0.0) - 2019-05-22

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/8.1.0...v9.0.0)

### Added

- Make incremental backups deactivable [#1188](https://github.com/puppetlabs/puppetlabs-mysql/pull/1188) ([SaschaDoering](https://github.com/SaschaDoering))
- Allow multiple backupmethods [#1187](https://github.com/puppetlabs/puppetlabs-mysql/pull/1187) ([SaschaDoering](https://github.com/SaschaDoering))

### Changed
- pdksync - (MODULES-8444) - Raise lower Puppet bound [#1184](https://github.com/puppetlabs/puppetlabs-mysql/pull/1184) ([david22swan](https://github.com/david22swan))

### Fixed

- Fix the contribution guide URL [#1190](https://github.com/puppetlabs/puppetlabs-mysql/pull/1190) ([morremeyer](https://github.com/morremeyer))
- (MODULES-8886) Revert removal of deepmerge function [#1181](https://github.com/puppetlabs/puppetlabs-mysql/pull/1181) ([eimlav](https://github.com/eimlav))
- Fixed Changelog links for 8.1.0 [#1180](https://github.com/puppetlabs/puppetlabs-mysql/pull/1180) ([morremeyer](https://github.com/morremeyer))

## [8.1.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/8.1.0) - 2019-04-03

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/8.0.1...8.1.0)

### Added

- Rotate option for xtrabackup script [#1176](https://github.com/puppetlabs/puppetlabs-mysql/pull/1176) ([elfranne](https://github.com/elfranne))

### Fixed

- (MODULES-6627) Remove unused --host flags from mysqlcaller [#1174](https://github.com/puppetlabs/puppetlabs-mysql/pull/1174) ([david22swan](https://github.com/david22swan))
- Set correct packagename for ruby_mysql on Ubuntu 18.04 [#1163](https://github.com/puppetlabs/puppetlabs-mysql/pull/1163) ([datty](https://github.com/datty))
- [MODULES-8779] Set proper python_package_name for RHEL/CentOS 8 [#1161](https://github.com/puppetlabs/puppetlabs-mysql/pull/1161) ([javierpena](https://github.com/javierpena))
- fix install ordering for innodb data size [#1160](https://github.com/puppetlabs/puppetlabs-mysql/pull/1160) ([fe80](https://github.com/fe80))

## [8.0.1](https://github.com/puppetlabs/puppetlabs-mysql/tree/8.0.1) - 2019-03-20

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/8.0.0...8.0.1)

### Added

- Add support for dynamic backupmethods/mariabackup [#1171](https://github.com/puppetlabs/puppetlabs-mysql/pull/1171) ([danquack](https://github.com/danquack))

### Fixed

- (MODULES-8684) - Removing private tags from Puppet Types [#1170](https://github.com/puppetlabs/puppetlabs-mysql/pull/1170) ([david22swan](https://github.com/david22swan))

## [8.0.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/8.0.0) - 2019-01-23

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/7.0.0...8.0.0)

### Added

- (MODULES-3539) Allow @ in username [#1155](https://github.com/puppetlabs/puppetlabs-mysql/pull/1155) ([Fogelholk](https://github.com/Fogelholk))
- (MODULES-8144) - Add support for SLES 15 [#1146](https://github.com/puppetlabs/puppetlabs-mysql/pull/1146) ([eimlav](https://github.com/eimlav))
- Added support for RHSCL mysql versions and support for .mylogin.cnf for MySQL 5.6.6+ [#1061](https://github.com/puppetlabs/puppetlabs-mysql/pull/1061) ([DJMuggs](https://github.com/DJMuggs))

### Changed
- (MODULES-8193) - Removal of inbuilt deepmerge and dirname functions [#1145](https://github.com/puppetlabs/puppetlabs-mysql/pull/1145) ([david22swan](https://github.com/david22swan))

### Fixed

- (MODULES-8193) - Wrapper methods created for inbuilt 4.x functions [#1151](https://github.com/puppetlabs/puppetlabs-mysql/pull/1151) ([david22swan](https://github.com/david22swan))
- pdksync - (FM-7655) Fix rubygems-update for ruby < 2.3 [#1150](https://github.com/puppetlabs/puppetlabs-mysql/pull/1150) ([tphoney](https://github.com/tphoney))
- Add includedir for Gentoo [#1147](https://github.com/puppetlabs/puppetlabs-mysql/pull/1147) ([baurmatt](https://github.com/baurmatt))
- add mysql_native_password for mariadb 10.2 in password_hash [#1117](https://github.com/puppetlabs/puppetlabs-mysql/pull/1117) ([mlk-89](https://github.com/mlk-89))
- Removing query_cache ops that are no longer supported in MySQL >= 8.0 [#1107](https://github.com/puppetlabs/puppetlabs-mysql/pull/1107) ([ernstae](https://github.com/ernstae))

## [7.0.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/7.0.0) - 2018-10-25

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/6.2.0...7.0.0)

### Added

- (MODULES-7857) Support user creation on galera [#1130](https://github.com/puppetlabs/puppetlabs-mysql/pull/1130) ([MaxFedotov](https://github.com/MaxFedotov))
- MySQL 8 compatibility in user management [#1092](https://github.com/puppetlabs/puppetlabs-mysql/pull/1092) ([zpetr](https://github.com/zpetr))

### Changed
- (MODULES-6923) remove staging module [#1115](https://github.com/puppetlabs/puppetlabs-mysql/pull/1115) ([tphoney](https://github.com/tphoney))

### Fixed

- (MODULES-7487) Check authentication string for user password on MariaDB 10.2.16+ [#1135](https://github.com/puppetlabs/puppetlabs-mysql/pull/1135) ([gguillotte](https://github.com/gguillotte))

## [6.2.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/6.2.0) - 2018-09-28

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/6.1.0...6.2.0)

### Added

- pdksync - (MODULES-6805) metadata.json shows support for puppet 6 [#1127](https://github.com/puppetlabs/puppetlabs-mysql/pull/1127) ([tphoney](https://github.com/tphoney))

### Fixed

- (maint) - Change versioning comparison [#1123](https://github.com/puppetlabs/puppetlabs-mysql/pull/1123) ([eimlav](https://github.com/eimlav))

## [6.1.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/6.1.0) - 2018-09-13

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/6.0.0...6.1.0)

### Fixed

- pdksync - (MODULES-7705) - Bumping stdlib dependency from < 5.0.0 to < 6.0.0 [#1114](https://github.com/puppetlabs/puppetlabs-mysql/pull/1114) ([pmcmaw](https://github.com/pmcmaw))
- (MODULES-6981) Do not try to read ~root/.my.cnf when calling "mysqld -V" [#1063](https://github.com/puppetlabs/puppetlabs-mysql/pull/1063) ([simondeziel](https://github.com/simondeziel))

## [6.0.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/6.0.0) - 2018-08-02

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/5.4.0...6.0.0)

### Added

- (FM-5985) - Addition of support for Ubuntu 18.04 to mysql [#1104](https://github.com/puppetlabs/puppetlabs-mysql/pull/1104) ([david22swan](https://github.com/david22swan))
- (MODULES-7439) - Implementing beaker-testmode_switcher [#1095](https://github.com/puppetlabs/puppetlabs-mysql/pull/1095) ([pmcmaw](https://github.com/pmcmaw))
- Support for optional__args and prescript to mysqldump backup provider [#1083](https://github.com/puppetlabs/puppetlabs-mysql/pull/1083) ([eputnam](https://github.com/eputnam))
- Allow empty user passwords [#1075](https://github.com/puppetlabs/puppetlabs-mysql/pull/1075) ([ThoTischner](https://github.com/ThoTischner))
- Add user tls_options and grant options to mysql::db [#1065](https://github.com/puppetlabs/puppetlabs-mysql/pull/1065) ([edestecd](https://github.com/edestecd))
- Use puppet4 functions-api [#1044](https://github.com/puppetlabs/puppetlabs-mysql/pull/1044) ([juliantodt](https://github.com/juliantodt))

### Changed
- [FM-6962] Removal of unsupported OS from mysql [#1086](https://github.com/puppetlabs/puppetlabs-mysql/pull/1086) ([david22swan](https://github.com/david22swan))

### Fixed

- (MODULES-7353) Enable service for Debian 9  [#1094](https://github.com/puppetlabs/puppetlabs-mysql/pull/1094) ([david22swan](https://github.com/david22swan))
- Update locales test for Debian 9 [#1091](https://github.com/puppetlabs/puppetlabs-mysql/pull/1091) ([HelenCampbell](https://github.com/HelenCampbell))
- [FM-7045] Fix to allow Debian 9 test's to run clean [#1088](https://github.com/puppetlabs/puppetlabs-mysql/pull/1088) ([david22swan](https://github.com/david22swan))
- (MODULES-7198) Fix DROP USER IF EXISTS on mariadb [#1082](https://github.com/puppetlabs/puppetlabs-mysql/pull/1082) ([hunner](https://github.com/hunner))

## [5.4.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/5.4.0) - 2018-05-23

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/5.3.0...5.4.0)

### Added

- (PDOC-210) add Puppet Strings documentation [#1068](https://github.com/puppetlabs/puppetlabs-mysql/pull/1068) ([hunner](https://github.com/hunner))
- (PDOC-210) add Puppet Strings documentation [#1062](https://github.com/puppetlabs/puppetlabs-mysql/pull/1062) ([eputnam](https://github.com/eputnam))
- (MODULES-5618) Hide logging of password_hash changes in mysql::user [#993](https://github.com/puppetlabs/puppetlabs-mysql/pull/993) ([jhriggs](https://github.com/jhriggs))
- Replaced 'DROP USER' with 'DROP USER IF EXISTS' [#942](https://github.com/puppetlabs/puppetlabs-mysql/pull/942) ([xelmido](https://github.com/xelmido))

### Fixed

- (MODULES-6627) Removes unused --host flag from mysqlcaller [#1064](https://github.com/puppetlabs/puppetlabs-mysql/pull/1064) ([HelenCampbell](https://github.com/HelenCampbell))
- fix archlinux compatibility [#1057](https://github.com/puppetlabs/puppetlabs-mysql/pull/1057) ([bastelfreak](https://github.com/bastelfreak))
- changed input param option in export.json from sql to file [#1054](https://github.com/puppetlabs/puppetlabs-mysql/pull/1054) ([cgoswami](https://github.com/cgoswami))
- PROCESS is now required [#958](https://github.com/puppetlabs/puppetlabs-mysql/pull/958) ([elmobp](https://github.com/elmobp))

## [5.3.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/5.3.0) - 2018-02-20

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/5.2.1...5.3.0)

## [5.2.1](https://github.com/puppetlabs/puppetlabs-mysql/tree/5.2.1) - 2018-02-02

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/5.2.0...5.2.1)

## [5.2.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/5.2.0) - 2018-01-19

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/5.1.0...5.2.0)

### Added

- (MODULES-4794) Add paths for RHSC [#1039](https://github.com/puppetlabs/puppetlabs-mysql/pull/1039) ([hunner](https://github.com/hunner))
- (MODULES-3623) Centralise MySQL calls... [#1036](https://github.com/puppetlabs/puppetlabs-mysql/pull/1036) ([hunner](https://github.com/hunner))
- #puppethack allow undef value for bind-address [#1035](https://github.com/puppetlabs/puppetlabs-mysql/pull/1035) ([JvGinkel](https://github.com/JvGinkel))
- Add Export database task [#1018](https://github.com/puppetlabs/puppetlabs-mysql/pull/1018) ([slenky](https://github.com/slenky))
- Add support for `GRANTS FUNCTION` [#1005](https://github.com/puppetlabs/puppetlabs-mysql/pull/1005) ([joshuaspence](https://github.com/joshuaspence))
- Allow authentication plugin to be changed [#1004](https://github.com/puppetlabs/puppetlabs-mysql/pull/1004) ([joshuaspence](https://github.com/joshuaspence))

### Changed
- (maint) - Removing Debian 9 [#1020](https://github.com/puppetlabs/puppetlabs-mysql/pull/1020) ([pmcmaw](https://github.com/pmcmaw))

## [5.1.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/5.1.0) - 2017-10-11

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/5.0.0...5.1.0)

## [5.0.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/5.0.0) - 2017-10-05

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/4.0.1...5.0.0)

### Added

- Updating PO file to match strings in POT file and code base. [#1010](https://github.com/puppetlabs/puppetlabs-mysql/pull/1010) ([pmcmaw](https://github.com/pmcmaw))

### Fixed

- refactor php_package_name default for Debian/Ubuntu [#969](https://github.com/puppetlabs/puppetlabs-mysql/pull/969) ([mmoll](https://github.com/mmoll))

## [4.0.1](https://github.com/puppetlabs/puppetlabs-mysql/tree/4.0.1) - 2017-09-09

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/4.0.0...4.0.1)

### Added

- (MODULES-5528) mysql_install_db change to optional [#990](https://github.com/puppetlabs/puppetlabs-mysql/pull/990) ([HelenCampbell](https://github.com/HelenCampbell))

### Fixed

- (MODULES-5602) remove superfluous backslashes from regular expressions [#989](https://github.com/puppetlabs/puppetlabs-mysql/pull/989) ([DavidS](https://github.com/DavidS))

## [4.0.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/4.0.0) - 2017-09-07

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/3.11.0...4.0.0)

### Changed
- replace validate_* with datatypes in db.pp [#930](https://github.com/puppetlabs/puppetlabs-mysql/pull/930) ([bastelfreak](https://github.com/bastelfreak))

### Fixed

- MODULES-5405 interpolation for puppet strings [#984](https://github.com/puppetlabs/puppetlabs-mysql/pull/984) ([tphoney](https://github.com/tphoney))
- interpolation for ruby & puppet code. [#983](https://github.com/puppetlabs/puppetlabs-mysql/pull/983) ([tphoney](https://github.com/tphoney))
- Updated pot file, decorated simple strings [#978](https://github.com/puppetlabs/puppetlabs-mysql/pull/978) ([tphoney](https://github.com/tphoney))
- Fixing empty user/password issue [#972](https://github.com/puppetlabs/puppetlabs-mysql/pull/972) ([ajardan](https://github.com/ajardan))
- (MODULES-4604) move name validation in mysql_grant type [#961](https://github.com/puppetlabs/puppetlabs-mysql/pull/961) ([eputnam](https://github.com/eputnam))
- (MODULES-4115) Invalid parameter provider on Mysql_user[user@localhost] in mysql::db [#912](https://github.com/puppetlabs/puppetlabs-mysql/pull/912) ([ryanb-hc](https://github.com/ryanb-hc))

## [3.11.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/3.11.0) - 2017-05-08

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/3.10.0...3.11.0)

### Added

- (#4534) Add PROXY grant support to mysql_grant [#934](https://github.com/puppetlabs/puppetlabs-mysql/pull/934) ([jhriggs](https://github.com/jhriggs))
- Add a file in /tmp to check when the last backup was successful [#907](https://github.com/puppetlabs/puppetlabs-mysql/pull/907) ([ampersand8](https://github.com/ampersand8))

### Fixed

- Do not wait for mysql socket to open if service_ensure is stopped [#948](https://github.com/puppetlabs/puppetlabs-mysql/pull/948) ([sw0x2A](https://github.com/sw0x2A))
- (MODULES-4743) mysql : cannot initialize database dir not empty [#945](https://github.com/puppetlabs/puppetlabs-mysql/pull/945) ([shawnferry](https://github.com/shawnferry))
- Only install bzip2 if backupcompress [#933](https://github.com/puppetlabs/puppetlabs-mysql/pull/933) ([edestecd](https://github.com/edestecd))
- Use gfind on solaris [#920](https://github.com/puppetlabs/puppetlabs-mysql/pull/920) ([marvin0815](https://github.com/marvin0815))

### Other

- Enhancements to xtrabackup backup provider [#902](https://github.com/puppetlabs/puppetlabs-mysql/pull/902) ([fraenki](https://github.com/fraenki))

## [3.10.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/3.10.0) - 2016-11-07

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/3.9.0...3.10.0)

### Added

- Add support for setting tls options for mysql_user's [#896](https://github.com/puppetlabs/puppetlabs-mysql/pull/896) ([JAORMX](https://github.com/JAORMX))
- MODULES-3907 Add MySQL/Percona 5.7 initialize on fresh deploy [#892](https://github.com/puppetlabs/puppetlabs-mysql/pull/892) ([QuentinMoss](https://github.com/QuentinMoss))
- Add support for REQUIRE SSL|X509 option [#888](https://github.com/puppetlabs/puppetlabs-mysql/pull/888) ([edestecd](https://github.com/edestecd))

### Fixed

- Revert "Add support for REQUIRE SSL|X509 option" [#895](https://github.com/puppetlabs/puppetlabs-mysql/pull/895) ([hunner](https://github.com/hunner))
- fixes problem with package name change from php5-mysql to php-mysql on 16.04 [#889](https://github.com/puppetlabs/puppetlabs-mysql/pull/889) ([ppouliot](https://github.com/ppouliot))

### Other

- Added parameter import_cat_cmd [#891](https://github.com/puppetlabs/puppetlabs-mysql/pull/891) ([jkroepke](https://github.com/jkroepke))

## [3.9.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/3.9.0) - 2016-09-06

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/3.8.0...3.9.0)

### Added

- (MODULES-3698) Updates defaults for SLES12 [#881](https://github.com/puppetlabs/puppetlabs-mysql/pull/881) ([bmjen](https://github.com/bmjen))
- MODULES-3711 - Add limit to mysql server ID generated value [#872](https://github.com/puppetlabs/puppetlabs-mysql/pull/872) ([QuentinMoss](https://github.com/QuentinMoss))
- parametrize xtradb package name [#860](https://github.com/puppetlabs/puppetlabs-mysql/pull/860) ([ndelic0](https://github.com/ndelic0))
- add new backup dump parameter maxallowedpacket [#856](https://github.com/puppetlabs/puppetlabs-mysql/pull/856) ([cfasnacht](https://github.com/cfasnacht))
- [MODULES-3441] Discover mysql version using facts [#852](https://github.com/puppetlabs/puppetlabs-mysql/pull/852) ([jtopper](https://github.com/jtopper))

### Fixed

- revoking GRANT privilege fix [#880](https://github.com/puppetlabs/puppetlabs-mysql/pull/880) ([bodik](https://github.com/bodik))
- Ensure that error log is writable by owner [#877](https://github.com/puppetlabs/puppetlabs-mysql/pull/877) ([runejuhl](https://github.com/runejuhl))
- MODULES-3697 Changed puppet fail behaviour for mysql create user and grant if user name is longer than 16 chars [#871](https://github.com/puppetlabs/puppetlabs-mysql/pull/871) ([dn1s](https://github.com/dn1s))
- (MODULES-3401) Fix for mysql version retrieval [#869](https://github.com/puppetlabs/puppetlabs-mysql/pull/869) ([HelenCampbell](https://github.com/HelenCampbell))
- MODULES-3601 Move binary logging configuration to take place after pa… [#868](https://github.com/puppetlabs/puppetlabs-mysql/pull/868) ([QuentinMoss](https://github.com/QuentinMoss))
- Resource fails when fqdn is not set. [#853](https://github.com/puppetlabs/puppetlabs-mysql/pull/853) ([ragonlan](https://github.com/ragonlan))
- Fix global parameter usage in backup script [#840](https://github.com/puppetlabs/puppetlabs-mysql/pull/840) ([HT43-bqxFqB](https://github.com/HT43-bqxFqB))

## [3.8.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/3.8.0) - 2016-05-31

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/3.7.0...3.8.0)

### Added

- Support mysql_install_db script on Gentoo [#838](https://github.com/puppetlabs/puppetlabs-mysql/pull/838) ([glorpen](https://github.com/glorpen))
- (MODULES-2111) Add the system database to user related actions. [#830](https://github.com/puppetlabs/puppetlabs-mysql/pull/830) ([fvanboven](https://github.com/fvanboven))
- Added bzip2 package support on mysqldump backup [#827](https://github.com/puppetlabs/puppetlabs-mysql/pull/827) ([lcrisci](https://github.com/lcrisci))

### Fixed

- Revert "Use mariadb by default for Debian Jessie (#845)" [#847](https://github.com/puppetlabs/puppetlabs-mysql/pull/847) ([DavidS](https://github.com/DavidS))
-  Find MySQL 5.5 installation on CentOS [#842](https://github.com/puppetlabs/puppetlabs-mysql/pull/842) ([jjagodzinski](https://github.com/jjagodzinski))
- Fixed an issue with Amazon linux major release 4 installation [#837](https://github.com/puppetlabs/puppetlabs-mysql/pull/837) ([megianni](https://github.com/megianni))
- default group for logfiles on Debian/Ubuntu should be adm [#836](https://github.com/puppetlabs/puppetlabs-mysql/pull/836) ([fschndr](https://github.com/fschndr))
- Check that /var/lib/mysql actually contains files. [#834](https://github.com/puppetlabs/puppetlabs-mysql/pull/834) ([jonnytdevops](https://github.com/jonnytdevops))
- move out $options['mysqld']['log-error'] from service.pp into installdb.pp [#833](https://github.com/puppetlabs/puppetlabs-mysql/pull/833) ([ndelic0](https://github.com/ndelic0))
- make sure we find mysqld on FreeBSD [#831](https://github.com/puppetlabs/puppetlabs-mysql/pull/831) ([fraenki](https://github.com/fraenki))
- remove erroneous anchors to mysql::client from mysql::db [#829](https://github.com/puppetlabs/puppetlabs-mysql/pull/829) ([vicinus](https://github.com/vicinus))
- Remove mysql regex when checking type [#828](https://github.com/puppetlabs/puppetlabs-mysql/pull/828) ([s-t-e-v-e-n-k](https://github.com/s-t-e-v-e-n-k))
- Default mysqld_type should be "mysql" [#824](https://github.com/puppetlabs/puppetlabs-mysql/pull/824) ([ih84ds](https://github.com/ih84ds))
- (FM-5050) Configure the base of includedir [#821](https://github.com/puppetlabs/puppetlabs-mysql/pull/821) ([DavidS](https://github.com/DavidS))
- (MODULES-1256) Fix parameters on OpenSUSE 12 [#820](https://github.com/puppetlabs/puppetlabs-mysql/pull/820) ([hunner](https://github.com/hunner))
- Remove mysql_table_exists() function [#815](https://github.com/puppetlabs/puppetlabs-mysql/pull/815) ([hunner](https://github.com/hunner))
- Config before install [#813](https://github.com/puppetlabs/puppetlabs-mysql/pull/813) ([tomkrouper](https://github.com/tomkrouper))
- Loosen MariaDB recognition to fix it on Debian 8 [#812](https://github.com/puppetlabs/puppetlabs-mysql/pull/812) ([koubas](https://github.com/koubas))
- Fixed global parameters skipped [#811](https://github.com/puppetlabs/puppetlabs-mysql/pull/811) ([pashamesh](https://github.com/pashamesh))
- Use mysql_install_db only with uniq defaults-extra-file [#809](https://github.com/puppetlabs/puppetlabs-mysql/pull/809) ([mmalchuk](https://github.com/mmalchuk))

## [3.7.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/3.7.0) - 2016-03-11

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/3.6.2...3.7.0)

### Added

- Ubuntu vivid should use systemd not upstart [#769](https://github.com/puppetlabs/puppetlabs-mysql/pull/769) ([gabriel403](https://github.com/gabriel403))

### Fixed

- (#3028) Fix mysql_grant with MySQL ANSI_QUOTES mode [#796](https://github.com/puppetlabs/puppetlabs-mysql/pull/796) ([jhriggs](https://github.com/jhriggs))
- Re-Add the ability to set a empty string as option parameter [#791](https://github.com/puppetlabs/puppetlabs-mysql/pull/791) ([roidelapluie](https://github.com/roidelapluie))
- (MODULES-2676) Fixed new mysql_datadir provider on CentOS for MySQl 5.7.6 compatibility [#789](https://github.com/puppetlabs/puppetlabs-mysql/pull/789) ([elconas](https://github.com/elconas))
- Fixing error when disabling service management and the service does not exist [#787](https://github.com/puppetlabs/puppetlabs-mysql/pull/787) ([obi11235](https://github.com/obi11235))
- ensure if service restart to wait till mysql is up [#784](https://github.com/puppetlabs/puppetlabs-mysql/pull/784) ([vicinus](https://github.com/vicinus))
- Fixes edge-case with dropping pre-existing users with grants [#779](https://github.com/puppetlabs/puppetlabs-mysql/pull/779) ([jmcclell](https://github.com/jmcclell))

## [3.6.2](https://github.com/puppetlabs/puppetlabs-mysql/tree/3.6.2) - 2015-12-04

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/3.6.1...3.6.2)

### Added

- MODULES-2650 Add support for renamed password column [#760](https://github.com/puppetlabs/puppetlabs-mysql/pull/760) ([roman-mueller](https://github.com/roman-mueller))

### Fixed

- Use temp cnf file instead of env variable. [#778](https://github.com/puppetlabs/puppetlabs-mysql/pull/778) ([mentat](https://github.com/mentat))
- (MODULES-2767) fix mysql_table_exists: add check for args.size, fix rspec test [#777](https://github.com/puppetlabs/puppetlabs-mysql/pull/777) ([agadelshin](https://github.com/agadelshin))
- (MODULES-2767) allow to check if table exists before grant [#776](https://github.com/puppetlabs/puppetlabs-mysql/pull/776) ([agadelshin](https://github.com/agadelshin))
- (MODULES-2605) Use MYSQL_PWD to avoid mysqldump warnings. [#775](https://github.com/puppetlabs/puppetlabs-mysql/pull/775) ([abednarik](https://github.com/abednarik))
- (MODULES-2787) Fixes for future parser [#773](https://github.com/puppetlabs/puppetlabs-mysql/pull/773) ([paco0x](https://github.com/paco0x))
- (MODULES-2490) correct the daemon_dev_package_name for mariadb on redhat [#768](https://github.com/puppetlabs/puppetlabs-mysql/pull/768) ([DavidS](https://github.com/DavidS))
- Fixes unique server_id within my.cnf Ticket/MODULES-2675 [#767](https://github.com/puppetlabs/puppetlabs-mysql/pull/767) ([jkarns87](https://github.com/jkarns87))
- (MODULES-2683) fix version compare to properly suppress show_diff for… [#766](https://github.com/puppetlabs/puppetlabs-mysql/pull/766) ([DavidS](https://github.com/DavidS))

### Other

- Using mariadb in OpenSuSE >= 13.1. [#572](https://github.com/puppetlabs/puppetlabs-mysql/pull/572) ([sharumpe](https://github.com/sharumpe))

## [3.6.1](https://github.com/puppetlabs/puppetlabs-mysql/tree/3.6.1) - 2015-09-22

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/3.6.0...3.6.1)

### Fixed

- Fix when not managing config file [#751](https://github.com/puppetlabs/puppetlabs-mysql/pull/751) ([mcanevet](https://github.com/mcanevet))
- Fixes improper use of function 'warn' in backup manifest of server. [#749](https://github.com/puppetlabs/puppetlabs-mysql/pull/749) ([Herr-Herner](https://github.com/Herr-Herner))

## [3.6.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/3.6.0) - 2015-08-11

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/3.5.0...3.6.0)

### Added

- (MODULES-2340) Implement script functionality for xtrabackup provider [#744](https://github.com/puppetlabs/puppetlabs-mysql/pull/744) ([danzilio](https://github.com/danzilio))

### Fixed

- (PUP-5021) depend on package title, not name [#746](https://github.com/puppetlabs/puppetlabs-mysql/pull/746) ([hunner](https://github.com/hunner))
- #2030 Only establish dependency between service and package if package is managed. [#745](https://github.com/puppetlabs/puppetlabs-mysql/pull/745) ([jonnytdevops](https://github.com/jonnytdevops))
- Fix show_diff already set on .my.cnf [#743](https://github.com/puppetlabs/puppetlabs-mysql/pull/743) ([michaeltchapman](https://github.com/michaeltchapman))
- Ensure idempotency between Puppet runs [#742](https://github.com/puppetlabs/puppetlabs-mysql/pull/742) ([EmilienM](https://github.com/EmilienM))
- Dont print root [#739](https://github.com/puppetlabs/puppetlabs-mysql/pull/739) ([hunner](https://github.com/hunner))
- [#puppethack] do not require mysql::server when using mysql::db [#736](https://github.com/puppetlabs/puppetlabs-mysql/pull/736) ([igalic](https://github.com/igalic))
- Remove default install root password if set [#682](https://github.com/puppetlabs/puppetlabs-mysql/pull/682) ([JCotton1123](https://github.com/JCotton1123))

## [3.5.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/3.5.0) - 2015-07-29

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/3.4.0...3.5.0)

### Added

- Add Solaris support to MySQL module [#729](https://github.com/puppetlabs/puppetlabs-mysql/pull/729) ([drewfisher314](https://github.com/drewfisher314))
- Add helper to install puppet/pe/puppet-agent [#725](https://github.com/puppetlabs/puppetlabs-mysql/pull/725) ([hunner](https://github.com/hunner))
- length check for usernames should take mysql version into consideration [#722](https://github.com/puppetlabs/puppetlabs-mysql/pull/722) ([igalic](https://github.com/igalic))

### Fixed

- Don't explode if macaddress isn't set [#730](https://github.com/puppetlabs/puppetlabs-mysql/pull/730) ([binford2k](https://github.com/binford2k))
- fix Evaluation Error with future parser [#728](https://github.com/puppetlabs/puppetlabs-mysql/pull/728) ([timogoebel](https://github.com/timogoebel))
- (MODULES-2077) Fixes wrong dependency variable [#719](https://github.com/puppetlabs/puppetlabs-mysql/pull/719) ([Spredzy](https://github.com/Spredzy))
- Fixed server package name so it isn't hardcoded to mysql [#718](https://github.com/puppetlabs/puppetlabs-mysql/pull/718) ([igalic](https://github.com/igalic))

## [3.4.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/3.4.0) - 2015-05-19

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/3.3.0...3.4.0)

### Added

- Added options for including/excluding triggers and routines to the mysql::server::backup module [#705](https://github.com/puppetlabs/puppetlabs-mysql/pull/705) ([stevesaliman](https://github.com/stevesaliman))
- Adds default values for parameters and align assignments [#699](https://github.com/puppetlabs/puppetlabs-mysql/pull/699) ([melan](https://github.com/melan))
- Added server_id fact [#676](https://github.com/puppetlabs/puppetlabs-mysql/pull/676) ([igalic](https://github.com/igalic))
- Add OpenBSD support. [#567](https://github.com/puppetlabs/puppetlabs-mysql/pull/567) ([buzzdeee](https://github.com/buzzdeee))

### Fixed

- update to proper defaults for freebsd [#712](https://github.com/puppetlabs/puppetlabs-mysql/pull/712) ([sethlyons](https://github.com/sethlyons))
- (fix) - Change default for mysql::server::backup to ignore_triggers =… [#711](https://github.com/puppetlabs/puppetlabs-mysql/pull/711) ([cyberious](https://github.com/cyberious))
- (fix) - Fix issue where fact is unknown at start - Resolve issue where if known and failed versioncmp would result in idempotency issue on second run [#709](https://github.com/puppetlabs/puppetlabs-mysql/pull/709) ([cyberious](https://github.com/cyberious))
- MODULES-1981: Revoke and grant difference of old and new privileges [#706](https://github.com/puppetlabs/puppetlabs-mysql/pull/706) ([agadelshin](https://github.com/agadelshin))
- Bugfix on Xtrabackup crons [#700](https://github.com/puppetlabs/puppetlabs-mysql/pull/700) ([mvisonneau](https://github.com/mvisonneau))
- fix FreeBSD support for backups [#697](https://github.com/puppetlabs/puppetlabs-mysql/pull/697) ([fraenki](https://github.com/fraenki))
- Fix regression introduced by adding OpenBSD support. [#691](https://github.com/puppetlabs/puppetlabs-mysql/pull/691) ([buzzdeee](https://github.com/buzzdeee))
- Manage service only if managed [#688](https://github.com/puppetlabs/puppetlabs-mysql/pull/688) ([mremy](https://github.com/mremy))
- mysql backup: fix regression in mysql_user call [#687](https://github.com/puppetlabs/puppetlabs-mysql/pull/687) ([igalic](https://github.com/igalic))
- Only set up ordering between the config file and the service if we're managing the config file. [#672](https://github.com/puppetlabs/puppetlabs-mysql/pull/672) ([timmooney](https://github.com/timmooney))

### Other

- (fix) - Check for mysql_verison before assuming that triggers are a valid permission [#708](https://github.com/puppetlabs/puppetlabs-mysql/pull/708) ([cyberious](https://github.com/cyberious))

## [3.3.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/3.3.0) - 2015-03-03

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/3.2.0...3.3.0)

### Added

- (MODULES-1804) Allow override of log-error [#678](https://github.com/puppetlabs/puppetlabs-mysql/pull/678) ([hunner](https://github.com/hunner))
- Use backup providers [#649](https://github.com/puppetlabs/puppetlabs-mysql/pull/649) ([dveeden](https://github.com/dveeden))
- (MODULES-1143) Add package_manage parameters [#617](https://github.com/puppetlabs/puppetlabs-mysql/pull/617) ([juniorsysadmin](https://github.com/juniorsysadmin))

### Fixed

- PR 654 was incorrectly using stdlib dirname [#677](https://github.com/puppetlabs/puppetlabs-mysql/pull/677) ([underscorgan](https://github.com/underscorgan))
- Fix bug in 578 [#671](https://github.com/puppetlabs/puppetlabs-mysql/pull/671) ([aldavud](https://github.com/aldavud))
- Check for full path for log-bin to stop puppet from managing directory “." [#654](https://github.com/puppetlabs/puppetlabs-mysql/pull/654) ([NoodlesNZ](https://github.com/NoodlesNZ))

## [3.2.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/3.2.0) - 2015-02-10

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/3.1.0...3.2.0)

### Added

- Support authentication plugins [#645](https://github.com/puppetlabs/puppetlabs-mysql/pull/645) ([dveeden](https://github.com/dveeden))
- Add type & provider for managing plugins [#641](https://github.com/puppetlabs/puppetlabs-mysql/pull/641) ([dveeden](https://github.com/dveeden))
- Support for authentication plugins [#640](https://github.com/puppetlabs/puppetlabs-mysql/pull/640) ([dveeden](https://github.com/dveeden))
- mysql_install_db freebsd support [#616](https://github.com/puppetlabs/puppetlabs-mysql/pull/616) ([takumin](https://github.com/takumin))
- Add new parameters create_root_user and create_root_my_cnf. [#578](https://github.com/puppetlabs/puppetlabs-mysql/pull/578) ([franzs](https://github.com/franzs))

### Fixed

- MODULES-1759: Remove dependency on stdlib >=4.1.0 [#661](https://github.com/puppetlabs/puppetlabs-mysql/pull/661) ([underscorgan](https://github.com/underscorgan))
- Bugfix: increase minimum stdlib [#660](https://github.com/puppetlabs/puppetlabs-mysql/pull/660) ([hunner](https://github.com/hunner))
- Make grant autorequire user [#658](https://github.com/puppetlabs/puppetlabs-mysql/pull/658) ([hunner](https://github.com/hunner))
- Revert "(#MODULES-1058) root_password.pp cannot create /root/.my.cnf due... [#656](https://github.com/puppetlabs/puppetlabs-mysql/pull/656) ([cyberious](https://github.com/cyberious))
- (MODULES-1731) Invalid parameter 'provider' removed from mysql_user instance. [#655](https://github.com/puppetlabs/puppetlabs-mysql/pull/655) ([rnelson0](https://github.com/rnelson0))
- (#MODULES-1058) root_password.pp cannot create /root/.my.cnf due to depe... [#651](https://github.com/puppetlabs/puppetlabs-mysql/pull/651) ([lodgenbd](https://github.com/lodgenbd))
- Return an empty string for an empty input. [#646](https://github.com/puppetlabs/puppetlabs-mysql/pull/646) ([dveeden](https://github.com/dveeden))
- Revert "Support for authentication plugins" [#644](https://github.com/puppetlabs/puppetlabs-mysql/pull/644) ([cmurphy](https://github.com/cmurphy))
- Make sure the example is somewhat secure [#638](https://github.com/puppetlabs/puppetlabs-mysql/pull/638) ([dveeden](https://github.com/dveeden))
- Do the right thing when fqdn==localhost [#637](https://github.com/puppetlabs/puppetlabs-mysql/pull/637) ([dveeden](https://github.com/dveeden))
- Future parser fix in params.pp [#632](https://github.com/puppetlabs/puppetlabs-mysql/pull/632) ([underscorgan](https://github.com/underscorgan))
- under Debian 8 package name for ruby mysql biding is called ruby-mysql, ... [#629](https://github.com/puppetlabs/puppetlabs-mysql/pull/629) ([Zouuup](https://github.com/Zouuup))
- ensure mysql-config-file and server package is in place before trying to... [#615](https://github.com/puppetlabs/puppetlabs-mysql/pull/615) ([KlavsKlavsen](https://github.com/KlavsKlavsen))

## [3.1.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/3.1.0) - 2014-12-16

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/3.0.0...3.1.0)

### Added

- (MODULES-1338) Allow mysql::db to import several files [#574](https://github.com/puppetlabs/puppetlabs-mysql/pull/574) ([Spredzy](https://github.com/Spredzy))

### Fixed

- Remove mysqltuner, fetch with staging instead [#624](https://github.com/puppetlabs/puppetlabs-mysql/pull/624) ([underscorgan](https://github.com/underscorgan))
- Fix issues introduced in puppetlabs/puppetlabs-mysql#612 [#623](https://github.com/puppetlabs/puppetlabs-mysql/pull/623) ([underscorgan](https://github.com/underscorgan))
- Use puppet() instead of shell() to install module dependencies [#622](https://github.com/puppetlabs/puppetlabs-mysql/pull/622) ([underscorgan](https://github.com/underscorgan))
- Reworked all identifier quoting detections [#612](https://github.com/puppetlabs/puppetlabs-mysql/pull/612) ([lavoiesl](https://github.com/lavoiesl))
- Fix operating system release fact for SLES [#611](https://github.com/puppetlabs/puppetlabs-mysql/pull/611) ([cmurphy](https://github.com/cmurphy))
- Fix support for SLES 12 [#610](https://github.com/puppetlabs/puppetlabs-mysql/pull/610) ([cmurphy](https://github.com/cmurphy))
- Default to MariaDB for SLES 12 [#608](https://github.com/puppetlabs/puppetlabs-mysql/pull/608) ([cyberious](https://github.com/cyberious))
- Proper containment for mysql::client in mysql::db [#605](https://github.com/puppetlabs/puppetlabs-mysql/pull/605) ([slamont](https://github.com/slamont))
- Fix regression in username validation [#602](https://github.com/puppetlabs/puppetlabs-mysql/pull/602) ([MasonM](https://github.com/MasonM))
- Create log-bin directory if it doesn't exist [#596](https://github.com/puppetlabs/puppetlabs-mysql/pull/596) ([NoodlesNZ](https://github.com/NoodlesNZ))

## [3.0.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/3.0.0) - 2014-11-11

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/2.3.1...3.0.0)

### Added

- [MODULES-1484] Add support for install_options for all package resources... [#591](https://github.com/puppetlabs/puppetlabs-mysql/pull/591) ([damonconway](https://github.com/damonconway))
- Improve checks for MySQL user's name. [#588](https://github.com/puppetlabs/puppetlabs-mysql/pull/588) ([maxenced](https://github.com/maxenced))
- Add support for Gentoo [#585](https://github.com/puppetlabs/puppetlabs-mysql/pull/585) ([dev-zero](https://github.com/dev-zero))
- [MODULES-1333] Add explicit dependencies for mysql_database and mysql_user types [#571](https://github.com/puppetlabs/puppetlabs-mysql/pull/571) ([jtopper](https://github.com/jtopper))
- (MODULES-552) Add capability to specify column_privileges [#570](https://github.com/puppetlabs/puppetlabs-mysql/pull/570) ([fnerdwq](https://github.com/fnerdwq))
- (MODULES-1330) Change order of revokation. [#569](https://github.com/puppetlabs/puppetlabs-mysql/pull/569) ([fnerdwq](https://github.com/fnerdwq))
- Parametrize !includedir [#509](https://github.com/puppetlabs/puppetlabs-mysql/pull/509) ([xbezdick](https://github.com/xbezdick))

### Fixed

- Fix escaped backslashes in grants [#594](https://github.com/puppetlabs/puppetlabs-mysql/pull/594) ([skroll](https://github.com/skroll))
- The old regex requires something after the 'host' part. Fix this. [#587](https://github.com/puppetlabs/puppetlabs-mysql/pull/587) ([maxenced](https://github.com/maxenced))
- Oracle 7 uses mariadb [#582](https://github.com/puppetlabs/puppetlabs-mysql/pull/582) ([cmurphy](https://github.com/cmurphy))
- Install bzip2 on RHEL 7 and Fedora hosts [#580](https://github.com/puppetlabs/puppetlabs-mysql/pull/580) ([cmurphy](https://github.com/cmurphy))
- Ensure error log is present before trying to manage ownership [#579](https://github.com/puppetlabs/puppetlabs-mysql/pull/579) ([cmurphy](https://github.com/cmurphy))
- Change sql param to default to undef instead of empty string [#577](https://github.com/puppetlabs/puppetlabs-mysql/pull/577) ([cmurphy](https://github.com/cmurphy))
- future parser converts explicit undef to empty string [#568](https://github.com/puppetlabs/puppetlabs-mysql/pull/568) ([edestecd](https://github.com/edestecd))
- mysql_database: prevent syntax error with collate=>'binary' [#565](https://github.com/puppetlabs/puppetlabs-mysql/pull/565) ([mmonaco](https://github.com/mmonaco))
- Fix issue with puppet_module_install, removed and using updated method f... [#564](https://github.com/puppetlabs/puppetlabs-mysql/pull/564) ([cyberious](https://github.com/cyberious))
- (MODULES-1287) Pass the backup credentials to 'SHOW DATABASES' [#559](https://github.com/puppetlabs/puppetlabs-mysql/pull/559) ([nhinds](https://github.com/nhinds))
- Fixes manage_service feature [#558](https://github.com/puppetlabs/puppetlabs-mysql/pull/558) ([paramite](https://github.com/paramite))
- Remove all the deprecated code. [#553](https://github.com/puppetlabs/puppetlabs-mysql/pull/553) ([apenney](https://github.com/apenney))
- Prevent ERROR 1008 in mysql_database provider [#547](https://github.com/puppetlabs/puppetlabs-mysql/pull/547) ([rayl](https://github.com/rayl))
- Make sure we actually notify the service. [#546](https://github.com/puppetlabs/puppetlabs-mysql/pull/546) ([igalic](https://github.com/igalic))
- Fix problem with GRANT not recognizing backslash [#540](https://github.com/puppetlabs/puppetlabs-mysql/pull/540) ([jsosic](https://github.com/jsosic))
- Grants for the backupuser should be conditional [#539](https://github.com/puppetlabs/puppetlabs-mysql/pull/539) ([stevesaliman](https://github.com/stevesaliman))

## [2.3.1](https://github.com/puppetlabs/puppetlabs-mysql/tree/2.3.1) - 2014-07-18

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/2.3.0...2.3.1)

## [2.3.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/2.3.0) - 2014-07-11

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/2.2.3...2.3.0)

### Added

- Install MySQL client and daemon dev libraries. [#510](https://github.com/puppetlabs/puppetlabs-mysql/pull/510) ([Aethylred](https://github.com/Aethylred))
- Add quotes to backup password to be able to use more complex passwords. [#495](https://github.com/puppetlabs/puppetlabs-mysql/pull/495) ([mauerj](https://github.com/mauerj))
- Allow to use different name for db resource other than db name [#489](https://github.com/puppetlabs/puppetlabs-mysql/pull/489) ([xcompass](https://github.com/xcompass))

### Fixed

- Handle changing the datadir properly. [#536](https://github.com/puppetlabs/puppetlabs-mysql/pull/536) ([apenney](https://github.com/apenney))
- Change grant provider to ignore grants for non existing users. [#530](https://github.com/puppetlabs/puppetlabs-mysql/pull/530) ([spil-jaak](https://github.com/spil-jaak))
- (MODULES-1096) Fix double quote / single quote issue in params.pp. [#526](https://github.com/puppetlabs/puppetlabs-mysql/pull/526) ([spil-jaak](https://github.com/spil-jaak))
- fix param client_package_ensure [#523](https://github.com/puppetlabs/puppetlabs-mysql/pull/523) ([davidmmiller](https://github.com/davidmmiller))
- Require title of mysql_grant resource to match form user/table [#522](https://github.com/puppetlabs/puppetlabs-mysql/pull/522) ([cmurphy](https://github.com/cmurphy))
- Change the package name in the manifest, too! [#513](https://github.com/puppetlabs/puppetlabs-mysql/pull/513) ([underscorgan](https://github.com/underscorgan))
- Package rename in Ubuntu 14.04. [#512](https://github.com/puppetlabs/puppetlabs-mysql/pull/512) ([underscorgan](https://github.com/underscorgan))
- Rhel7 fixes [#511](https://github.com/puppetlabs/puppetlabs-mysql/pull/511) ([underscorgan](https://github.com/underscorgan))
- Improve this so it works on Ubuntu 14.04. [#507](https://github.com/puppetlabs/puppetlabs-mysql/pull/507) ([apenney](https://github.com/apenney))
- lowercase hostname values in qualified usernames [#505](https://github.com/puppetlabs/puppetlabs-mysql/pull/505) ([larsks](https://github.com/larsks))
- Replaced database_user with mysql_user [#501](https://github.com/puppetlabs/puppetlabs-mysql/pull/501) ([ryansechrest](https://github.com/ryansechrest))
- User needs PROCESS privilege when doing file-per-database backup [#500](https://github.com/puppetlabs/puppetlabs-mysql/pull/500) ([nerdlich](https://github.com/nerdlich))
- [BUG] [Critical] Removing extra space after slash in mysqlbackup.sh [#490](https://github.com/puppetlabs/puppetlabs-mysql/pull/490) ([seocam](https://github.com/seocam))
- fix #487 mysql not starting if ssl is not disabled [#488](https://github.com/puppetlabs/puppetlabs-mysql/pull/488) ([globin](https://github.com/globin))
- backup script test: Actually loop through a list [#479](https://github.com/puppetlabs/puppetlabs-mysql/pull/479) ([igalic](https://github.com/igalic))
- handle mysql compiled without ssl [#477](https://github.com/puppetlabs/puppetlabs-mysql/pull/477) ([globin](https://github.com/globin))
- mysqlbackup.sh should be able to find mysql [#457](https://github.com/puppetlabs/puppetlabs-mysql/pull/457) ([igalic](https://github.com/igalic))

## [2.2.3](https://github.com/puppetlabs/puppetlabs-mysql/tree/2.2.3) - 2014-03-04

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/2.2.2...2.2.3)

### Fixed

- Replace the symlink with the actual file to resolve a PMT issue. [#484](https://github.com/puppetlabs/puppetlabs-mysql/pull/484) ([apenney](https://github.com/apenney))

## [2.2.2](https://github.com/puppetlabs/puppetlabs-mysql/tree/2.2.2) - 2014-03-03

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/2.2.1...2.2.2)

### Added

- Add unsupported infrastructure for excluding OSes we can't test on. [#470](https://github.com/puppetlabs/puppetlabs-mysql/pull/470) ([apenney](https://github.com/apenney))

### Fixed

- Last SLES fix, don't use the deprecated parameter name. [#469](https://github.com/puppetlabs/puppetlabs-mysql/pull/469) ([apenney](https://github.com/apenney))
- This fixes: [#467](https://github.com/puppetlabs/puppetlabs-mysql/pull/467) ([apenney](https://github.com/apenney))
- As we're deleting /etc/my.cnf, lets not restart MySQL in the middle [#466](https://github.com/puppetlabs/puppetlabs-mysql/pull/466) ([apenney](https://github.com/apenney))
- Fix the case of this, ARGH. [#465](https://github.com/puppetlabs/puppetlabs-mysql/pull/465) ([apenney](https://github.com/apenney))
- Make this work in SLES as well As RedHat. [#464](https://github.com/puppetlabs/puppetlabs-mysql/pull/464) ([apenney](https://github.com/apenney))

## [2.2.1](https://github.com/puppetlabs/puppetlabs-mysql/tree/2.2.1) - 2014-02-19

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/2.2.0...2.2.1)

### Fixed

- Fix this test for Debian.  This is a total hack for now. [#455](https://github.com/puppetlabs/puppetlabs-mysql/pull/455) ([apenney](https://github.com/apenney))
- Fixes for Ubuntu/Debian. [#454](https://github.com/puppetlabs/puppetlabs-mysql/pull/454) ([apenney](https://github.com/apenney))
- Repair this by ensuring calls to mysql include the database name. [#452](https://github.com/puppetlabs/puppetlabs-mysql/pull/452) ([apenney](https://github.com/apenney))

## [2.2.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/2.2.0) - 2014-02-13

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/2.1.0...2.2.0)

### Added

- Add check for puppet rpm before trying to install [#445](https://github.com/puppetlabs/puppetlabs-mysql/pull/445) ([Phil0xF7](https://github.com/Phil0xF7))
- Add logic to ignore mysql.events [#435](https://github.com/puppetlabs/puppetlabs-mysql/pull/435) ([b4ldr](https://github.com/b4ldr))
- option to specify a script that runs after backups [#413](https://github.com/puppetlabs/puppetlabs-mysql/pull/413) ([igalic](https://github.com/igalic))
- Restart [#401](https://github.com/puppetlabs/puppetlabs-mysql/pull/401) ([apenney](https://github.com/apenney))
- Support multiple lines of the same option [#398](https://github.com/puppetlabs/puppetlabs-mysql/pull/398) ([fridim](https://github.com/fridim))
- Added [if not exists] to [create database] clause. [#397](https://github.com/puppetlabs/puppetlabs-mysql/pull/397) ([srinathman](https://github.com/srinathman))
- Parameterize backup directory mode and ownership [#375](https://github.com/puppetlabs/puppetlabs-mysql/pull/375) ([ezheidtmann](https://github.com/ezheidtmann))

### Fixed

- Fix this so it installs PE appropriately. [#447](https://github.com/puppetlabs/puppetlabs-mysql/pull/447) ([apenney](https://github.com/apenney))
- mysql_deepmerge should treat underscore and dash equivalently, as mysql does [#428](https://github.com/puppetlabs/puppetlabs-mysql/pull/428) ([radford](https://github.com/radford))
- Allow override_options set to undef to completely remove the corresponding key reverting to the mysql default [#427](https://github.com/puppetlabs/puppetlabs-mysql/pull/427) ([radford](https://github.com/radford))
-  	Allow an option with a value of false to override something that mysql defaults to true rather than eliding it [#426](https://github.com/puppetlabs/puppetlabs-mysql/pull/426) ([radford](https://github.com/radford))
- Actually use upstart on Ubuntu by fixing misspelled variable name [#425](https://github.com/puppetlabs/puppetlabs-mysql/pull/425) ([radford](https://github.com/radford))
- fixed a problem with the mysql_database provider [#422](https://github.com/puppetlabs/puppetlabs-mysql/pull/422) ([stevesaliman](https://github.com/stevesaliman))
- Remove duplicate service_provider description [#421](https://github.com/puppetlabs/puppetlabs-mysql/pull/421) ([lboynton](https://github.com/lboynton))
- mysql_grant fixed to properly handle PROCEDURE grants [#412](https://github.com/puppetlabs/puppetlabs-mysql/pull/412) ([dgolja](https://github.com/dgolja))
- my.cnf: typo fix (bind-address) + migrate key_buffer (deprecated) to key_buffer_size [#395](https://github.com/puppetlabs/puppetlabs-mysql/pull/395) ([doc75](https://github.com/doc75))
- Mysql grant fixes [#391](https://github.com/puppetlabs/puppetlabs-mysql/pull/391) ([vicinus](https://github.com/vicinus))
- Fix missing mysql::config when including mysql [#385](https://github.com/puppetlabs/puppetlabs-mysql/pull/385) ([liwo](https://github.com/liwo))
- Type mysql_grant fixed, spec test created [#376](https://github.com/puppetlabs/puppetlabs-mysql/pull/376) ([w32-blaster](https://github.com/w32-blaster))
- Fix having wildcards (%) in hostnames of grants [#366](https://github.com/puppetlabs/puppetlabs-mysql/pull/366) ([liwo](https://github.com/liwo))

### Other

- changed log_error to log-error and pid_file to pid-file to match the mys... [#394](https://github.com/puppetlabs/puppetlabs-mysql/pull/394) ([danielfoglio](https://github.com/danielfoglio))

## [2.1.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/2.1.0) - 2013-11-13

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/2.0.1-rc1...2.1.0)

### Added

- added * for table name in title to match documented usage [#355](https://github.com/puppetlabs/puppetlabs-mysql/pull/355) ([tekenny](https://github.com/tekenny))
- Add Anchor pattern to client.pp [#343](https://github.com/puppetlabs/puppetlabs-mysql/pull/343) ([Bit-Doctor](https://github.com/Bit-Doctor))
- Adds example to set root password [#341](https://github.com/puppetlabs/puppetlabs-mysql/pull/341) ([spuder](https://github.com/spuder))
- Further improvements to our matching - stop trying to guess what [#319](https://github.com/puppetlabs/puppetlabs-mysql/pull/319) ([apenney](https://github.com/apenney))
- Improve mysql_grant to work with IPv6. [#308](https://github.com/puppetlabs/puppetlabs-mysql/pull/308) ([apenney](https://github.com/apenney))
- Extend coverage to the contents of /etc/my.cnf. [#302](https://github.com/puppetlabs/puppetlabs-mysql/pull/302) ([apenney](https://github.com/apenney))

### Fixed

- Method for loading .my.cnf file is changed from "defaults-file" to "defaults-extra-file" (mysql option) [#367](https://github.com/puppetlabs/puppetlabs-mysql/pull/367) ([w32-blaster](https://github.com/w32-blaster))
- Some options can not take a argument.  [#364](https://github.com/puppetlabs/puppetlabs-mysql/pull/364) ([jglenn9k](https://github.com/jglenn9k))
- Fix the broken anchoring. [#358](https://github.com/puppetlabs/puppetlabs-mysql/pull/358) ([apenney](https://github.com/apenney))
- fix for the fix: database -> database_user [#353](https://github.com/puppetlabs/puppetlabs-mysql/pull/353) ([igalic](https://github.com/igalic))
- database_user gives the wrong deprecation warning [#345](https://github.com/puppetlabs/puppetlabs-mysql/pull/345) ([igalic](https://github.com/igalic))
- Fix an issue with lowercase privileges. [#342](https://github.com/puppetlabs/puppetlabs-mysql/pull/342) ([apenney](https://github.com/apenney))
- Fix ordering causing mysql_grant to reapply. [#332](https://github.com/puppetlabs/puppetlabs-mysql/pull/332) ([apenney](https://github.com/apenney))
- Updated my.cnf template to support items with no values [#316](https://github.com/puppetlabs/puppetlabs-mysql/pull/316) ([tekenny](https://github.com/tekenny))
- Previously we were matching to ensure that usernames matched [#312](https://github.com/puppetlabs/puppetlabs-mysql/pull/312) ([apenney](https://github.com/apenney))
- Fix mysql::server::monitor mysql_grant privileges [#303](https://github.com/puppetlabs/puppetlabs-mysql/pull/303) ([treydock](https://github.com/treydock))
- Duplicate parameter removed. [#298](https://github.com/puppetlabs/puppetlabs-mysql/pull/298) ([apenney](https://github.com/apenney))

## [2.0.1-rc1](https://github.com/puppetlabs/puppetlabs-mysql/tree/2.0.1-rc1) - 2013-10-03

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/2.0.0-rc1...2.0.1-rc1)

## [2.0.0-rc1](https://github.com/puppetlabs/puppetlabs-mysql/tree/2.0.0-rc1) - 2013-10-03

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/1.0.0...2.0.0-rc1)

### Added

- Add all the params here as undef to make it clear what the intent is. [#296](https://github.com/puppetlabs/puppetlabs-mysql/pull/296) ([apenney](https://github.com/apenney))
- Add collation with the create statement [#291](https://github.com/puppetlabs/puppetlabs-mysql/pull/291) ([inkblot](https://github.com/inkblot))
- Improvements to mysql_grant. [#276](https://github.com/puppetlabs/puppetlabs-mysql/pull/276) ([apenney](https://github.com/apenney))
- Update mysqltuner.pp [#273](https://github.com/puppetlabs/puppetlabs-mysql/pull/273) ([davidcollom](https://github.com/davidcollom))
- Support Fedora's rolling development "release", Rawhide [#241](https://github.com/puppetlabs/puppetlabs-mysql/pull/241) ([judge-red](https://github.com/judge-red))

### Changed
- Completely redesign the MySQL module. [#258](https://github.com/puppetlabs/puppetlabs-mysql/pull/258) ([apenney](https://github.com/apenney))

### Fixed

- Use mysql::server::root_password instead of @options. [#288](https://github.com/puppetlabs/puppetlabs-mysql/pull/288) ([apenney](https://github.com/apenney))
- Add 3.3, strip down the excludes. [#286](https://github.com/puppetlabs/puppetlabs-mysql/pull/286) ([apenney](https://github.com/apenney))
- Fix mysql::client. [#285](https://github.com/puppetlabs/puppetlabs-mysql/pull/285) ([apenney](https://github.com/apenney))
- Fixes issue #274 by using recursive hash merge. [#282](https://github.com/puppetlabs/puppetlabs-mysql/pull/282) ([jburnham](https://github.com/jburnham))
- Removing the bindings compat stuff. [#280](https://github.com/puppetlabs/puppetlabs-mysql/pull/280) ([apenney](https://github.com/apenney))
- Remove mysql::globals. [#278](https://github.com/puppetlabs/puppetlabs-mysql/pull/278) ([apenney](https://github.com/apenney))

## [1.0.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/1.0.0) - 2013-09-23

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/0.9.0...1.0.0)

### Added

- Add option so mysql::backup to dump each database to its own file [#253](https://github.com/puppetlabs/puppetlabs-mysql/pull/253) ([treydock](https://github.com/treydock))
- Add HOME environment variable for .my.cnf to mysqladmin command [#245](https://github.com/puppetlabs/puppetlabs-mysql/pull/245) ([embeepea](https://github.com/embeepea))
- Added support to back up specified databases only with 'mysqlbackup' [#244](https://github.com/puppetlabs/puppetlabs-mysql/pull/244) ([cfeskens](https://github.com/cfeskens))
- Add environment variable for .my.cnf and specs [#243](https://github.com/puppetlabs/puppetlabs-mysql/pull/243) ([hunner](https://github.com/hunner))
- Add compatibility classes to handle the backwards incompatible changes. [#237](https://github.com/puppetlabs/puppetlabs-mysql/pull/237) ([apenney](https://github.com/apenney))

### Changed
- WIP: database_user and database refactoring [#248](https://github.com/puppetlabs/puppetlabs-mysql/pull/248) ([apenney](https://github.com/apenney))

### Fixed

- Fix this so we don't list dates or versions yet. [#238](https://github.com/puppetlabs/puppetlabs-mysql/pull/238) ([apenney](https://github.com/apenney))
- Fix puppet 2.6 compatibility [#235](https://github.com/puppetlabs/puppetlabs-mysql/pull/235) ([ekohl](https://github.com/ekohl))
- Refactor MySQL bindings and client packages. [#232](https://github.com/puppetlabs/puppetlabs-mysql/pull/232) ([apenney](https://github.com/apenney))
- Update my.cnf.pass.erb to allow custom socket support [#227](https://github.com/puppetlabs/puppetlabs-mysql/pull/227) ([hunner](https://github.com/hunner))

## [0.9.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/0.9.0) - 2013-07-15

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/0.8.1...0.9.0)

### Fixed

- Remove redundant hard coded replication parameters [#224](https://github.com/puppetlabs/puppetlabs-mysql/pull/224) ([3flex](https://github.com/3flex))
- include mysql_client package as a requirement for the db creation [#222](https://github.com/puppetlabs/puppetlabs-mysql/pull/222) ([wolfspyre](https://github.com/wolfspyre))
- Fixes suggested by RubyMine (just playing around with it) [#219](https://github.com/puppetlabs/puppetlabs-mysql/pull/219) ([apenney](https://github.com/apenney))

## [0.8.1](https://github.com/puppetlabs/puppetlabs-mysql/tree/0.8.1) - 2013-07-10

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/0.8.0...0.8.1)

## [0.8.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/0.8.0) - 2013-07-10

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/0.7.0...0.8.0)

### Added

- Support max_user_connections in database_user [#215](https://github.com/puppetlabs/puppetlabs-mysql/pull/215) ([mbakke](https://github.com/mbakke))
- Use $root_home for .my.cnf [#214](https://github.com/puppetlabs/puppetlabs-mysql/pull/214) ([paramite](https://github.com/paramite))
- Add basic specs for database provider. [#211](https://github.com/puppetlabs/puppetlabs-mysql/pull/211) ([apenney](https://github.com/apenney))
- add a maximum connection parameter and set the default to 1000 [#198](https://github.com/puppetlabs/puppetlabs-mysql/pull/198) ([mhellmic](https://github.com/mhellmic))
- add mysql::perl helper class [#187](https://github.com/puppetlabs/puppetlabs-mysql/pull/187) ([rsrchboy](https://github.com/rsrchboy))
- Implement character_set and other options [#167](https://github.com/puppetlabs/puppetlabs-mysql/pull/167) ([abraham1901](https://github.com/abraham1901))
- handling of my.cnf config file is now optional [#132](https://github.com/puppetlabs/puppetlabs-mysql/pull/132) ([savar](https://github.com/savar))

### Fixed

- Fixed PID file location for SLES 11 SP2. [#216](https://github.com/puppetlabs/puppetlabs-mysql/pull/216) ([vakuum](https://github.com/vakuum))
- Cover Fedora 19's move from mysql to mariadb packages [#210](https://github.com/puppetlabs/puppetlabs-mysql/pull/210) ([judge-red](https://github.com/judge-red))
- Database user refactor/tests [#208](https://github.com/puppetlabs/puppetlabs-mysql/pull/208) ([apenney](https://github.com/apenney))
- (WIP) #20562: Minor fix for ordering [#186](https://github.com/puppetlabs/puppetlabs-mysql/pull/186) ([apenney](https://github.com/apenney))
- Harden mysqlbackup.sh script [#170](https://github.com/puppetlabs/puppetlabs-mysql/pull/170) ([omalashenko](https://github.com/omalashenko))
- Quote the password [#166](https://github.com/puppetlabs/puppetlabs-mysql/pull/166) ([ekohl](https://github.com/ekohl))
- add ft_min_word_len and ft_max_word_len config options [#165](https://github.com/puppetlabs/puppetlabs-mysql/pull/165) ([leinaddm](https://github.com/leinaddm))
- fixes #19744 - no restart on root/.my.cnf change [#162](https://github.com/puppetlabs/puppetlabs-mysql/pull/162) ([frimik](https://github.com/frimik))

## [0.7.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/0.7.0) - 2013-06-25

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/0.6.1...0.7.0)

### Added

- Parameterized max_allowed_packet my.conf config setting, because it is needed to setup puppet-dashboard. [#179](https://github.com/puppetlabs/puppetlabs-mysql/pull/179) ([msmithgu](https://github.com/msmithgu))

### Fixed

- Update template for #179 [#201](https://github.com/puppetlabs/puppetlabs-mysql/pull/201) ([hunner](https://github.com/hunner))
- make tmpdir configurable [#200](https://github.com/puppetlabs/puppetlabs-mysql/pull/200) ([hunner](https://github.com/hunner))
- Fix SQL when ANSI_QUOTES is enabled in mysql config. [#199](https://github.com/puppetlabs/puppetlabs-mysql/pull/199) ([hunner](https://github.com/hunner))
- change the distribution osfamily from Redhat into RedHat [#197](https://github.com/puppetlabs/puppetlabs-mysql/pull/197) ([mhellmic](https://github.com/mhellmic))
- fix puppet warning default_engine [#188](https://github.com/puppetlabs/puppetlabs-mysql/pull/188) ([gimler](https://github.com/gimler))
- fix variables in templates [#185](https://github.com/puppetlabs/puppetlabs-mysql/pull/185) ([ChrisRut](https://github.com/ChrisRut))
- python_package_name parameter missing [#178](https://github.com/puppetlabs/puppetlabs-mysql/pull/178) ([wolfspyre](https://github.com/wolfspyre))
- [Important] Fix default-storage-engine default value [#171](https://github.com/puppetlabs/puppetlabs-mysql/pull/171) ([ctrlaltdel](https://github.com/ctrlaltdel))
- Refactor to put a knob on all parameters [#169](https://github.com/puppetlabs/puppetlabs-mysql/pull/169) ([wolfspyre](https://github.com/wolfspyre))
- Puppet 2.6 fix [#163](https://github.com/puppetlabs/puppetlabs-mysql/pull/163) ([domcleal](https://github.com/domcleal))
- Restrict the versions and add 3.1 [#155](https://github.com/puppetlabs/puppetlabs-mysql/pull/155) ([richardc](https://github.com/richardc))
- Fix issue with redeclaration of database_user via mysql::db  [#154](https://github.com/puppetlabs/puppetlabs-mysql/pull/154) ([pbrit](https://github.com/pbrit))
- Update travis config file [#148](https://github.com/puppetlabs/puppetlabs-mysql/pull/148) ([blkperl](https://github.com/blkperl))

## [0.6.1](https://github.com/puppetlabs/puppetlabs-mysql/tree/0.6.1) - 2013-01-11

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/0.6.0...0.6.1)

### Fixed

- Patch providers for absent my.cnf [#141](https://github.com/puppetlabs/puppetlabs-mysql/pull/141) ([hunner](https://github.com/hunner))

## [0.6.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/0.6.0) - 2013-01-09

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/0.5.0...0.6.0)

### Added

- Add php support [#137](https://github.com/puppetlabs/puppetlabs-mysql/pull/137) ([hunner](https://github.com/hunner))
- Added SuSE support to puppetlabs-mysql [#136](https://github.com/puppetlabs/puppetlabs-mysql/pull/136) ([deadpoint](https://github.com/deadpoint))
- add parameter to remove old files in conf.d dir [#131](https://github.com/puppetlabs/puppetlabs-mysql/pull/131) ([saz](https://github.com/saz))
- allow logging via syslog [#130](https://github.com/puppetlabs/puppetlabs-mysql/pull/130) ([saz](https://github.com/saz))
- Optionally manage the mysqld service [#122](https://github.com/puppetlabs/puppetlabs-mysql/pull/122) ([hunner](https://github.com/hunner))
- Mysql::backup Compression Optional [#117](https://github.com/puppetlabs/puppetlabs-mysql/pull/117) ([hunner](https://github.com/hunner))
- Add show view privilege for backup user [#108](https://github.com/puppetlabs/puppetlabs-mysql/pull/108) ([pbrit](https://github.com/pbrit))
- new config define and a small bugfix [#93](https://github.com/puppetlabs/puppetlabs-mysql/pull/93) ([savar](https://github.com/savar))

### Fixed

- Update manifests/server/monitor.pp [#134](https://github.com/puppetlabs/puppetlabs-mysql/pull/134) ([nikolavp](https://github.com/nikolavp))
- fixed character-set detection regex [#133](https://github.com/puppetlabs/puppetlabs-mysql/pull/133) ([obilodeau](https://github.com/obilodeau))
- account security should not fail if hostname == fqdn [#128](https://github.com/puppetlabs/puppetlabs-mysql/pull/128) ([bodepd](https://github.com/bodepd))
- fix mysql bug [#126](https://github.com/puppetlabs/puppetlabs-mysql/pull/126) ([bodepd](https://github.com/bodepd))
- Create /root/.my.cnf even when root passwd is not managed [#125](https://github.com/puppetlabs/puppetlabs-mysql/pull/125) ([bodepd](https://github.com/bodepd))
- Root credentials [#123](https://github.com/puppetlabs/puppetlabs-mysql/pull/123) ([hunner](https://github.com/hunner))
- Restart optional and minor doc fix [#115](https://github.com/puppetlabs/puppetlabs-mysql/pull/115) ([frimik](https://github.com/frimik))
- Don't assign to hash after creation [#114](https://github.com/puppetlabs/puppetlabs-mysql/pull/114) ([dalen](https://github.com/dalen))
- Update mysql::backup privs for #108 [#112](https://github.com/puppetlabs/puppetlabs-mysql/pull/112) ([hunner](https://github.com/hunner))

## [0.5.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/0.5.0) - 2012-08-23

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/0.4.0...0.5.0)

### Added

- Add bind address unset [#106](https://github.com/puppetlabs/puppetlabs-mysql/pull/106) ([hunner](https://github.com/hunner))
- Added an option to specify db status. [#101](https://github.com/puppetlabs/puppetlabs-mysql/pull/101) ([martasd](https://github.com/martasd))
- Add support for Amazon Linux. [#94](https://github.com/puppetlabs/puppetlabs-mysql/pull/94) ([hunner](https://github.com/hunner))
- Add priv validation to database_grant provider [#91](https://github.com/puppetlabs/puppetlabs-mysql/pull/91) ([reidmv](https://github.com/reidmv))
- Add a bunch of new parameters [#90](https://github.com/puppetlabs/puppetlabs-mysql/pull/90) ([emonty](https://github.com/emonty))

### Fixed

- Change list passed into validate_re to a stringe [#105](https://github.com/puppetlabs/puppetlabs-mysql/pull/105) ([derekhiggins](https://github.com/derekhiggins))
- Parameterized pidfile; critical for successful first restart [#102](https://github.com/puppetlabs/puppetlabs-mysql/pull/102) ([jkff](https://github.com/jkff))
- Clarify how to grant specific privileges with database_grant [#100](https://github.com/puppetlabs/puppetlabs-mysql/pull/100) ([mcary](https://github.com/mcary))
- Revert "Merge pull request #90 from emonty/master" [#97](https://github.com/puppetlabs/puppetlabs-mysql/pull/97) ([bodepd](https://github.com/bodepd))
- Put that curly brace in the right place this time [#96](https://github.com/puppetlabs/puppetlabs-mysql/pull/96) ([branan](https://github.com/branan))
- Add a missing curly brace [#95](https://github.com/puppetlabs/puppetlabs-mysql/pull/95) ([branan](https://github.com/branan))
- Escape $root_password during execs. [#73](https://github.com/puppetlabs/puppetlabs-mysql/pull/73) ([razorsedge](https://github.com/razorsedge))

## [0.4.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/0.4.0) - 2012-07-24

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/0.3.0...0.4.0)

### Added

- Add enabled parameter to mysql::server [#81](https://github.com/puppetlabs/puppetlabs-mysql/pull/81) ([bodepd](https://github.com/bodepd))
- Allow consumer to specify default storage engine for MySQL server. [#74](https://github.com/puppetlabs/puppetlabs-mysql/pull/74) ([jmchilton](https://github.com/jmchilton))
- Added mysql::backup class. [#64](https://github.com/puppetlabs/puppetlabs-mysql/pull/64) ([razorsedge](https://github.com/razorsedge))
- Added mysql::server::account_security class. [#63](https://github.com/puppetlabs/puppetlabs-mysql/pull/63) ([razorsedge](https://github.com/razorsedge))

### Fixed

- add missing db param to database_grant [#83](https://github.com/puppetlabs/puppetlabs-mysql/pull/83) ([agerlic](https://github.com/agerlic))
- escape database name [#82](https://github.com/puppetlabs/puppetlabs-mysql/pull/82) ([agerlic](https://github.com/agerlic))
- Default types hacks not needed. [#76](https://github.com/puppetlabs/puppetlabs-mysql/pull/76) ([rdrgmnzs](https://github.com/rdrgmnzs))
- Fixed regex of database user. [#71](https://github.com/puppetlabs/puppetlabs-mysql/pull/71) ([razorsedge](https://github.com/razorsedge))

## [0.3.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/0.3.0) - 2012-05-04

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/0.2.0...0.3.0)

### Added

- Allow wildcard host assignment with sql. [#68](https://github.com/puppetlabs/puppetlabs-mysql/pull/68) ([razorsedge](https://github.com/razorsedge))
- Query the database for possible permissions [#65](https://github.com/puppetlabs/puppetlabs-mysql/pull/65) ([branan](https://github.com/branan))
- Java [#61](https://github.com/puppetlabs/puppetlabs-mysql/pull/61) ([razorsedge](https://github.com/razorsedge))

### Fixed

- (#14316) Make privileges case-insensitive [#69](https://github.com/puppetlabs/puppetlabs-mysql/pull/69) ([branan](https://github.com/branan))
- I noticed the following message whilst provisioning using this module: [#60](https://github.com/puppetlabs/puppetlabs-mysql/pull/60) ([geogdog](https://github.com/geogdog))
- set platform dependent error logfile location [#58](https://github.com/puppetlabs/puppetlabs-mysql/pull/58) ([derekhiggins](https://github.com/derekhiggins))

## [0.2.0](https://github.com/puppetlabs/puppetlabs-mysql/tree/0.2.0) - 2012-04-11

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/v0.0.1...0.2.0)

### Added

- (#13203) Add ssl support [#54](https://github.com/puppetlabs/puppetlabs-mysql/pull/54) ([blkperl](https://github.com/blkperl))

### Fixed

- Fix mysql service on Ubuntu. [#50](https://github.com/puppetlabs/puppetlabs-mysql/pull/50) ([nanliu](https://github.com/nanliu))
- (#13163) Datadir should be configurable [#47](https://github.com/puppetlabs/puppetlabs-mysql/pull/47) ([blkperl](https://github.com/blkperl))
- Fix issues from nans massive pull request [#45](https://github.com/puppetlabs/puppetlabs-mysql/pull/45) ([bodepd](https://github.com/bodepd))
- #11963 In the mysql module the Exec[mysqld-restart] should have more in path [#42](https://github.com/puppetlabs/puppetlabs-mysql/pull/42) ([fcharlier](https://github.com/fcharlier))
- Refactor mysql module. [#41](https://github.com/puppetlabs/puppetlabs-mysql/pull/41) ([nanliu](https://github.com/nanliu))
- (#12412) mysqltuner.pl update [#38](https://github.com/puppetlabs/puppetlabs-mysql/pull/38) ([grooverdan](https://github.com/grooverdan))
- (#11508) Only load sql_scripts on DB creation [#28](https://github.com/puppetlabs/puppetlabs-mysql/pull/28) ([ccaum](https://github.com/ccaum))
- Bug #11375: puppetlabs-mysql fails on CentOS/RHEL [#27](https://github.com/puppetlabs/puppetlabs-mysql/pull/27) ([justintime](https://github.com/justintime))

## [v0.0.1](https://github.com/puppetlabs/puppetlabs-mysql/tree/v0.0.1) - 2011-12-13

[Full Changelog](https://github.com/puppetlabs/puppetlabs-mysql/compare/d28f0e0327d73dde80331494d2abb5562d0ff144...v0.0.1)

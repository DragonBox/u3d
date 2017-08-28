# Change Log

## [v0.9.4](https://github.com/DragonBox/u3d/tree/v0.9.4) (2017-08-28)
[Full Changelog](https://github.com/DragonBox/u3d/compare/v0.9.3...v0.9.4)

**Implemented enhancements:**

- Merge install and local\_install commands [\#84](https://github.com/DragonBox/u3d/issues/84)
- Document installation path sanitization [\#50](https://github.com/DragonBox/u3d/issues/50)
- Make unity versions test unit [\#72](https://github.com/DragonBox/u3d/pull/72) ([niezbop](https://github.com/niezbop))
- \[tech\] rubocop: update version and fix windows compatibility [\#61](https://github.com/DragonBox/u3d/pull/61) ([lacostej](https://github.com/lacostej))
- u3d/install local\_install: if no version specified, fallback on version required by current project [\#53](https://github.com/DragonBox/u3d/pull/53) ([lacostej](https://github.com/lacostej))
- u3d/install: display more information during sanization, including what would happen \(fixes \#50\) [\#51](https://github.com/DragonBox/u3d/pull/51) ([lacostej](https://github.com/lacostej))

**Fixed bugs:**

- u3d run not getting project path automatically with some arguments [\#73](https://github.com/DragonBox/u3d/issues/73)
- u3d/list doesn't list all installed Unity versions [\#69](https://github.com/DragonBox/u3d/issues/69)
- Installation stays in /Application/Unity when installing on OSX [\#68](https://github.com/DragonBox/u3d/issues/68)
- u3d local\_install broken on Mac [\#62](https://github.com/DragonBox/u3d/issues/62)
- u3d/install unnecessarily asking for permissions when it has nothing to do [\#52](https://github.com/DragonBox/u3d/issues/52)
- downloader \(for linux\) does not detect incomplete files [\#21](https://github.com/DragonBox/u3d/issues/21)

**Closed issues:**

- \[Doc\] make u3d run default behavior more visible in documentation [\#75](https://github.com/DragonBox/u3d/issues/75)
- \[Feature request\] List available packages [\#70](https://github.com/DragonBox/u3d/issues/70)
- Refactor the downloader/validator logic [\#66](https://github.com/DragonBox/u3d/issues/66)
- \[tech\] setup circleci / coverage etc [\#4](https://github.com/DragonBox/u3d/issues/4)
- migrate available integration tests to mock tests [\#2](https://github.com/DragonBox/u3d/issues/2)

**Merged pull requests:**

- Disable trick to reduce CPU on slow network as it slows down download on fast networks [\#94](https://github.com/DragonBox/u3d/pull/94) ([lacostej](https://github.com/lacostej))
- Merge download and local\_install into one \(\#84\) [\#92](https://github.com/DragonBox/u3d/pull/92) ([lacostej](https://github.com/lacostej))
- Add tests for INIParser.create\_linux\_ini' [\#89](https://github.com/DragonBox/u3d/pull/89) ([lacostej](https://github.com/lacostej))
- u3d/installer: add tests for Installer.create / sanitize [\#88](https://github.com/DragonBox/u3d/pull/88) ([lacostej](https://github.com/lacostej))
- Make sure tests pass in full offline mode \(no network at all\) [\#87](https://github.com/DragonBox/u3d/pull/87) ([lacostej](https://github.com/lacostej))
- Mac Installer fix [\#85](https://github.com/DragonBox/u3d/pull/85) ([niezbop](https://github.com/niezbop))
- u3d/run: add -projectpath also when passing arguments \(fixes \#73\) [\#80](https://github.com/DragonBox/u3d/pull/80) ([lacostej](https://github.com/lacostej))
- Refactor/downloader and ini [\#79](https://github.com/DragonBox/u3d/pull/79) ([lacostej](https://github.com/lacostej))
- Improve the docs, in particular with run and auto-detection of the current project [\#78](https://github.com/DragonBox/u3d/pull/78) ([lacostej](https://github.com/lacostej))
- Improve the docs, in particular with run and auto-detection of the current project \(\#75\) [\#77](https://github.com/DragonBox/u3d/pull/77) ([lacostej](https://github.com/lacostej))
- u3d/commands: add unit tests and fix 2 small install command issues [\#76](https://github.com/DragonBox/u3d/pull/76) ([lacostej](https://github.com/lacostej))
- Do not crash when no PlaybackEngines are found [\#74](https://github.com/DragonBox/u3d/pull/74) ([lacostej](https://github.com/lacostej))
- A missing license header [\#67](https://github.com/DragonBox/u3d/pull/67) ([lacostej](https://github.com/lacostej))
- \[tech\] Installer unit tests. Initial commit [\#60](https://github.com/DragonBox/u3d/pull/60) ([lacostej](https://github.com/lacostej))
- \[tech\] automate changelog generation through rake [\#59](https://github.com/DragonBox/u3d/pull/59) ([lacostej](https://github.com/lacostej))
- u3d/install: do not try to download unknown versions \(i.e. not in cache\) [\#57](https://github.com/DragonBox/u3d/pull/57) ([niezbop](https://github.com/niezbop))
- u3d/run: improve run inline help [\#54](https://github.com/DragonBox/u3d/pull/54) ([lacostej](https://github.com/lacostej))
- \[tech\] migrate to circle ci 2.0, using Rakefile as basis for complex operations [\#49](https://github.com/DragonBox/u3d/pull/49) ([lacostej](https://github.com/lacostej))
- \[tech\] rubocop cleanups [\#46](https://github.com/DragonBox/u3d/pull/46) ([lacostej](https://github.com/lacostej))
- u3d/install: allow to recover from incomplete downloads on linux by autodetecting size  [\#23](https://github.com/DragonBox/u3d/pull/23) ([niezbop](https://github.com/niezbop))

## [v0.9.3](https://github.com/DragonBox/u3d/tree/v0.9.3) (2017-08-07)
[Full Changelog](https://github.com/DragonBox/u3d/compare/v0.9.2...v0.9.3)

**Implemented enhancements:**

- Auto-sanitize Linux install names after install [\#35](https://github.com/DragonBox/u3d/issues/35)
- u3d list: properly align versions and paths in output [\#42](https://github.com/DragonBox/u3d/pull/42) ([niezbop](https://github.com/niezbop))

**Fixed bugs:**

- Don't duplicate Unity install for specific versions [\#40](https://github.com/DragonBox/u3d/issues/40)
- u3d install: too high CPU usage during download [\#36](https://github.com/DragonBox/u3d/issues/36)
- Linux Unity\_2017.2.0b2 installer failure [\#19](https://github.com/DragonBox/u3d/issues/19)

**Merged pull requests:**

- Do not reinstall Unity or its packages if already present. Also prevent duplication because of sanitization. [\#41](https://github.com/DragonBox/u3d/pull/41) ([niezbop](https://github.com/niezbop))
- Linux auto sanitize after install [\#39](https://github.com/DragonBox/u3d/pull/39) ([niezbop](https://github.com/niezbop))
- u3d/install: reduce cpu caused by lack of buffering and high console output \#36 [\#37](https://github.com/DragonBox/u3d/pull/37) ([lacostej](https://github.com/lacostej))
- Rubocop / Improve code style [\#34](https://github.com/DragonBox/u3d/pull/34) ([niezbop](https://github.com/niezbop))
- \[linux\] Adjust to weird editor versions stored under ProjectSettings/ProjectVersion.txt [\#33](https://github.com/DragonBox/u3d/pull/33) ([niezbop](https://github.com/niezbop))
- Make Linux runner functional again [\#29](https://github.com/DragonBox/u3d/pull/29) ([lacostej](https://github.com/lacostej))
- u3d/run: ensure parent dir to logfile exists before creating the file [\#28](https://github.com/DragonBox/u3d/pull/28) ([lacostej](https://github.com/lacostej))
- Rubocop / Improve code style [\#27](https://github.com/DragonBox/u3d/pull/27) ([lacostej](https://github.com/lacostej))
- Fix Linux runner and installation [\#26](https://github.com/DragonBox/u3d/pull/26) ([niezbop](https://github.com/niezbop))
- Change sanitizer to be platform specific [\#24](https://github.com/DragonBox/u3d/pull/24) ([niezbop](https://github.com/niezbop))
- Make Linux installer functional again [\#20](https://github.com/DragonBox/u3d/pull/20) ([lacostej](https://github.com/lacostej))

## [v0.9.2](https://github.com/DragonBox/u3d/tree/v0.9.2) (2017-08-04)
[Full Changelog](https://github.com/DragonBox/u3d/compare/v0.9.1...v0.9.2)

**Fixed bugs:**

- Fix missing key failure [\#13](https://github.com/DragonBox/u3d/pull/13) ([niezbop](https://github.com/niezbop))

**Closed issues:**

- -logFile /dev/stdout not supported [\#11](https://github.com/DragonBox/u3d/issues/11)
- Do you have any relevant documents? [\#7](https://github.com/DragonBox/u3d/issues/7)
- rspec broken on linux [\#5](https://github.com/DragonBox/u3d/issues/5)

**Merged pull requests:**

- Better support for /dev/stdout \(\#11\) [\#17](https://github.com/DragonBox/u3d/pull/17) ([lacostej](https://github.com/lacostej))
- u3d/list: sort versions [\#16](https://github.com/DragonBox/u3d/pull/16) ([lacostej](https://github.com/lacostej))
- Fix tail logs synchronization [\#12](https://github.com/DragonBox/u3d/pull/12) ([niezbop](https://github.com/niezbop))
- Various test fixes, including linux rspec support, and a regression [\#9](https://github.com/DragonBox/u3d/pull/9) ([lacostej](https://github.com/lacostej))
- specs: ensure test pass on Linux [\#8](https://github.com/DragonBox/u3d/pull/8) ([lacostej](https://github.com/lacostej))
- Linux versions fix [\#6](https://github.com/DragonBox/u3d/pull/6) ([niezbop](https://github.com/niezbop))
- Document further the prettifier [\#1](https://github.com/DragonBox/u3d/pull/1) ([lacostej](https://github.com/lacostej))

## [v0.9.1](https://github.com/DragonBox/u3d/tree/v0.9.1) (2017-07-24)
[Full Changelog](https://github.com/DragonBox/u3d/compare/v0.9...v0.9.1)



\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*
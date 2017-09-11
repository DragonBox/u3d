# Change Log

## [v1.0.3](https://github.com/DragonBox/u3d/tree/v1.0.3) (2017-09-11)
[Full Changelog](https://github.com/DragonBox/u3d/compare/v1.0.2...v1.0.3)

**Implemented enhancements:**

- u3d/internal: create a argescape cross platform method [\#132](https://github.com/DragonBox/u3d/issues/132)
- u3d/prettifyer should fail with contextual information to ease improvement [\#128](https://github.com/DragonBox/u3d/issues/128)
- u3d: accept password-less sudo [\#126](https://github.com/DragonBox/u3d/issues/126)

**Fixed bugs:**

- u3d run: -logFile /dev/stdout causes crashes on Linux [\#43](https://github.com/DragonBox/u3d/issues/43)

**Closed issues:**

- Create a full circleci mac/linux example [\#15](https://github.com/DragonBox/u3d/issues/15)

**Merged pull requests:**

- Automate bump & changelog tasks [\#135](https://github.com/DragonBox/u3d/pull/135) ([lacostej](https://github.com/lacostej))
- u3d/prettifyer: fail with contextual information \(Fixes \#128\) [\#134](https://github.com/DragonBox/u3d/pull/134) ([lacostej](https://github.com/lacostej))
- u3d/internal: introduce a argescape string function \(Fixes \#132\) [\#133](https://github.com/DragonBox/u3d/pull/133) ([lacostej](https://github.com/lacostej))
- u3d/credentials support empty passwords for passwordless sudo \(Fixes \#128\) [\#130](https://github.com/DragonBox/u3d/pull/130) ([lacostej](https://github.com/lacostej))
- Download file now prints progress also in non interactive mode \(only in verbose\) [\#129](https://github.com/DragonBox/u3d/pull/129) ([lacostej](https://github.com/lacostej))

## [v1.0.2](https://github.com/DragonBox/u3d/tree/v1.0.2) (2017-09-05)
[Full Changelog](https://github.com/DragonBox/u3d/compare/v1.0.1...v1.0.2)

**Implemented enhancements:**

- u3d/prettify: catch missing dependencies errors on Linux [\#123](https://github.com/DragonBox/u3d/issues/123)
- Prettifyer not plugged when using -logFile /dev/stdout [\#18](https://github.com/DragonBox/u3d/issues/18)
- u3d/prettify: modify compiler rule parsing for 2017+ [\#121](https://github.com/DragonBox/u3d/pull/121) ([niezbop](https://github.com/niezbop))
- ud3/prettify: improve exception logging rules [\#118](https://github.com/DragonBox/u3d/pull/118) ([niezbop](https://github.com/niezbop))
- u3d/available: linux: do not try to fetch package size if already cached [\#116](https://github.com/DragonBox/u3d/pull/116) ([lacostej](https://github.com/lacostej))
- u3d/dependencies: add command to install Linux dependencies [\#25](https://github.com/DragonBox/u3d/pull/25) ([niezbop](https://github.com/niezbop))

**Fixed bugs:**

- u3d install updating cache even with --no-download option [\#104](https://github.com/DragonBox/u3d/issues/104)

**Merged pull requests:**

- u3d/prettify: add rule to catch library loading errors [\#124](https://github.com/DragonBox/u3d/pull/124) ([niezbop](https://github.com/niezbop))
- u3d/prettify: also plug log analyzer on stdout \(Fixes \#18 \#43\) [\#122](https://github.com/DragonBox/u3d/pull/122) ([lacostej](https://github.com/lacostej))
- u3d/install: do not refresh cache when download disabled \(Fixes \#104\) [\#120](https://github.com/DragonBox/u3d/pull/120) ([lacostej](https://github.com/lacostej))

## [v1.0.1](https://github.com/DragonBox/u3d/tree/v1.0.1) (2017-08-31)
[Full Changelog](https://github.com/DragonBox/u3d/compare/v1.0.0...v1.0.1)

**Merged pull requests:**

- u3d/downloader: use\_ssl should be set dynamically to download from https [\#113](https://github.com/DragonBox/u3d/pull/113) ([lacostej](https://github.com/lacostej))

## [v1.0.0](https://github.com/DragonBox/u3d/tree/v1.0.0) (2017-08-31)
[Full Changelog](https://github.com/DragonBox/u3d/compare/v1.0.0.rc1...v1.0.0)

## [v1.0.0.rc1](https://github.com/DragonBox/u3d/tree/v1.0.0.rc1) (2017-08-30)
[Full Changelog](https://github.com/DragonBox/u3d/compare/v0.9.4...v1.0.0.rc1)

**Implemented enhancements:**

- u3d/install: move chmod +x of linux files at install time  [\#91](https://github.com/DragonBox/u3d/issues/91)

**Fixed bugs:**

- Log prettifier not logging command line arguments \(among other initialisation things\) on Unity 2017+ [\#99](https://github.com/DragonBox/u3d/issues/99)
- Error if stdout closed while writing to it [\#96](https://github.com/DragonBox/u3d/issues/96)
- Downloader not as fast as it should be [\#93](https://github.com/DragonBox/u3d/issues/93)

**Closed issues:**

- u3d/prettify: missing executeMethod failure / exception catching [\#102](https://github.com/DragonBox/u3d/issues/102)
- Ensure u3d works well on ruby 2.4.1 [\#82](https://github.com/DragonBox/u3d/issues/82)

**Merged pull requests:**

- u3d: prepare for 1.0.0.rc1 release [\#111](https://github.com/DragonBox/u3d/pull/111) ([lacostej](https://github.com/lacostej))
- fastlane-plugin-u3d: allow to depend on coming 1.0.0 version [\#109](https://github.com/DragonBox/u3d/pull/109) ([lacostej](https://github.com/lacostej))
- u3d/run allow to configure the rules.json location using U3D\_RULES\_PATH env variable [\#108](https://github.com/DragonBox/u3d/pull/108) ([lacostej](https://github.com/lacostej))
- u3d/run: if thread exits abnormally, don't wait for it and return [\#107](https://github.com/DragonBox/u3d/pull/107) ([lacostej](https://github.com/lacostej))
- Add log rules to parse exceptions and aborts [\#106](https://github.com/DragonBox/u3d/pull/106) ([niezbop](https://github.com/niezbop))
- Fix INIT log phase not starting when intended [\#101](https://github.com/DragonBox/u3d/pull/101) ([niezbop](https://github.com/niezbop))
- u3d/install: move chmod +x of linux files at install time \(Fixes \#91\) [\#100](https://github.com/DragonBox/u3d/pull/100) ([lacostej](https://github.com/lacostej))
- logger: Hide EPIPE errors when stdout already closed [\#97](https://github.com/DragonBox/u3d/pull/97) ([lacostej](https://github.com/lacostej))

## [v0.9.4](https://github.com/DragonBox/u3d/tree/v0.9.4) (2017-08-28)
[Full Changelog](https://github.com/DragonBox/u3d/compare/v0.9.3...v0.9.4)

**Implemented enhancements:**

- Merge install and local\_install commands [\#84](https://github.com/DragonBox/u3d/issues/84)
- Document installation path sanitization [\#50](https://github.com/DragonBox/u3d/issues/50)
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
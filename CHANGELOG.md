# Changelog

## [v1.3.4](https://github.com/DragonBox/u3d/tree/v1.3.4) (2024-10-30)

[Full Changelog](https://github.com/DragonBox/u3d/compare/v1.3.2...v1.3.4)

**Closed issues:**

- u3d available getting a 403 [\#433](https://github.com/DragonBox/u3d/issues/433)
- `'user_error!': Unknown method 'info'` when List package or install unity [\#432](https://github.com/DragonBox/u3d/issues/432)
- Unable to install unity 2021.3.7f1 on windows [\#430](https://github.com/DragonBox/u3d/issues/430)
- unity\_versions.rb:70 can't modify frozen String: "" [\#429](https://github.com/DragonBox/u3d/issues/429)

**Merged pull requests:**

- \[CI\] Drop Circle now that we use github since 532bb2792ab5eda2449b80131bce… [\#446](https://github.com/DragonBox/u3d/pull/446) ([lacostej](https://github.com/lacostej))
- Drop ruby 2.5, support 3.2 and 3.3. Adjust dependencies, improve rubocop support and adjust CI on github.  [\#445](https://github.com/DragonBox/u3d/pull/445) ([lacostej](https://github.com/lacostej))
- Bump nio4r to pass installation on some CI platforms [\#444](https://github.com/DragonBox/u3d/pull/444) ([lacostej](https://github.com/lacostej))
- Update package dependencies to resolve circular dependency issue [\#440](https://github.com/DragonBox/u3d/pull/440) ([langtind](https://github.com/langtind))
- Preparing release for 1.3.3 [\#436](https://github.com/DragonBox/u3d/pull/436) ([niezbop](https://github.com/niezbop))
- fix: don't attempt to append to frozen string [\#435](https://github.com/DragonBox/u3d/pull/435) ([jlsalmon](https://github.com/jlsalmon))
- \[Fix\] U3d::Utils: replace Ruby agent with another one to bypass 403 from Unity [\#434](https://github.com/DragonBox/u3d/pull/434) ([niezbop](https://github.com/niezbop))
- fix: replace usage of nonexistent UI.info method [\#431](https://github.com/DragonBox/u3d/pull/431) ([jlsalmon](https://github.com/jlsalmon))
- Preparing release for 1.3.2 [\#428](https://github.com/DragonBox/u3d/pull/428) ([lacostej](https://github.com/lacostej))

## [v1.3.2](https://github.com/DragonBox/u3d/tree/v1.3.2) (2022-06-08)

[Full Changelog](https://github.com/DragonBox/u3d/compare/v1.3.1...v1.3.2)

**Merged pull requests:**

- Add Fiddle to gemspec / dependencies [\#427](https://github.com/DragonBox/u3d/pull/427) ([lacostej](https://github.com/lacostej))
- Run rspec within bundle exec [\#426](https://github.com/DragonBox/u3d/pull/426) ([lacostej](https://github.com/lacostej))
- Remove appveyor [\#425](https://github.com/DragonBox/u3d/pull/425) ([lacostej](https://github.com/lacostej))
- Fix parameter to update\_checker [\#424](https://github.com/DragonBox/u3d/pull/424) ([lacostej](https://github.com/lacostej))

## [v1.3.1](https://github.com/DragonBox/u3d/tree/v1.3.1) (2022-05-18)

[Full Changelog](https://github.com/DragonBox/u3d/compare/v1.3.0...v1.3.1)

**Closed issues:**

- `u3d install 2019.4.35f1` fails at 1.3.0 [\#421](https://github.com/DragonBox/u3d/issues/421)

**Merged pull requests:**

- \[Fix\] Broken install command, fixes \#421 [\#422](https://github.com/DragonBox/u3d/pull/422) ([lacostej](https://github.com/lacostej))
- Release 1.3.0 [\#420](https://github.com/DragonBox/u3d/pull/420) ([lacostej](https://github.com/lacostej))

## [v1.3.0](https://github.com/DragonBox/u3d/tree/v1.3.0) (2022-05-16)

[Full Changelog](https://github.com/DragonBox/u3d/compare/v1.2.3...v1.3.0)

**Closed issues:**

- Install without password/sudo [\#418](https://github.com/DragonBox/u3d/issues/418)
- u3d install gives error about missing Win32 dependency.  [\#415](https://github.com/DragonBox/u3d/issues/415)
- Segmentation Fault with Win32API [\#414](https://github.com/DragonBox/u3d/issues/414)
- Can't find 2019.4.14f LTS in u3d available. [\#412](https://github.com/DragonBox/u3d/issues/412)
- Missing Linux versions in central cache [\#408](https://github.com/DragonBox/u3d/issues/408)
- Cannot install 2019.4.4f1 [\#401](https://github.com/DragonBox/u3d/issues/401)

**Merged pull requests:**

- Various gem updates to solve security vulnerabilities in development tools [\#419](https://github.com/DragonBox/u3d/pull/419) ([lacostej](https://github.com/lacostej))
- Support ruby3 and later on Windows \(fixes \#414\) [\#417](https://github.com/DragonBox/u3d/pull/417) ([lacostej](https://github.com/lacostej))
- Fix installation of modules for non latest releases [\#416](https://github.com/DragonBox/u3d/pull/416) ([lacostej](https://github.com/lacostej))
- Fixing error when installing Unity 2020 version in Linux [\#410](https://github.com/DragonBox/u3d/pull/410) ([DiegoTorresSED](https://github.com/DiegoTorresSED))

## [v1.2.3](https://github.com/DragonBox/u3d/tree/v1.2.3) (2020-02-26)

[Full Changelog](https://github.com/DragonBox/u3d/compare/v1.2.2...v1.2.3)

**Merged pull requests:**

- Allow to refresh the github changelog. Also fix them as we removed empty lines. [\#398](https://github.com/DragonBox/u3d/pull/398) ([lacostej](https://github.com/lacostej))
- Detect 2019 modules and allow to install 2019, skipping dmg install for now [\#392](https://github.com/DragonBox/u3d/pull/392) ([lacostej](https://github.com/lacostej))

## [v1.2.2](https://github.com/DragonBox/u3d/tree/v1.2.2) (2020-02-21)

[Full Changelog](https://github.com/DragonBox/u3d/compare/v1.2.1...v1.2.2)

**Fixed bugs:**

- Error management in invalid modules at least on macOS [\#385](https://github.com/DragonBox/u3d/issues/385)
- U3D\_EXTRA\_PATHS is improperly interpreted on Windows [\#383](https://github.com/DragonBox/u3d/issues/383)

**Closed issues:**

- github releases are not marked as latest nor contain changelogs [\#389](https://github.com/DragonBox/u3d/issues/389)

**Merged pull requests:**

- Bump Example1 dependencies that trigger security warning on github [\#396](https://github.com/DragonBox/u3d/pull/396) ([lacostej](https://github.com/lacostej))
- Create Github releases. Required for \#390. \[Fixes \#389\] [\#395](https://github.com/DragonBox/u3d/pull/395) ([lacostej](https://github.com/lacostej))
- Support displaying u3d updates [\#390](https://github.com/DragonBox/u3d/pull/390) ([lacostej](https://github.com/lacostej))
- u3d/install: convert Windows paths to ruby paths when treating U3D\_EXTRA\_PATHS [\#388](https://github.com/DragonBox/u3d/pull/388) ([lacostej](https://github.com/lacostej))
- u3d/install: verify package names before we ensure setup coherence \(fixes \#385\) \(regression from 1.2.0\) [\#387](https://github.com/DragonBox/u3d/pull/387) ([lacostej](https://github.com/lacostej))

## [v1.2.1](https://github.com/DragonBox/u3d/tree/v1.2.1) (2019-11-15)

[Full Changelog](https://github.com/DragonBox/u3d/compare/v1.2.0...v1.2.1)

**Implemented enhancements:**

- u3d 1.2.0 not compatible with fastlane [\#379](https://github.com/DragonBox/u3d/issues/379)
- Lower dependency on rubyzip to 1.3.0 for fastlane compatibility [\#380](https://github.com/DragonBox/u3d/pull/380) ([niezbop](https://github.com/niezbop))

## [v1.2.0](https://github.com/DragonBox/u3d/tree/v1.2.0) (2019-11-15)

[Full Changelog](https://github.com/DragonBox/u3d/compare/v1.1.5...v1.2.0)

**Implemented enhancements:**

- 2019.x Android package: Install SDK & NDK Tools [\#359](https://github.com/DragonBox/u3d/issues/359)
- u3d/installer: Enable the download/installation of modules from Unity Hub [\#375](https://github.com/DragonBox/u3d/pull/375) ([niezbop](https://github.com/niezbop))

**Fixed bugs:**

- installation\_path parameter problems [\#371](https://github.com/DragonBox/u3d/issues/371)
- u3d list command does not work in non-standard path [\#370](https://github.com/DragonBox/u3d/issues/370)
- New linux versions are not visible in u3d [\#369](https://github.com/DragonBox/u3d/issues/369)
- I can't execute commands if I have an alpha version installed [\#354](https://github.com/DragonBox/u3d/issues/354)
- Cannot start u3d within a working directory which path contains special characters. [\#352](https://github.com/DragonBox/u3d/issues/352)
- u3d/installation: fix the version retrieving for Windows on Unity 2019.2.x and onwards [\#374](https://github.com/DragonBox/u3d/pull/374) ([niezbop](https://github.com/niezbop))
- u3d/installer: support custom install paths through U3D\_EXTRA\_PATHS [\#373](https://github.com/DragonBox/u3d/pull/373) ([niezbop](https://github.com/niezbop))
- Use the VersionsFetcher with Unity's json on Linux as well [\#364](https://github.com/DragonBox/u3d/pull/364) ([niezbop](https://github.com/niezbop))

**Closed issues:**

- unity 2019.2.x on windows [\#367](https://github.com/DragonBox/u3d/issues/367)
- When using prettifier, have an option to write the raw log to file in case we need it [\#365](https://github.com/DragonBox/u3d/issues/365)
- u3d can't list all available versions for Linux [\#360](https://github.com/DragonBox/u3d/issues/360)
- Empty ini files prevent Unity installation [\#356](https://github.com/DragonBox/u3d/issues/356)

**Merged pull requests:**

- Bump ruby dependencies in examples to get rid of CVEs [\#372](https://github.com/DragonBox/u3d/pull/372) ([lacostej](https://github.com/lacostej))
- Prevent empty ini files from being created and ignore them \(fixes \#356\) [\#361](https://github.com/DragonBox/u3d/pull/361) ([lacostej](https://github.com/lacostej))
- u3d/internals: add a quote around active rule name with loggin parsing failures [\#358](https://github.com/DragonBox/u3d/pull/358) ([lacostej](https://github.com/lacostej))
- u3d/internals: prepare for adding a test suite for the prettifier. Supports \#119 [\#355](https://github.com/DragonBox/u3d/pull/355) ([lacostej](https://github.com/lacostej))
- u3d/internals: support accentuated characters in Windows Local App Data path. Fixes \#352 [\#353](https://github.com/DragonBox/u3d/pull/353) ([lacostej](https://github.com/lacostej))

## [v1.1.5](https://github.com/DragonBox/u3d/tree/v1.1.5) (2019-03-06)

[Full Changelog](https://github.com/DragonBox/u3d/compare/v1.1.4...v1.1.5)

**Fixed bugs:**

- u3d available not listing all versions on macOS [\#349](https://github.com/DragonBox/u3d/issues/349)

**Merged pull requests:**

- list/available: find Mac or Windows version based on the unity\_shader package. Fixes \#349 [\#350](https://github.com/DragonBox/u3d/pull/350) ([lacostej](https://github.com/lacostej))
- build: automatically set reviewer on pre\_release PR [\#348](https://github.com/DragonBox/u3d/pull/348) ([lacostej](https://github.com/lacostej))

## [v1.1.4](https://github.com/DragonBox/u3d/tree/v1.1.4) (2019-02-28)

[Full Changelog](https://github.com/DragonBox/u3d/compare/v1.1.3...v1.1.4)

**Implemented enhancements:**

- u3d/asset: add feature that enables easy inspection of asset in a Unity project [\#341](https://github.com/DragonBox/u3d/pull/341) ([niezbop](https://github.com/niezbop))

**Closed issues:**

- u3d returns code=0 if failed [\#343](https://github.com/DragonBox/u3d/issues/343)
- `user\_error!': package 'Mac' doesn't exist [\#340](https://github.com/DragonBox/u3d/issues/340)
- list fails when version does not follow standard format, e.g. MagicLeap versions [\#331](https://github.com/DragonBox/u3d/issues/331)
- Bug: Failed to install pkg file [\#310](https://github.com/DragonBox/u3d/issues/310)

**Merged pull requests:**

- u3d/list: support Magic Leap Versions parsing and sorting \(fixes \#331\) [\#346](https://github.com/DragonBox/u3d/pull/346) ([lacostej](https://github.com/lacostej))
- Update to latest hub to label PRs and remove the hardcoding of the user's repo [\#345](https://github.com/DragonBox/u3d/pull/345) ([lacostej](https://github.com/lacostej))
- u3d/install exit 1 when version not found. Fixes \#343 [\#344](https://github.com/DragonBox/u3d/pull/344) ([lacostej](https://github.com/lacostej))
- Add `-t*` flag for 7z when unpacking packages [\#342](https://github.com/DragonBox/u3d/pull/342) ([tony-rowan](https://github.com/tony-rowan))

## [v1.1.3](https://github.com/DragonBox/u3d/tree/v1.1.3) (2019-01-08)

[Full Changelog](https://github.com/DragonBox/u3d/compare/v1.1.2...v1.1.3)

**Implemented enhancements:**

- install/linux: fallback on ruby strings implementation \(fixes \#326\) [\#327](https://github.com/DragonBox/u3d/pull/327) ([lacostej](https://github.com/lacostej))

**Fixed bugs:**

- u3d/unity\_versions: fix missing latest versions [\#335](https://github.com/DragonBox/u3d/pull/335) ([niezbop](https://github.com/niezbop))

**Closed issues:**

- Last version not available using `u3d available` [\#337](https://github.com/DragonBox/u3d/issues/337)
- No Beta versions visible with u3d available [\#330](https://github.com/DragonBox/u3d/issues/330)
- installation.rb:210:in ``': No such file or directory - strings \(Errno::ENOENT\) [\#326](https://github.com/DragonBox/u3d/issues/326)

**Merged pull requests:**

- u3d/available: Make Linux 2018.3.0f2 available on linux \#337 [\#338](https://github.com/DragonBox/u3d/pull/338) ([tony-rowan](https://github.com/tony-rowan))
- Bump dependencies to remove dependency on rubyzip 1.2.1 [\#328](https://github.com/DragonBox/u3d/pull/328) ([lacostej](https://github.com/lacostej))

## [v1.1.2](https://github.com/DragonBox/u3d/tree/v1.1.2) (2018-07-12)

[Full Changelog](https://github.com/DragonBox/u3d/compare/v1.1.1...v1.1.2)

**Implemented enhancements:**

- u3d/available: Add option to not use the central cache [\#324](https://github.com/DragonBox/u3d/pull/324) ([niezbop](https://github.com/niezbop))

## [v1.1.1](https://github.com/DragonBox/u3d/tree/v1.1.1) (2018-07-12)

[Full Changelog](https://github.com/DragonBox/u3d/compare/v1.1.0...v1.1.1)

**Fixed bugs:**

- Unity 2018.2.x is not listed as available [\#321](https://github.com/DragonBox/u3d/issues/321)
- u3d/versions: Accept new pattern for mac above 2018.2+ [\#322](https://github.com/DragonBox/u3d/pull/322) ([niezbop](https://github.com/niezbop))
- u3d/runner: Fix -projectPath argument [\#320](https://github.com/DragonBox/u3d/pull/320) ([niezbop](https://github.com/niezbop))

**Closed issues:**

- Inconsistency regarding -projectpath / -projectPath argument [\#319](https://github.com/DragonBox/u3d/issues/319)
- Betas not fetched anymore [\#314](https://github.com/DragonBox/u3d/issues/314)

## [v1.1.0](https://github.com/DragonBox/u3d/tree/v1.1.0) (2018-06-27)

[Full Changelog](https://github.com/DragonBox/u3d/compare/v1.0.21...v1.1.0)

**Implemented enhancements:**

- Document parallel Unity runs [\#317](https://github.com/DragonBox/u3d/pull/317) ([niezbop](https://github.com/niezbop))

**Closed issues:**

- \[OSX\] \[Request?\] Not possible to run concurrent projects [\#316](https://github.com/DragonBox/u3d/issues/316)
- u3d available is not exhaustive [\#312](https://github.com/DragonBox/u3d/issues/312)

**Merged pull requests:**

- u3d/available: proper fetching of paginated archives \(fixes \#312\) [\#313](https://github.com/DragonBox/u3d/pull/313) ([lacostej](https://github.com/lacostej))

## [v1.0.21](https://github.com/DragonBox/u3d/tree/v1.0.21) (2018-04-27)

[Full Changelog](https://github.com/DragonBox/u3d/compare/v1.0.20...v1.0.21)

**Implemented enhancements:**

- u3d/install: do not ask for password when user is root on Linux [\#303](https://github.com/DragonBox/u3d/issues/303)
- u3d/prettify: report failures to parse logs automatically [\#146](https://github.com/DragonBox/u3d/issues/146)
- u3d/install do not ask for root password [\#304](https://github.com/DragonBox/u3d/pull/304) ([lacostej](https://github.com/lacostej))
- u3d/\* automatically retry admin privilege elevation \#236 [\#297](https://github.com/DragonBox/u3d/pull/297) ([lacostej](https://github.com/lacostej))
- u3d/sanitize: support dot\_not\_move [\#293](https://github.com/DragonBox/u3d/pull/293) ([lacostej](https://github.com/lacostej))
- u3d/ui: adjust a message that is use for more than just downloading unity [\#292](https://github.com/DragonBox/u3d/pull/292) ([lacostej](https://github.com/lacostej))
- u3d/sanitize: ensure Installation instance's root\_path is updated post move [\#291](https://github.com/DragonBox/u3d/pull/291) ([lacostej](https://github.com/lacostej))
- u3d/move command, renaming install dirs. Support long version names. Fixes \#274 [\#289](https://github.com/DragonBox/u3d/pull/289) ([lacostej](https://github.com/lacostej))
- u3d/console: an interactive version of u3d \(Fixes \#265\) [\#283](https://github.com/DragonBox/u3d/pull/283) ([lacostej](https://github.com/lacostej))

**Fixed bugs:**

- Unity Installations fail on Windows with space in path [\#302](https://github.com/DragonBox/u3d/issues/302)
- u3d/internals: grant\_admin wasn't using has\_admin\_privileges? to get the privileges on non windows platforms [\#301](https://github.com/DragonBox/u3d/pull/301) ([lacostej](https://github.com/lacostej))

**Closed issues:**

- Include build number when renaming hotfix releases of Unity [\#274](https://github.com/DragonBox/u3d/issues/274)
- u3d should ask again for password if wrong password is given in interactive mode [\#236](https://github.com/DragonBox/u3d/issues/236)
- u3d: non UTF-8 environments can cause issues. [\#147](https://github.com/DragonBox/u3d/issues/147)

**Merged pull requests:**

- u3d/console: remove require on pry [\#307](https://github.com/DragonBox/u3d/pull/307) ([lacostej](https://github.com/lacostej))
- Allow spaces in installation paths on Windows \#302 [\#306](https://github.com/DragonBox/u3d/pull/306) ([lacostej](https://github.com/lacostej))
- u3d/install: support full pkg for Linux [\#305](https://github.com/DragonBox/u3d/pull/305) ([lacostej](https://github.com/lacostej))
- u3d/internals: fallback on admin move of creating u3d\_do\_not\_move if needed [\#300](https://github.com/DragonBox/u3d/pull/300) ([lacostej](https://github.com/lacostej))
- u3d/list: identify versions that can't be moved with a ! [\#298](https://github.com/DragonBox/u3d/pull/298) ([lacostej](https://github.com/lacostej))
- u3d/internals: move windows\_path from U3d::Utils to U3dCore::Helper and reuse it in AdminTools [\#296](https://github.com/DragonBox/u3d/pull/296) ([lacostej](https://github.com/lacostej))
- u3d/internals: extract the move\_file into U3dCore::AdminTools [\#295](https://github.com/DragonBox/u3d/pull/295) ([lacostej](https://github.com/lacostej))
- u3d/sanitize: sanitize on list only + cleanups and refactors [\#294](https://github.com/DragonBox/u3d/pull/294) ([lacostej](https://github.com/lacostej))
- u3d/list: properly identify the build number [\#288](https://github.com/DragonBox/u3d/pull/288) ([lacostej](https://github.com/lacostej))
- u3d/examples: support Unity 2017.3+, identified while investigating \#3 [\#286](https://github.com/DragonBox/u3d/pull/286) ([lacostej](https://github.com/lacostej))
- u3d/\* Detect incorrect locale \(Fixes \#147\) [\#285](https://github.com/DragonBox/u3d/pull/285) ([lacostej](https://github.com/lacostej))
- u3d/list: introduce format and make sure the list\_installed return an array of versions [\#284](https://github.com/DragonBox/u3d/pull/284) ([lacostej](https://github.com/lacostej))

## [v1.0.20](https://github.com/DragonBox/u3d/tree/v1.0.20) (2018-04-19)

[Full Changelog](https://github.com/DragonBox/u3d/compare/v1.0.19...v1.0.20)

**Implemented enhancements:**

- u3d/list: display full revision number \(prepares for \#274\) [\#280](https://github.com/DragonBox/u3d/pull/280) ([lacostej](https://github.com/lacostej))
- u3d/prettify: catch build pipeline messages [\#279](https://github.com/DragonBox/u3d/pull/279) ([niezbop](https://github.com/niezbop))
- u3d/prettify: fix exception rule start pattern [\#273](https://github.com/DragonBox/u3d/pull/273) ([niezbop](https://github.com/niezbop))
- u3d/\*: failure reporter [\#267](https://github.com/DragonBox/u3d/pull/267) ([niezbop](https://github.com/niezbop))
- Move duplicated data\_path out of U3d::Cache/U3d::INIparser to U3dCore::Helper [\#266](https://github.com/DragonBox/u3d/pull/266) ([niezbop](https://github.com/niezbop))

**Fixed bugs:**

- UnityEngine.Debug.Log\[Error|Warning|\]Format do not appear in u3d run output [\#269](https://github.com/DragonBox/u3d/issues/269)
- u3d/prettify: Catch Enlighten jobs failure [\#272](https://github.com/DragonBox/u3d/pull/272) ([niezbop](https://github.com/niezbop))

**Closed issues:**

- u3d/log catch all BuildPipeline:BuildPlayerInternalNoCheck messages [\#278](https://github.com/DragonBox/u3d/issues/278)
- New LTS releases not recognised [\#276](https://github.com/DragonBox/u3d/issues/276)
- cache stopped building [\#275](https://github.com/DragonBox/u3d/issues/275)
- incompatible character encodings: CP850 and UTF-8 [\#268](https://github.com/DragonBox/u3d/issues/268)

**Merged pull requests:**

- u3d/available support LTS \(\#276\) [\#277](https://github.com/DragonBox/u3d/pull/277) ([lacostej](https://github.com/lacostej))
- Document locale unicode requirements \(fixes \#268\) [\#271](https://github.com/DragonBox/u3d/pull/271) ([lacostej](https://github.com/lacostej))
- u3d/prettify: Fix UnityEngine.Debug.LogXXXFormat not being caught [\#270](https://github.com/DragonBox/u3d/pull/270) ([niezbop](https://github.com/niezbop))

## [v1.0.19](https://github.com/DragonBox/u3d/tree/v1.0.19) (2018-03-09)

[Full Changelog](https://github.com/DragonBox/u3d/compare/v1.0.18...v1.0.19)

**Implemented enhancements:**

- u3d: standardize log and descriptions [\#263](https://github.com/DragonBox/u3d/pull/263) ([niezbop](https://github.com/niezbop))

**Merged pull requests:**

- u3d/licenses: add feature to display licenses [\#262](https://github.com/DragonBox/u3d/pull/262) ([lacostej](https://github.com/lacostej))

## [v1.0.18](https://github.com/DragonBox/u3d/tree/v1.0.18) (2018-03-08)

[Full Changelog](https://github.com/DragonBox/u3d/compare/v1.0.17...v1.0.18)

**Closed issues:**

- error: Net::ReadTimeout [\#258](https://github.com/DragonBox/u3d/issues/258)

**Merged pull requests:**

- u3d/\* allow to modify Net::HTTP read timeout \(all rubies\) and max retries \(ruby 2.5+\) default values. Change read time out to 300 sec \(fixes \#258\) [\#260](https://github.com/DragonBox/u3d/pull/260) ([lacostej](https://github.com/lacostej))

## [v1.0.17](https://github.com/DragonBox/u3d/tree/v1.0.17) (2018-03-05)

[Full Changelog](https://github.com/DragonBox/u3d/compare/v1.0.16...v1.0.17)

**Closed issues:**

- Latest versions not listed on linux [\#256](https://github.com/DragonBox/u3d/issues/256)
- Unable to use U3D to install latest beta 2018.1.0b\[8|7\] [\#255](https://github.com/DragonBox/u3d/issues/255)

**Merged pull requests:**

- Detect missing 3 Linux versions \(fixes \#255 and \#256\) [\#257](https://github.com/DragonBox/u3d/pull/257) ([lacostej](https://github.com/lacostej))

## [v1.0.16](https://github.com/DragonBox/u3d/tree/v1.0.16) (2018-02-04)

[Full Changelog](https://github.com/DragonBox/u3d/compare/v1.0.15...v1.0.16)

**Implemented enhancements:**

- support install of .xz files [\#251](https://github.com/DragonBox/u3d/issues/251)
- Linux ini partial support exists now [\#244](https://github.com/DragonBox/u3d/issues/244)

**Fixed bugs:**

- u3d/install & u3d/available no INI file error on Linux [\#242](https://github.com/DragonBox/u3d/issues/242)
- u3d/prettify: Fix rule termination when there are special characters in the file name [\#246](https://github.com/DragonBox/u3d/pull/246) ([niezbop](https://github.com/niezbop))

**Closed issues:**

- u3d/available missing latest versions on Linux [\#241](https://github.com/DragonBox/u3d/issues/241)
- u3d/install fails to install Linux dependencies inside docker [\#240](https://github.com/DragonBox/u3d/issues/240)

**Merged pull requests:**

- u3d/install linux xz format \(fixes \#251\) [\#252](https://github.com/DragonBox/u3d/pull/252) ([lacostej](https://github.com/lacostej))
- u3d/available: support broken parts of Linux INI \(\#244\) [\#248](https://github.com/DragonBox/u3d/pull/248) ([lacostej](https://github.com/lacostej))
- u3d/available: fix forums parsing and move ini faking/downloading at available time, to support package based Linux versions [\#247](https://github.com/DragonBox/u3d/pull/247) ([lacostej](https://github.com/lacostej))
- u3d/prettify: Parse Android command invocation failure [\#245](https://github.com/DragonBox/u3d/pull/245) ([niezbop](https://github.com/niezbop))
- Support linux forums pagination [\#243](https://github.com/DragonBox/u3d/pull/243) ([lacostej](https://github.com/lacostej))

## [v1.0.15](https://github.com/DragonBox/u3d/tree/v1.0.15) (2018-01-16)

[Full Changelog](https://github.com/DragonBox/u3d/compare/v1.0.14...v1.0.15)

**Fixed bugs:**

- u3d/install: download beta for mac also needs to discard checking md5s on Windows packages [\#234](https://github.com/DragonBox/u3d/pull/234) ([lacostej](https://github.com/lacostej))

## [v1.0.14](https://github.com/DragonBox/u3d/tree/v1.0.14) (2018-01-15)

[Full Changelog](https://github.com/DragonBox/u3d/compare/v1.0.13...v1.0.14)

**Implemented enhancements:**

- Support 2018.1.0b2 VisualStudio package installation [\#225](https://github.com/DragonBox/u3d/issues/225)
- u3d/install: improve messages [\#231](https://github.com/DragonBox/u3d/pull/231) ([niezbop](https://github.com/niezbop))
- u3d/install: add support for installing .msi packages on Windows [\#230](https://github.com/DragonBox/u3d/pull/230) ([niezbop](https://github.com/niezbop))

**Merged pull requests:**

- Appveyor support / Windows build automation [\#228](https://github.com/DragonBox/u3d/pull/228) ([lacostej](https://github.com/lacostej))
- u3d/install Unity 2018. Download works on Windows and Mac and Mac installs. Fixes \#225 [\#227](https://github.com/DragonBox/u3d/pull/227) ([lacostej](https://github.com/lacostej))
- u3d/install: allow to download from one platform while on another one [\#226](https://github.com/DragonBox/u3d/pull/226) ([lacostej](https://github.com/lacostej))

## [v1.0.13](https://github.com/DragonBox/u3d/tree/v1.0.13) (2018-01-09)

[Full Changelog](https://github.com/DragonBox/u3d/compare/v1.0.12...v1.0.13)

**Implemented enhancements:**

- u3d/install: allow to specify packages download directory [\#213](https://github.com/DragonBox/u3d/issues/213)
- u3d/available: fetch versions data from a central repository, speeding up identification of available releases [\#142](https://github.com/DragonBox/u3d/issues/142)
- u3d/available: introduce a central cache \(fixes \#142\) [\#217](https://github.com/DragonBox/u3d/pull/217) ([lacostej](https://github.com/lacostej))
- u3d/available: allow to match using regular expression [\#216](https://github.com/DragonBox/u3d/pull/216) ([lacostej](https://github.com/lacostej))
- u3d/install: allow to specify packages download directory using an environment variable [\#214](https://github.com/DragonBox/u3d/pull/214) ([niezbop](https://github.com/niezbop))
- u3d/prettify: remove Jenkins rules [\#211](https://github.com/DragonBox/u3d/pull/211) ([niezbop](https://github.com/niezbop))
- u3d/prettify: update ruleset with LICENSE SYSTEM rules [\#210](https://github.com/DragonBox/u3d/pull/210) ([niezbop](https://github.com/niezbop))

**Merged pull requests:**

- Rubocop 0.52.1 workaround. Fixed in rubocop master [\#218](https://github.com/DragonBox/u3d/pull/218) ([lacostej](https://github.com/lacostej))
- u3d/internals: a serie of cache related refactors [\#215](https://github.com/DragonBox/u3d/pull/215) ([lacostej](https://github.com/lacostej))
- Update to latest rubocop [\#212](https://github.com/DragonBox/u3d/pull/212) ([lacostej](https://github.com/lacostej))

## [v1.0.12](https://github.com/DragonBox/u3d/tree/v1.0.12) (2018-01-03)

[Full Changelog](https://github.com/DragonBox/u3d/compare/v1.0.11...v1.0.12)

**Implemented enhancements:**

- Incorrect package check downloads and reinstalls it [\#198](https://github.com/DragonBox/u3d/issues/198)

**Fixed bugs:**

- u3d/install enforce\_setup\_coherence interferes with download only operation [\#206](https://github.com/DragonBox/u3d/issues/206)
- Fix unity\_version argument of fastlane plugin u3d type [\#193](https://github.com/DragonBox/u3d/pull/193) ([niezbop](https://github.com/niezbop))

**Merged pull requests:**

- u3d/install: download only should not filter out already installed packages \(fixes \#206\) [\#208](https://github.com/DragonBox/u3d/pull/208) ([lacostej](https://github.com/lacostej))
- u3d/install: help fixes [\#207](https://github.com/DragonBox/u3d/pull/207) ([lacostej](https://github.com/lacostej))
- u3d/install: do not reinstall already installed packages [\#202](https://github.com/DragonBox/u3d/pull/202) ([niezbop](https://github.com/niezbop))
- u3d/install: describe how password can be passed to u3d \(fixes \#200\) [\#201](https://github.com/DragonBox/u3d/pull/201) ([lacostej](https://github.com/lacostej))

## [v1.0.11](https://github.com/DragonBox/u3d/tree/v1.0.11) (2017-12-07)

[Full Changelog](https://github.com/DragonBox/u3d/compare/v1.0.10...v1.0.11)

**Implemented enhancements:**

- u3d/list: also detect previously installed deb packages on Linux \(fixes \#189\) [\#190](https://github.com/DragonBox/u3d/pull/190) ([lacostej](https://github.com/lacostej))

**Merged pull requests:**

- doc: explain CI setup with jenkins [\#191](https://github.com/DragonBox/u3d/pull/191) ([lacostej](https://github.com/lacostej))
- u3d/run: fail with a proper message when opening a Unity4 project [\#187](https://github.com/DragonBox/u3d/pull/187) ([lacostej](https://github.com/lacostej))

## [v1.0.10](https://github.com/DragonBox/u3d/tree/v1.0.10) (2017-11-03)

[Full Changelog](https://github.com/DragonBox/u3d/compare/v1.0.9...v1.0.10)

**Fixed bugs:**

- u3d/download progress bar on Windows not going to 100% [\#164](https://github.com/DragonBox/u3d/issues/164)

**Closed issues:**

- u3d/install: confusing "-p not available on linux" message [\#181](https://github.com/DragonBox/u3d/issues/181)
- u3d/install: already installed packages are reinstalled [\#161](https://github.com/DragonBox/u3d/issues/161)

**Merged pull requests:**

- u3d/download/install: --all option was broken. Added tests [\#184](https://github.com/DragonBox/u3d/pull/184) ([lacostej](https://github.com/lacostej))
- u3d install: Improve Linux warnings for package options \(fixes \#181\) [\#183](https://github.com/DragonBox/u3d/pull/183) ([lacostej](https://github.com/lacostej))
- Fix log termination [\#180](https://github.com/DragonBox/u3d/pull/180) ([niezbop](https://github.com/niezbop))
- u3d/list find package names under PlaybackEngines ivy.xml [\#178](https://github.com/DragonBox/u3d/pull/178) ([lacostej](https://github.com/lacostej))
- u3d/downloader: print progress improvements \(fix \#164\) [\#177](https://github.com/DragonBox/u3d/pull/177) ([lacostej](https://github.com/lacostej))

## [v1.0.9](https://github.com/DragonBox/u3d/tree/v1.0.9) (2017-10-31)

[Full Changelog](https://github.com/DragonBox/u3d/compare/v1.0.8...v1.0.9)

**Implemented enhancements:**

- Implement uninstall [\#174](https://github.com/DragonBox/u3d/issues/174)
- u3d/install: find all patched versions [\#172](https://github.com/DragonBox/u3d/issues/172)

**Merged pull requests:**

- u3d/available: discover all patched releases \(fixes \#172\) [\#173](https://github.com/DragonBox/u3d/pull/173) ([lacostej](https://github.com/lacostej))
- Implement uninstall. Also modify the output of list on Mac and deprecate Installation.path in favor of Installation.root\_path [\#171](https://github.com/DragonBox/u3d/pull/171) ([lacostej](https://github.com/lacostej))
- u3d/cleanups small refactorings and cleanups [\#170](https://github.com/DragonBox/u3d/pull/170) ([lacostej](https://github.com/lacostej))

## [v1.0.8](https://github.com/DragonBox/u3d/tree/v1.0.8) (2017-10-18)

[Full Changelog](https://github.com/DragonBox/u3d/compare/v1.0.7...v1.0.8)

**Fixed bugs:**

- `install': uninitialized constant U3d::Globals \(NameError\) [\#166](https://github.com/DragonBox/u3d/issues/166)
- u3d doesn't detect Unity version anterior to 5.0 on Windows [\#165](https://github.com/DragonBox/u3d/issues/165)

**Merged pull requests:**

- Fix Windows version detection for Unity4 \(fixes \#165\) [\#168](https://github.com/DragonBox/u3d/pull/168) ([niezbop](https://github.com/niezbop))
- Fix module name issue for Globals call [\#167](https://github.com/DragonBox/u3d/pull/167) ([niezbop](https://github.com/niezbop))

## [v1.0.7](https://github.com/DragonBox/u3d/tree/v1.0.7) (2017-10-03)

[Full Changelog](https://github.com/DragonBox/u3d/compare/v1.0.6...v1.0.7)

**Closed issues:**

- u3d/install: weird mac spurious install issues [\#160](https://github.com/DragonBox/u3d/issues/160)

**Merged pull requests:**

- u3d/install: properly search for freshly installed versions on Mac \(fixes \#160\) [\#162](https://github.com/DragonBox/u3d/pull/162) ([lacostej](https://github.com/lacostej))

## [v1.0.6](https://github.com/DragonBox/u3d/tree/v1.0.6) (2017-10-02)

[Full Changelog](https://github.com/DragonBox/u3d/compare/v1.0.5...v1.0.6)

**Implemented enhancements:**

- docs/Add how to install ruby to README [\#154](https://github.com/DragonBox/u3d/pull/154) ([niezbop](https://github.com/niezbop))

**Closed issues:**

- Make it obvious that ruby 2.0 is not properly supported [\#157](https://github.com/DragonBox/u3d/issues/157)

**Merged pull requests:**

- u3d/all: detect ruby 2.0 usage and move checks into compatibility file \(fixes \#157\) [\#158](https://github.com/DragonBox/u3d/pull/158) ([lacostej](https://github.com/lacostej))
- u3d/all feature/detect bash on ubuntu on windows \(fixed \#150\) [\#155](https://github.com/DragonBox/u3d/pull/155) ([niezbop](https://github.com/niezbop))

## [v1.0.5](https://github.com/DragonBox/u3d/tree/v1.0.5) (2017-09-28)

[Full Changelog](https://github.com/DragonBox/u3d/compare/v1.0.4...v1.0.5)

**Merged pull requests:**

- u3d/help: document verbose [\#152](https://github.com/DragonBox/u3d/pull/152) ([lacostej](https://github.com/lacostej))
- docs: document u3d usage on CI servers and how-to troubleshoot [\#151](https://github.com/DragonBox/u3d/pull/151) ([lacostej](https://github.com/lacostej))
- u3d/credentials fix ArgumentError in commands \(fixes \#148\) [\#149](https://github.com/DragonBox/u3d/pull/149) ([niezbop](https://github.com/niezbop))

## [v1.0.4](https://github.com/DragonBox/u3d/tree/v1.0.4) (2017-09-16)

[Full Changelog](https://github.com/DragonBox/u3d/compare/v1.0.3...v1.0.4)

**Fixed bugs:**

- u3d/installer might not see a newly installed version on Mac [\#139](https://github.com/DragonBox/u3d/issues/139)
- Issue with using installer (error: undefined method `\[\]' for nil:NilClass.\) [\#138](https://github.com/DragonBox/u3d/issues/138)

**Merged pull requests:**

- u3d/available: restore Linux version. [\#144](https://github.com/DragonBox/u3d/pull/144) ([lacostej](https://github.com/lacostej))
- u3d/installer: allow to find the installation we just installed, and fallback on spotlight on mac [\#143](https://github.com/DragonBox/u3d/pull/143) ([lacostej](https://github.com/lacostej))
- u3d/analyzer: remove extra end of lines in context information [\#141](https://github.com/DragonBox/u3d/pull/141) ([lacostej](https://github.com/lacostej))
- u3d/installer: hard fail if we ask for a non existant package \(Related to \#138\) [\#140](https://github.com/DragonBox/u3d/pull/140) ([lacostej](https://github.com/lacostej))
- u3d/internal: load all internal modules in top 'u3d' file [\#137](https://github.com/DragonBox/u3d/pull/137) ([lacostej](https://github.com/lacostej))

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
- Improve the docs, in particular with run and auto-detection of the current project [\#78](https://github.com/DragonBox/u3d/pull/78) ([lacostej](https://github.com/lacostej))
- Do not crash when no PlaybackEngines are found [\#74](https://github.com/DragonBox/u3d/pull/74) ([lacostej](https://github.com/lacostej))
- A missing license header [\#67](https://github.com/DragonBox/u3d/pull/67) ([lacostej](https://github.com/lacostej))
- \[tech\] Installer unit tests. Initial commit [\#60](https://github.com/DragonBox/u3d/pull/60) ([lacostej](https://github.com/lacostej))
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



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*

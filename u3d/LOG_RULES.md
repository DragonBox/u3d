# Log Analyzer rules

The Log Analyzer processes both Unity output and existing log files thanks to a set of JSON rules. These rules are under ./config/log_rules.json. They are meant to be customizable to fit as best as possible your logging specifications.

This document explains how to customize the ruleset.

## I - Foreword

### A - Log Analysis Philosophy

The main thing to understand behind our rule system is that it is based on a whitelist approach: anything coming in the analyzer will be ignored unless it matches a rule, in which case it will be processed accordingly.

The reason behind this approach is that Unity generates a lot of unwanted noise that would have been complicated to filter out. By filtering in, only relevant and/or expected information will be logged, allowing for a much clearer output, and better understanding of what is happening during Unity's runtime.

### B - Patterns

The log analyzer relies heavily on 'patterns' to follow the Unity output and extract information. These patterns are regular expressions which will be used to parse the returned lines. They are declared as regular `string` in the rules file, but are parsed to standard Ruby Regexp later on, and therefore follow their syntax.

For more information on how to use patterns, please refer to [Ruby's Regexp Documentation](https://ruby-doc.org/core-2.3.1/Regexp.html).

## II - Phases

### A - Phased behaviour of the analyzer

As Unity usually goes through different phases during running, compilation or whichever action you want it to perform, the information (and its processing) that it will output will most likely be dependent on the action being performed.
Therefore, our log analyzer behaves in a phased fashion. It has an inner memory keeping track of the active 'phase' Unity is going through, the ruleset it applies depends on it.

A phase is started when a given pattern is encountered in the logs, and ends in two different ways: either a terminating pattern is met, or another phase starts.

Because there are rules that you may want to apply throughout the whole analysis, there is a peculiar phase: the 'GENERAL' one. It contains a generic set of rules which will be applied in parallel to the active phase's ruleset, and allows for not having to repeat rules in different phases. The main use which this phase was designed for is to catch exceptions, warnings and errors no matter the active phase, but it is obviously not limited to that.

### B - Phase syntax

The syntax of phases is as follows:

```json
"PHASE_NAME": {
  "active": true,
  "silent": false,
  "comment": "This is an optional comment for clarity purpose",
  "phase_start_pattern": "This pattern ends the phase",
  "phase_end_pattern": "This pattern ends the phase",
  "rules": {
    "rule_1": {},
    "rule_2": {}
  }
}
```
* `active`: controls whether or not the phase should be active. If the phase is not active the analyzer will never try to start it, nor applying its rules.
* __[OPTIONAL]__ `silent`: the phase will start and end normally, it will nonetheless never try to apply its rules, resulting in the phase being logically present, even though silent. More or less an alternative to toggling off every rule in its ruleset.
* __[OPTIONAL]__ `comment`: short description of the phase. This section is only for readability purpose and will be ignored during parsing as it does not contain logic.
* `phase_start_pattern`: this is a mandatory pattern that controls the condition under which the phase will start.
* __[OPTIONAL]__ `phase_end_pattern`: this patterns specifies when the phase should end. It is optional because a phase will also end when another one begins, as stated in II A. This is used when you know exactly when the phase has finished.
* `rules`: contains a set of rules. See III for further information on rule declaration.

## Rules

### A - Rule declaration

The information contained in Unity's log can be formatted differently: it can be contained in a single line, spread on several, the lines can contain exactly what you want or be way too verbose for your liking.

In consequence, the rule syntax is pretty loose to cover as many cases as possible, and below is describe syntax for some of archetypal rules.

They contain nonetheless two mandatory sections:

```json
"rule_name": {
  "active": true,
  "start_pattern": "This pattern will start the rule"
}
```
Similarly to phases, `active` will control whether or not the rule should be applied, and the `start_pattern` will trigger the rule.

### B - One line parsing, unfiltered

The most basic rule is when you want to extract a single line without having to do any processing on it. Here is an example:

```json
"asset_DB_loading": {
  "active": true,
  "start_pattern": "Loading Asset Database ?... {,2}\\d+\\.?\\d*"
}
```

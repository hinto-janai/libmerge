# WORK IN PROGRESS - libmerge
>Function for merging files together in Bash

## Contents
- [About](#About)
- [Speed](#Speed)
- [Usage](#Usage)
- [Input](#Input)
- [Example](#Example)
- [Errors](#Errors)

## About
This function merges two files (`a` and `b`) together, usually an old configuration file and a new one. It RETAINS anything changed within `a` while ADDING the new lines found in `b`, ***in the correct order.*** Requires `sed` and Bash v4+. Requires `grep` if the `--diff` option is given.

## Speed
The process of `merge()` is:
1. Load files into memory
2. Create a `sed` find/replace argument for every line in the old file
3. Invoke `sed` with the long argument we just made

The new file (that is in memory now) is piped into `sed` ***once.*** This process essentially creates a very long `sed` find/replace script and invokes it once, instead of invoking `sed` with a single argument every loop, which would be exponentially slower.

| lines of text | merge() time |
|---------------|--------------|
| 10            | 0.001s       |
| 50            | 0.020s       |
| 100           | 0.035s       |
| 250           | 0.080s       |
| 500           | 0.100s       |
| 1000          | 0.450s       |

## Usage
Copy the `merge()` function from `merge.sh` into your script [or preferably, use hbc to "compile" this library together with your script, click here for more details.](https://github.com/hinto-janaiyo/hbc)

## Input
`merge()` requires at the minimum 2 arguments:
- `OLD_FILE`
- `NEW_FILE`

`merge()` without extra flags will output the merged file to standard out.

With a third optional argument: `--diff`, a colored diff-like output will print instead. Empty line additions will not be printed, but will be added during a normal `merge()`. **Note: this option will use `grep`**

## Example
File `a`:
```bash
ONE=these
TWO=are
THREE=some
FOUR=values
FIVE=i
SIX=would
SEVEN=like
EIGHT=to
NINE=keep
TEN=around
```
File `b`:
```bash
ONE=
TWO=

# new comment
NEW=
VARIABLES=

THREE=
FOUR=
FIVE=
```
Simply overwriting `a` with `b` (`cat b > a`) would destroy the old contents of `a`. Appending (`cat b >> a`) would be better, but in this instance, it wouldn't merge the two files in the correct order. Running `merge a b` would output:
```
ONE=these
TWO=are

# new comment
NEW=
VARIABLES=

THREE=some
FOUR=values
FIVE=i
```
The old values from `a` carried over, values found in `a` but NOT in `b` are deprecated and removed. New values from `b` are added in the correct locations.

## Errors
| Exit Code | Reason                                      |
|-----------|---------------------------------------------|
| 1         | error creating local variables for config() |
| 2         | 2 or 3 arguments were not given             |
| 3         | $1 file doesn't exist or is not a file      |
| 4         | $2 file doesn't exist or is not a file      |
| 5         | do not have permission to read file $1      |
| 6         | do not have permission to read file $2      |
| 7         | error reading from the file $1              |
| 8         | error reading from the file $2              |
| 9         | file $1 is empty                            |
| 10        | file $2 is empty                            |
| 11        | could not turn on `shopt -s extglob`        |
| 12        | `sed` error                                 |

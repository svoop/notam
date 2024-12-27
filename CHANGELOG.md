## Main

Nothing so far

## 1.1.6

#### Changes
* Update Ruby to 3.4
* Add ignore list for fixtures broken upstream

## 1.1.5

#### Changes
* Add support for Ruby 3.3

## 1.1.4

#### Changes
* Drop obsolete countries gem

## 1.1.3

#### Changes
* Don't wrap years when breaking down date ranges
* Allow HJ and HN in schedules

## 1.1.2

#### Fixes
* Carry over last base date instead of first base date

## 1.1.1

#### Fixes
* Carry over base date for multiple D-item elements which partially omit to
  mention the month in every element

## 1.1.0

#### Additions
* Extract subject group and condition group on Q item

## 1.0.0

#### Breaking Changes
* `NOTAM::Schedule.parse` now returns an array of `NOTAM_Schedule` instances
  instead of just a single one.

#### Changes
* Edge case tolerant extraction of `PART n OF n` and `END PART n OF n` markers

#### Additions
* Support for datetime ranges (i.e. `1 APR 2000-20 MAY 2000`) as well as times
  across midnight (i.e. `1 APR 1900-0500`) on D items.
* Wrap all exceptions raised while parsing items.

## 0.1.3

#### Fixes
* Reverse accidentally flipped F and G item.

## 0.1.2

#### Changes
* The five day schedules are calculated starting today if `effective_at` is
  in the past.

## 0.1.1

#### Changes
* Update dependency on AIXM gem

## 0.1.0

#### Initial Implementation
* Require Ruby 3.0
* `NOTAM::Message` and `NOTAM::Item` (Header, Q, A-G, Footer)
* `NOTAM::Schedule` with useful tools like `slice` and `resolve`
* Expansion of contractions on E item
* Tests against live NOTAM

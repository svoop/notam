## Main

Nothing so far

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

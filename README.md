[![Version](https://img.shields.io/gem/v/notam.svg?style=flat)](https://rubygems.org/gems/notam)
[![Tests](https://img.shields.io/github/workflow/status/svoop/notam/Test.svg?style=flat&label=tests)](https://github.com/svoop/notam/actions?workflow=Test)
[![Code Climate](https://img.shields.io/codeclimate/maintainability/notam/notam.svg?style=flat)](https://codeclimate.com/github/svoop/notam/)
[![Donorbox](https://img.shields.io/badge/donate-on_donorbox-yellow.svg)](https://donorbox.org/bitcetera)

# NOTAM

Parser for [NOTAM (Notice to Airmen)](https://www.icao.int/safety/istars/pages/notams.aspx) messages in Ruby.

* [Homepage](https://github.com/svoop/notam)
* [API](https://www.rubydoc.info/gems/notam)
* Author: [Sven Schwyn - Bitcetera](https://bitcetera.com)

## Install

### Security

This gem is [cryptographically signed](https://guides.rubygems.org/security/#using-gems) in order to assure it hasn't been tampered with. Unless already done, please add the author's public key as a trusted certificate now:

```
gem cert --add <(curl -Ls https://raw.github.com/svoop/notam/main/certs/svoop.pem)
```

### Bundler

Add the following to the `Gemfile` or `gems.rb` of your [Bundler](https://bundler.io) powered Ruby project:

```ruby
gem notam
```

And then install the bundle:

```
bundle install --trust-policy MediumSecurity
```

## Usage

```ruby
raw_notam_text_message = <<~END
  A1484/02 NOTAMN
  Q) EGTT/QMRXX/IV/NBO/A/000/999/5129N00028W005
  A) EGLL
  B) 0208231540
  C) 0210310500 EST
  E) RWY 09R/27L DUE WIP NO CENTRELINE, TDZ OR SALS LIGHTING AVBL
END

notam = NOTAM.parse(raw_notam_text_message)
notam.valid?  # => true
notam.data    # => Hash
```

Since NOTAM may contain a certain level of redundancy, the parser does some integrity checks, fixes the payload if possible and issues a warning.

The resulting hash contains a representation of the NOTAM which can be consumed by other code such as [AIPP](https://rubygems.org/gems/aipp).

You get a `NOTAM::ParseError` in case the raw NOTAM text message fails to be parsed. If you're sure the NOTAM is correct, please [submit an issue](#development) or fix the bug and [submit a pull request](#development).

See the [API documentation](https://www.rubydoc.info/gems/notam) for more.

⚠️ Only NOTAM compatible with the ICAO annex 15 are supported for now. Most notably in the USA other NOTAM formats exist which cannot be parsed using this gem.

### FIR

Four letter FIR codes assigned by the ICAO follow some logic, albeit there exist exceptions and inconsistencies e.g. for historical reasons. Let's take an easy example:

```
L F M M
┬ ┬ ─┬─
│ │  └─ global area: L => lower Europe
│ └──── geopolitical unit: F => France
└────── subsection: MM => Marseille
```

The informal use of only the first two letters often stands for a combination of all subsections contained therein. Example: `LF` is a combination of `LFBB`, `LFEE`, `LFFF`, `LFMM` and `LFRR`.

FIR codes ending with `XX` specify more than one subsection. Example: `LFXX` is a combination of two subsections with in `LF`. In NOTAM, this notation may be used on the Q item if (and only if) the affected subsections are listed on the A item.

### Series

The first letter of the NOTAM ID is identifying the series. The following example is part of series `S`:

```
S0054/02 NOTAMN
```

AIS are free to define series as they please, however, a few conventions have emerged:

* **Series A**<br>General rules, en-route navigation and communication facilities, airspace restrictions and activities taking place above FL 245 as well as information concerning major international aerodromes.
* **Series B**<br>Information on airspace restrictions, on activities taking place at or below FL 245 and on other international aerodromes at which IFR flights are permitted.
* **Series C**<br>Information on other international aerodromes at which only VFR flights are permitted.
* **Series D**<br>Information on national aerodromes
* **Series E**<br>Information on heliports
* **Series S** (aka: SNOWTAM)<br>Surface condition reports
* **Series T**<br>Reserved for NOTAM processing units in cases when basic operational information was not triggered by the issuing AIS.
* **Series V** (aka: ASHTAM)<br>Volcano ash condition reports

### Special NOTAM

#### Checklist

Checklist NOTAM are periodically issued lists of all currently effective NOTAM. They are used for cross checking and can usually be ignored for flight planning. Their Q item contain `Q..KK` which is decoded as "condition: :checklist", here's an example:

```
Q) EDXX/QKKKK/K /K  /K /000/999/5123N01018E999
```

#### Trigger

Trigger NOTAM are referring to another source of information such as AIP SUP (AIP supplement). Their Q item contain `Q..TT` which is decoded as "condition: :trigger", here's an example:

```
Q) LFXX/QRTTT/IV/BO /W /000/035/4708N00029E010
```

Note: Trigger NOTAM are never published as series `T`.

### Schedules

For compatibility, schedule dates and times are expressed using the corresponding classes from the [AIXM gem](https://rubygems.org/gems/aixm):

* [Date](https://www.rubydoc.info/gems/aixm/AIXM/Schedule/Date)
* [Day](https://www.rubydoc.info/gems/aixm/AIXM/Schedule/Day)
* [Time](https://www.rubydoc.info/gems/aixm/AIXM/Schedule/Time)

### References

* [ICAO Annex 15 on NOTAM](https://www.bazl.admin.ch/bazl/en/home/specialists/regulations-and-guidelines/legislation-and-directives/anhaenge-zur-konvention-der-internationalen-zivilluftfahrtorgani.html)
* [NOTAM Q Codes](https://www.faa.gov/air_traffic/publications/atpubs/notam_html/appendix_b.html)
* [Guide de la consultation NOTAM (fr)](https://www.sia.aviation-civile.gouv.fr/pub/media/news/file/g/u/guide_de_la_consultation_notam_05-10-2017-1.pdf)
* [NOTAM Contractions](https://www.notams.faa.gov/downloads/contractions.pdf)
* [NOTAM format cheat sheet](http://vat-air.dk/files/ICAO%20NOTAM%20format.pdf)
* [Introduction on Wikipedia](https://en.wikipedia.org/wiki/NOTAM)

## Translations

You find the translations for each available language in `lib/locales/`. Additional translations are very welcome provided you have sufficient aeronautical background knowledge.

Please [create a translation request issue](https://github.com/svoop/notam/issues), then duplicate the `lib/locales/en.yml` reference language file and translate it.

## Tests and Fixtures

The test suite may run against live NOTAM if you set the `SPEC_SCOPE` environment variable:

```
export SPEC_SCOPE=all        # run against all NOTAM fixtures
export SPEC_SCOPE=all-fast   # run against all NOTAM fixtures but exit on the first failure
export SPEC_SCOPE=W0214/22   # run against given NOTAM fixture only
```

The NOTAM fixtures are written to `spec/fixtures`, you can manage them using a Rake tasks:

```
rake --tasks fixtures
```

## Development

To install the development dependencies and then run the test suite:

```
bundle install
bundle exec rake    # run tests once
bundle exec guard   # run tests whenever files are modified
```

You're welcome to [submit issues](https://github.com/svoop/notam/issues) and contribute code by [forking the project and submitting pull requests](https://docs.github.com/en/get-started/quickstart/fork-a-repo).

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

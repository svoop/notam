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

Add the following to the <samp>Gemfile</samp> or <samp>gems.rb</samp> of your [Bundler](https://bundler.io) powered Ruby project:

```ruby
gem notam
```

And then install the bundle:

```
bundle install --trust-policy MediumSecurity
```

## Usage

```ruby
raw_message = <<~END
  A1484/02 NOTAMN
  Q) EGTT/QMRXX/IV/NBO/A/000/999/5129N00028W005
  A) EGLL
  B) 0208231540
  C) 0210310500 EST
  E) RWY 09R/27L DUE WIP NO CENTRELINE, TDZ OR SALS LIGHTING AVBL
END

notam = NOTAM.parse(raw_message)
notam.valid?                  # => true
notam.fir                     # => "EGLL"
notam.country                 # => "UK"
notam.center_xy               # => #<AIXM::XY 51.48333333N 000.46666667W>
notam.radius                  # => #<AIXM::D 5.0 nm>
notam.effective_at            # => 2002-08-23 15:40:00.000000 +0000
notam.expiration_at           # => 2002-10-31 05:00:00.000000 +0000
notam.estimated_expiration?   # => true
```

See the [API documentation](https://www.rubydoc.info/gems/notam) for more.

⚠️ Only NOTAMs compatible with the ICAO annex 15 are supported for now. Most notably in the USA other NOTAM formats exist which cannot be parsed using this gem.

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

FIR codes ending with `XX` specify more than one subsection. Example: `LFXX` is a combination of two subsections with in `LF`. In NOTAMs, this notation may be used on the Q item if (and only if) the affected subsections are listed on the A item.

### References

* [ICAO Annex 15 on NOTAM](https://www.bazl.admin.ch/bazl/en/home/specialists/regulations-and-guidelines/legislation-and-directives/anhaenge-zur-konvention-der-internationalen-zivilluftfahrtorgani.html)
* [NOTAM Q Codes](https://www.faa.gov/air_traffic/publications/atpubs/notam_html/appendix_b.html)
* [Guide de la consultation NOTAM (fr)](https://www.sia.aviation-civile.gouv.fr/pub/media/news/file/g/u/guide_de_la_consultation_notam_05-10-2017-1.pdf)
* [NOTAM Contractions](https://www.notams.faa.gov/downloads/contractions.pdf)
* [NOTAM format cheat sheet](http://vat-air.dk/files/ICAO%20NOTAM%20format.pdf)
* [Introduction on Wikipedia](https://en.wikipedia.org/wiki/NOTAM)

## Translations

You find the translations for each available language in <samp>lib/locales/</samp>. Additional translations are very welcome provided you have sufficient aeronautical background knowledge.

Please [create a translation request issue](https://github.com/svoop/notam/issues), then duplicate the <samp>lib/locales/en.yml</samp> reference language file and translate it.

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

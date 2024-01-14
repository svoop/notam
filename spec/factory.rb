# frozen_string_literal: true

module NOTAM
  class Factory
    class << self

      def message
        @message ||= {
          single:
            <<~NEND,
              A0135/20 NOTAMN
              Q) EGTT/QMRXX/IV/NBO/A/000/999/5129N00028W005
              A) EGLL
              B) 0201010600
              C) 0203312300
              D) MON-WED FRI SR MINUS15-1130 EXC 01-02 FEB 01-02 MAR 01-02
              E) RWY 09R/27L DUE WIP NO CENTRELINE, TDZ OR SALS LIGHTING AVBL
              F) 2000 FT AMSL
              G) 2050 FT AMSL
              CREATED: 01 Jan 2002 01:00:00
              SOURCE: LSSNYNYX
            NEND
          partitioned_without_end:
            <<~NEND,
              D3616/22 NOTAMN
              Q) EDGG/QRTCA/IV/BO /W /000/100/5003N00804E012
              A) EDGG PART 10 OF 11 B) 2211160800 C) 2211181800
              D) NOV 16 0800-2200, NOV 17 0500-2200, NOV 18 0500-1800
              E) TEMPO RESTRICTED AREA EDR RHEINGAU ESTABLISHED
              CREATED: 15 Nov 2022 15:42:00
              SOURCE: EUECYIYN
            NEND
          partitioned_with_end:
            <<~NEND,
              D3616/22 NOTAMN
              Q) EDGG/QRTCA/IV/BO /W /000/100/5003N00804E012
              A) EDGG PART 1 OF 2 B) 2211160800 C) 2211181800
              D) NOV 16 0800-2200, NOV 17 0500-2200, NOV 18 0500-1800
              E) TEMPO RESTRICTED AREA EDR RHEINGAU ESTABLISHED
              END PART 1 OF 2
              CREATED: 15 Nov 2022 15:42:00
              SOURCE: EUECYIYN
            NEND
          partitioned_with_end_anywhere:
            <<~NEND,
              D3616/22 NOTAMN
              Q) EDGG/QRTCA/IV/BO /W /000/100/5003N00804E012
              A) EDGG PART 2 OF 2 B) 2211160800 C) 2211181800
              D) NOV 16 0800-2200, NOV 17 0500-2200, NOV 18 0500-1800
              E) - FLTS CONDUCTED ENTIRELY UNDER IFR
              F) GND G) FL100
              END PART 2 OF 2
              CREATED: 15 Nov 2022 15:42:00
              SOURCE: EUECYIYN
            NEND
        }
      end

      def header
        @header ||= {
          new: 'A0135/20 NOTAMN',
          replace: 'A0137/20 NOTAMR A0135/20',
          cancel: 'A0139/20 NOTAMC A0137/20'
        }
      end

      def q
        @q ||= {
          egtt: 'Q) EGTT/QMRLC/IV/NBO/AE/000/999/5129N00028W005',
          lfnt: 'Q) LFNT/QMRXX/V /M  /A /000/999/4359N00445E001'
        }
      end

      def a
        @a ||= {
          egll: 'A) EGLL',
          lsas: 'A) LSAS LOVV LIMM'
        }
      end

      def b
        @b ||= {
          fix: 'B) 0208231540'
        }
      end

      def c
        @c ||= {
          fix: 'C) 0210310200',
          estimated: 'C) 0210310500 EST',
          spaceless: 'C) 0210041030EST',
          permanent: 'C) PERM'
        }
      end

      def d
        @d ||= {
          two_months: 'D) FEB 08-28 2000-2200, MAR 01-05 1800-2200',
          one_month: 'D) 16 23 H24, 19 21-24 28 0600-1700',
          simple_implicit_months: 'D) MAY 27 0530-1000, 30 0800-2100, 31 0530-2100, JUN 05 0800-2159, 06-08 0530-2159, 09 0530-1400',
          complex_implicit_months: 'D) JUN 13-15 JUL 04-06 0530-2159, 08 10 0800-2159',
          weekdays: 'D) MON-FRI 0700-1100 1300-1700',
          date_with_exception: 'D) FEB 01-MAR 31 0700-1100 EXC FRI',
          daytime: 'D) SR-SS',
          invalid: 'D) 22 0700-1700 23 0430-1800 24 0430-1400'
        }
      end

      def e
        @e ||= {
          rwy: 'E) RWY 09R/27L DUE WIP NO CENTRELINE, TDZ OR SALS LIGHTING AVBL',
          appenzell: "E) CABLE CRANE 3.6KM SSW APPENZELL, LEN 1370M, 471759N0092340E,\n135.0M / 443.0FT AGL, 1328.9M / 4359.9FT AMSL.",
          poissy: "E) 'POISSY CENTRE HOSPITALIER' HLP CLOSED.",
          brieuc: "E) TOWER CRANE NEARBY  'SAINT BRIEUC HELISTATION CENTRE\nHOSPITALIER'- RDL117/0.07NM HELIPORT ARP\nPSN: 482925N 0024457W\nHEIGHT: 86FT\nLELEV : 442FT\nLIGHTING: NIGHT AND DAY"
        }
      end

      def f
        @f ||= {
          qnh: 'F) 2000 FT AMSL',
          qnh_m: 'F) 1000M AMSL',
          qfe: 'F) 2100FT AGL',
          qfe_m: 'F) 1100 M AGL',
          qne: 'F) FL100',
          qne_space: 'F) FL 110',
          sfc: 'F) SFC',
          gnd: 'F) GND'
        }
      end

      def g
        @g ||= {
          qnh: 'G) 2050 FT AMSL',
          qnh_m: 'G) 1050M AMSL',
          qfe: 'G) 2150FT AGL',
          qfe_m: 'G) 1150 M AGL',
          qne: 'G) FL150',
          qne_space: 'G) FL 160',
          unl: 'G) UNL'
        }
      end

      def footer
        @footer ||= {
          created: 'CREATED: 10 Feb 2022 07:00:00',
          source: 'SOURCE: LSSNYNYX'
        }
      end

      def schedule
        @schedule ||= {
          date: '05 1130-1330',
          dates: '05 09 13 1130-1330',
          dates_with_month: 'FEB 05 MAR 06 1100-1200',
          date_range: '05-18 1130-1330',
          date_range_with_exception: '05-18 1130-1330 EXC FRI',
          date_across_midnight: '08 29 2100-0600',
          date_range_with_month: 'FEB 01-MAR 31 0700-1100',
          date_range_across_end_of_year: 'DEC 30-JAN 02 H24',
          day: 'MON 0700-1900',
          days: 'MON WED FRI 0700-1900',
          day_range: 'MON-TUE 0700-1900',
          day_range_with_exception: 'MON-TUE 0700-1900 EXC FEB 15',
          day_across_midnight: 'MON 2200-0400',
          datetime: '08 0800-12 2000',
          datetime_with_exception: '08 0800-12 2000 EXC FRI',
          datetime_with_month: 'FEB 08 0800-MAR 12 2000',
          datetime_across_midnight: 'MAY 29 2200-MAY 30 2200',
          multiple_times: 'MON-FRI 0700-1100 1300-1700',
          multiple_times_across_midnight: 'MON 0700-1100 2300-0200',
          daily: 'DAILY 1000-2000',
          daily_across_midnight: 'DAILY 2200-0500',
          daytime: 'SR-SS',
          sun_to_hour: 'SR MINUS30-1500',
          hour_to_sun: '1000-SS PLUS30'
        }
      end

    end
  end
end

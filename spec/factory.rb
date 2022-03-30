# frozen_string_literal: true

module NOTAM
  class Factory
    class << self

      def header
        @header ||= {
          new: 'A0135/20 NOTAMN',
          replace: 'A0137/20 NOTAMR A0135/20',
          cancel: 'A0139/20 NOTAMC A0137/20'
        }
      end

      def q
        @q ||= {
          egtt: 'Q) EGTT/QMRXX/IV/NBO/A/000/999/5129N00028W005'
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
        }
      end

      def e
        @e ||= {
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
          unl: 'F) UNL'
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
          sfc: 'G) SFC',
          gnd: 'G) GND'
        }
      end

      def footer
        @footer ||= {
          created: 'CREATED: 10 Feb 2022 07:00:00',
          source: 'SOURCE: LSSNYNYX'
        }
      end

      def sample_message
        %i(header q a b c d e f g footer).map { send(_1).values.sample }.join("\n")
      end

    end
  end
end

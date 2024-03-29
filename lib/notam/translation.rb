# frozen_string_literal: true

module NOTAM

  class << self

    # Expand informal two letter ICAO FIR identifier.
    #
    # @example
    #   NOTAM.expand_fir('LF')   # => ["LFBB", "LFEE", "LFFF", "LFMM", "LFRR", "LFXX]
    #
    # @param fir [String] informal two letter ICAO FIR identifier
    # @return [Array<String>] four letter ICAO FIR identifiers
    def expand_fir(informal_fir)
      FIRS.keys.select { _1.start_with? informal_fir }.tap do |firs|
        fail(ArgumentError, "unknown wildcard FIR") unless firs.any?
        firs << "#{informal_fir}XX"
      end
    end

    # Get countries for the given ICAO FIR (wildcard) identifier
    #
    # @param fir [String] four letter ICAO FIR identifier
    # @return [Array<Symbol>] array of country ISO alpha 2 codes
    def countries_for(fir)
      FIRS.fetch(fir)
    end

    # Translates the NOTAM subject group code to human/machine readable symbol
    #
    # @param code [String] one letter subject group code
    # @return [Symbol] value from {NOTAM::SUBJECT_GROUPS}
    def subject_group_for(code)
      SUBJECT_GROUPS.fetch(code)
    end

    # Translates the NOTAM subject code to human/machine readable symbol
    #
    # @param code [String] two letter subject code
    # @return [Symbol] value from {NOTAM::SUBJECTS}
    def subject_for(code)
      SUBJECTS.fetch(code)
    end

    # Translates the NOTAM condition group code to human/machine readable symbol
    #
    # @param code [String] one letter condition group code
    # @return [Symbol] value from {NOTAM::CONDITION_GROUPS}
    def condition_group_for(code)
      CONDITION_GROUPS.fetch(code)
    end

    # Translates the NOTAM condition code to human/machine readable symbol
    #
    # @param code [String] two letter condition code
    # @return [Symbol] value from {NOTAM::CONDITIONS}
    def condition_for(code)
      CONDITIONS.fetch(code)
    end

    # Translates the NOTAM traffic code to human/machine readable symbol
    #
    # @param code [String] traffic code
    # @return [Symbol] value from {NOTAM::TRAFFIC}
    def traffic_for(code)
      TRAFFIC.fetch(code)
    end

    # Translates the NOTAM purpose code to human/machine readable symbol
    #
    # @param code [String] one letter purpose code
    # @return [Symbol] value from {NOTAM::PURPOSES}
    def purpose_for(code)
      PURPOSES.fetch(code)
    end

    # Translates the NOTAM scope code to human/machine readable symbol
    #
    # @param code [String] one letter scope code
    # @return [Symbol] value from {NOTAM::SCOPES}
    def scope_for(code)
      SCOPES.fetch(code)
    end

    # Expands and optionally translates the NOTAM contraction
    #
    # @param contraction [String] approved NOTAM contraction
    # @param translate [Boolean] returns expanded and translated String when
    #   +true+ or expanded only Symbol otherwise (default)
    # @return [Symbol, String, nil] expansion from {NOTAM::CONTRACTIONS},
    #   translation or +nil+
    def expand(contraction, translate: false)
      if expansion = CONTRACTIONS[contraction]
        translate ? I18n.t("contractions.#{expansion}", default: nil) : expansion
      end
    end
  end

  # FIR ICAO codes to countries
  #
  # @see https://en.wikipedia.org/wiki/Flight_information_region
  FIRS = {
    'AGGG' => [:SB],
    'ANAU' => [:NR],
    'AYPM' => [:PG],
    'BGGL' => [:GL, :DK],
    'BIRD' => [:IS],
    'CZEG' => [:CA],
    'CZQM' => [:CA],
    'CZQX' => [:CA],
    'CZUL' => [:CA],
    'CZVR' => [:CA],
    'CZWG' => [:CA],
    'CZYZ' => [:CA],
    'DAAA' => [:DZ],
    'DGAC' => [:GH],
    'DIII' => [:CI],
    'DNKK' => [:NG],
    'DRRR' => [:NE],
    'DTTC' => [:TN],
    'EZZZ' => [:BE],
    'EBBU' => [:BE, :LU],
    'EDGG' => [:DE],
    'EDMM' => [:DE],
    'EDUU' => [:DE],
    'EDVV' => [:DE],
    'EDWW' => [:DE],
    'EDYY' => [:BE, :DE, :NL],
    'EETT' => [:EE],
    'EFIN' => [:FI],
    'EGGX' => [:UK],
    'EGPX' => [:UK],
    'EGQQ' => [:UK],
    'EGTT' => [:UK],
    'EHAA' => [:NL],
    'EISN' => [:IE],
    'EKDK' => [:DK],
    'ENOB' => [:NO],
    'ENOR' => [:NO],
    'EPWW' => [:PL],
    'ESAA' => [:SE],
    'ESMM' => [:SE],
    'ESOS' => [:SE],
    'EVRR' => [:LV],
    'EYVL' => [:LT],
    'FABL' => [:ZA],
    'FACA' => [:ZA],
    'FACT' => [:ZA],
    'FADN' => [:ZA],
    'FAJO' => [:ZA],
    'FAJX' => [:ZA],
    'FAPX' => [:ZA],
    'FBGR' => [:BW],
    'FCCC' => [:CD],
    'FIMM' => [:MU],
    'FKKK' => [:CM],
    'FLFI' => [:ZM],
    'FMCX' => [:KM],
    'FMMM' => [:MG],
    'FNAN' => [:AO],
    'FOOO' => [:GA],
    'FQBE' => [:MZ],
    'FSSS' => [:SC],
    'FTTT' => [:TD],
    'FVHF' => [:ZW],
    'FWLL' => [:MW],
    'FYWF' => [:NA],
    'FZZA' => [:CG],
    'GCCC' => [:ES],
    'GLRB' => [:LR],
    'GMMM' => [:MA],
    'GOOO' => [:SN],
    'GVSC' => [:CV],
    'HAAA' => [:ET],
    'HBBA' => [:BI],
    'HCSM' => [:SO],
    'HECC' => [:EG],
    'HHAA' => [:EG],
    'HKNA' => [:KE],
    'HLLL' => [:LY],
    'HRYR' => [:RW],
    'HSSS' => [:SD],
    'HTDC' => [:TZ],
    'HUEC' => [:UG],
    'KZAB' => [:US],
    'KZAK' => [:US],
    'KZAU' => [:US],
    'KZBW' => [:US],
    'KZDC' => [:US],
    'KZDV' => [:US],
    'KZFW' => [:US],
    'KZHU' => [:US],
    'KZID' => [:US],
    'KZJX' => [:US],
    'KZKC' => [:US],
    'KZLA' => [:US],
    'KZLC' => [:US],
    'KZMA' => [:US],
    'KZME' => [:US],
    'KZMP' => [:US],
    'KZNY' => [:US],
    'KZOA' => [:US],
    'KZOB' => [:US],
    'KZSE' => [:US],
    'KZTL' => [:US],
    'KZWY' => [:US],
    'LAAA' => [:AL],
    'LBSR' => [:BG],
    'LBWR' => [:BG],
    'LCCC' => [:CY],
    'LDZO' => [:HR],
    'LECB' => [:ES],
    'LECM' => [:ES],
    'LECS' => [:ES],
    'LFBB' => [:FR],
    'LFEE' => [:FR],
    'LFFF' => [:FR],
    'LFMM' => [:FR],
    'LFRR' => [:FR],
    'LGGG' => [:GR],
    'LHCC' => [:HU],
    'LIBB' => [:IT],
    'LIMM' => [:IT],
    'LIRR' => [:IT],
    'LJLA' => [:SI],
    'LKAA' => [:CZ],
    'LLLL' => [:IL],
    'LMMM' => [:MT],
    'LOVV' => [:AT],
    'LPPC' => [:PT],
    'LPPO' => [:PT],
    'LQSB' => [:BA],
    'LRBB' => [:RO],
    'LSAG' => [:CH],
    'LSAS' => [:CH],
    'LSAZ' => [:CH],
    'LTAA' => [:TR],
    'LTBB' => [:TR],
    'LUUU' => [:MD],
    'LWSS' => [:MK],
    'LYBA' => [:RS],
    'LZBB' => [:SK],
    'MDCS' => [:DO],
    'MHTG' => [:HN],
    'MKJK' => [:JM],
    'MMFO' => [:MX],
    'MMFR' => [:MX],
    'MPZL' => [:PA],
    'MTEG' => [:HT],
    'MUFH' => [:CU],
    'MYNA' => [:BS],
    'NFFF' => [:FJ],
    'NTTT' => [:PF, :FR],
    'NWWX' => [:NC, :FR],
    'NZZC' => [:NZ],
    'NZZO' => [:NZ],
    'OAKX' => [:AF],
    'OBBB' => [:BH],
    'OEJD' => [:SA],
    'OIIX' => [:IR],
    'OJAC' => [:JO],
    'OKAC' => [:KW],
    'OLBB' => [:LB],
    'OMAE' => [:AE],
    'OOMM' => [:OM],
    'OPKR' => [:PK],
    'OPLR' => [:PK],
    'ORBB' => [:IQ],
    'ORMM' => [:IQ],
    'OSTT' => [:SY],
    'OYSC' => [:YE],
    'PAZA' => [:US],
    'PAZN' => [:US],
    'PHZH' => [:US],
    'RCAA' => [:TW],
    'RJJJ' => [:JA],
    'RKRR' => [:KR],
    'RPHI' => [:PH],
    'SACF' => [:AR],
    'SACU' => [:AR],
    'SAEF' => [:AR],
    'SAEU' => [:AR],
    'SAMF' => [:AR],
    'SAMV' => [:AR],
    'SARR' => [:AR],
    'SAVF' => [:AR],
    'SAVU' => [:AR],
    'SBAO' => [:BR],
    'SBAZ' => [:BR],
    'SBBS' => [:BR],
    'SBCW' => [:BR],
    'SBRE' => [:BR],
    'SCCZ' => [:CL],
    'SCEZ' => [:CL],
    'SCFZ' => [:CL],
    'SCIZ' => [:CL],
    'SCTZ' => [:CL],
    'SEFG' => [:EC],
    'SGFA' => [:PY],
    'SKEC' => [:CO],
    'SKED' => [:CO],
    'SLLF' => [:BO],
    'SMPM' => [:SR],
    'SOOO' => [:GF, :FR],
    'SPIM' => [:PU],
    'SUEO' => [:UY],
    'SVZM' => [:VE],
    'SYGC' => [:GY],
    'TJZS' => [:PR, :US],
    'TNCF' => [:CW, :NL],
    'TTZP' => [:TT],
    'UAAX' => [:KZ],
    'UACX' => [:KZ],
    'UAFX' => [:KG],
    'UASS' => [:KZ],
    'UDDD' => [:AM],
    'UEMH' => [:RU],
    'UENN' => [:RU],
    'UESS' => [:RU],
    'UESU' => [:RU],
    'UEVV' => [:RU],
    'UGEE' => [:RU],
    'UGGG' => [:GE],
    'UHBI' => [:RU],
    'UHHH' => [:RU],
    'UHMI' => [:RU],
    'UHMM' => [:RU],
    'UHMP' => [:RU],
    'UHNN' => [:RU],
    'UHPT' => [:RU],
    'UHPU' => [:RU],
    'UHSH' => [:RU],
    'UIKB' => [:RU],
    'UIKK' => [:RU],
    'UKBV' => [:UA],
    'UKCV' => [:UA],
    'UKDV' => [:UA],
    'UKFV' => [:UA],
    'UKHV' => [:UA],
    'UKLV' => [:UA],
    'UKOV' => [:UA],
    'ULLL' => [:RU],
    'ULOL' => [:RU],
    'UMKD' => [:RU],
    'UMMV' => [:BY],
    'UNLL' => [:RU],
    'UOTT' => [:RU],
    'URRV' => [:RU],
    'USDK' => [:RU],
    'USHB' => [:RU],
    'USHH' => [:RU],
    'UTAK' => [:TM],
    'UTNR' => [:UZ],
    'UTSD' => [:UZ],
    'UTTR' => [:UZ],
    'UUWV' => [:RU],
    'UUYW' => [:RU],
    'UUYY' => [:RU],
    'UWOO' => [:RU],
    'VABF' => [:IN],
    'VCCC' => [:LK],
    'VDPF' => [:KH],
    'VECF' => [:IN],
    'VGFR' => [:BD],
    'VHHK' => [:HK],
    'VIDF' => [:IN],
    'VLIV' => [:LA],
    'VLVT' => [:LA],
    'VNSM' => [:NP],
    'VOMF' => [:IN],
    'VRMF' => [:MV],
    'VTBB' => [:TH],
    'VVHM' => [:VN],
    'VVHN' => [:VN],
    'VYMD' => [:MM],
    'VYYF' => [:MM],
    'WAAF' => [:ID],
    'WAAZ' => [:ID],
    'WABZ' => [:ID],
    'WADZ' => [:ID],
    'WAJZ' => [:ID],
    'WAKZ' => [:ID],
    'WALZ' => [:ID],
    'WAMZ' => [:ID],
    'WAOZ' => [:ID],
    'WAPZ' => [:ID],
    'WATZ' => [:ID],
    'WBFC' => [:BN, :MY],
    'WIIF' => [:ID],
    'WIIZ' => [:ID],
    'WIMZ' => [:ID],
    'WIOZ' => [:ID],
    'WIPZ' => [:ID],
    'WMFC' => [:MY],
    'WSJC' => [:SG],
    'YBBB' => [:AU],
    'YMMM' => [:AU],
    'ZBPE' => [:CH],
    'ZGJD' => [:CH],
    'ZGZU' => [:CH],
    'ZHWH' => [:CH],
    'ZJSA' => [:CH],
    'ZKKP' => [:KP],
    'ZLHW' => [:CH],
    'ZMUB' => [:MN],
    'ZPKM' => [:CH],
    'ZSHA' => [:CH],
    'ZWUQ' => [:CH],
    'ZYSH' => [:CH]
  }.freeze

  # International NOTAM Q codes for subject groups
  #
  # @see https://www.faa.gov/air_traffic/publications/atpubs/notam_html/appendix_b.html
  SUBJECT_GROUPS = {
    'A' => :airspace_organization,
    'C' => :communications_and_surveillance_facilities,
    'F' => :facilities_and_services,
    'G' => :gnss_services,
    'I' => :instrument_and_microwave_landing_system,
    'K' => :checklist,
    'L' => :lighting_facilities,
    'M' => :movement_and_landing_area,
    'N' => :terminal_and_en_route_navigation_facilities,
    'O' => :other_information,
    'P' => :air_traffic_procedures,
    'R' => :airspace_restrictions,
    'S' => :air_traffic_and_volmet_services,
    'W' => :warning,
    'X' => :other
  }.freeze

  # International NOTAM Q codes for subjects
  #
  # @see https://www.faa.gov/air_traffic/publications/atpubs/notam_html/appendix_b.html
  SUBJECTS = {
    'AA' => :minimum_altitude,
    'AC' => :class_bcde_surface_area,
    'AD' => :air_defense_identification_zone,
    'AE' => :control_area,
    'AF' => :flight_information_region,
    'AH' => :upper_control_area,
    'AL' => :minimum_usable_flight_level,
    'AN' => :area_navigation_route,
    'AO' => :oceanic_control_area,
    'AP' => :reporting_point,
    'AR' => :ats_route,
    'AT' => :terminal_control_area,
    'AU' => :upper_flight_information_region,
    'AV' => :upper_advisory_area,
    'AX' => :significant_point,
    'AZ' => :aerodrome_traffic_zone,
    'CA' => :air_ground_facility,
    'CB' => :automatic_dependent_surveillance_broadcast,
    'CC' => :automatic_dependent_surveillance_contract,
    'CD' => :controller_pilot_data_link,
    'CE' => :en_route_surveillance_radar,
    'CG' => :ground_controlled_approach_system,
    'CL' => :selective_calling_system,
    'CM' => :surface_movement_radar,
    'CP' => :precision_approach_radar,
    'CR' => :surveillance_radar_element_of_par,
    'CS' => :secondary_surveillance_radar,
    'CT' => :terminal_area_surveillance_radar,
    'FA' => :aerodrome,
    'FB' => :friction_measuring_device,
    'FC' => :ceiling_measurement_equipment,
    'FD' => :docking_system,
    'FE' => :oxygen,
    'FF' => :fire_fighting_and_rescue,
    'FG' => :ground_movement_control,
    'FH' => :helicopter_alighting_area,
    'FI' => :aircraft_de_icing,
    'FJ' => :oils,
    'FL' => :landing_direction_indicator,
    'FM' => :meteorological_service,
    'FO' => :fog_dispersal_system,
    'FP' => :heliport,
    'FS' => :snow_removal_equipment,
    'FT' => :transmissometer,
    'FU' => :fuel_availability,
    'FW' => :wind_direction_indicator,
    'FZ' => :customs,
    'GA' => :gnss_airfield_specific_operations,
    'GW' => :gnss_area_wide_operations,
    'IC' => :instrument_landing_system,
    'ID' => :dme_associated_with_ils,
    'IG' => :glide_path,
    'II' => :inner_marker,
    'IL' => :localizer,
    'IM' => :middle_marker,
    'IN' => :localizer_without_ils,
    'IO' => :outer_marker,
    'IS' => :ils_category_1,
    'IT' => :ils_category_2,
    'IU' => :ils_category_3,
    'IW' => :microwave_landing_system,
    'IX' => :locator_outer,
    'IY' => :locator_middle,
    'KK' => :checklist,
    'LA' => :approach_lighting_system,
    'LB' => :aerodrome_beacon,
    'LC' => :runway_centre_line_lights,
    'LD' => :landing_direction_indicator_lights,
    'LE' => :runway_edge_lights,
    'LF' => :sequenced_flashing_lights,
    'LG' => :pilot_controlled_lighting,
    'LH' => :high_intensity_runway_lights,
    'LI' => :runway_end_identifier_lights,
    'LJ' => :runway_alignment_indicator_lights,
    'LK' => :category_2_components_of_als,
    'LL' => :low_intensity_runway_lights,
    'LM' => :medium_intensity_runway_lights,
    'LP' => :precision_approach_path_indicator,
    'LR' => :all_landing_area_lighting_facilities,
    'LS' => :stopway_lights,
    'LT' => :threshold_lights,
    'LU' => :helicopter_approach_path_indicator,
    'LV' => :visual_approach_slope_indicator_system,
    'LW' => :heliport_lighting,
    'LX' => :taxiway_centre_line_lights,
    'LY' => :taxiway_edge_lights,
    'LZ' => :runway_touchdown_zone_lights,
    'MA' => :movement_area,
    'MB' => :bearing_strength,
    'MC' => :clearway,
    'MD' => :declared_distances,
    'MG' => :taxiing_guidance_system,
    'MH' => :runway_arresting_gear,
    'MK' => :parking_area,
    'MM' => :daylight_markings,
    'MN' => :apron,
    'MO' => :stopbar,
    'MP' => :aircraft_stands,
    'MR' => :runway,
    'MS' => :stopway,
    'MT' => :threshold,
    'MU' => :runway_turning_bay,
    'MW' => :strip_shoulder,
    'MX' => :taxiway,
    'MY' => :rapid_exit_taxiway,
    'NA' => :all_radio_navigation_facilities,
    'NB' => :nondirectional_radio_beacon,
    'NC' => :decca,
    'ND' => :dme,
    'NF' => :fan_marker,
    'NL' => :locator,
    'NM' => :vor_dme,
    'NN' => :tacan,
    'NO' => :omega,
    'NT' => :vortac,
    'NV' => :vor,
    'OA' => :aeronautical_information_service,
    'OB' => :obstacle,
    'OE' => :aircraft_entry_requirements,
    'OL' => :obstacle_lights,
    'OR' => :rescue_coordination_centre,
    'PA' => :standard_instrument_arrival,
    'PB' => :standard_vfr_arrival,
    'PC' => :contingency_procedures,
    'PD' => :standard_instrument_departure,
    'PE' => :standard_vfr_departure,
    'PF' => :flow_control_procedure,
    'PH' => :holding_procedure,
    'PI' => :instrument_approach_procedure,
    'PK' => :vfr_approach_procedure,
    'PL' => :flight_plan_processing,
    'PM' => :aerodrome_operating_minima,
    'PN' => :noise_operating_restriction,
    'PO' => :obstacle_clearance_altitude,
    'PR' => :radio_failure_procedure,
    'PT' => :transition_altitude_or_level,
    'PU' => :missed_approach_procedure,
    'PX' => :minimum_holding_altitude,
    'PZ' => :adiz_procedure,
    'RA' => :airspace_reservation,
    'RD' => :danger_area,
    'RM' => :military_operating_area,
    'RO' => :overflying,
    'RP' => :prohibited_area,
    'RR' => :restricted_area,
    'RT' => :temporary_restricted_area,
    'SA' => :automatic_terminal_information_service,
    'SB' => :ats_reporting_office,
    'SC' => :area_control_centre,
    'SE' => :flight_information_service,
    'SF' => :aerodrome_flight_information_service,
    'SL' => :flow_control_centre,
    'SO' => :oceanic_area_control_centre,
    'SP' => :approach_control_service,
    'SS' => :flight_service_station,
    'ST' => :aerodrome_control_tower,
    'SU' => :upper_area_control_centre,
    'SV' => :volmet_broadcast,
    'SY' => :upper_advisory_service,
    'WA' => :air_display,
    'WB' => :aerobatics,
    'WC' => :captive_balloon_or_kite,
    'WD' => :demolition_of_explosives,
    'WE' => :exercises,
    'WF' => :air_refueling,
    'WG' => :glider_flying,
    'WH' => :blasting,
    'WJ' => :banner_towing,
    'WL' => :ascent_of_free_balloon,
    'WM' => :missile_gun_firing,
    'WP' => :parachute_paragliding_or_hang_gliding,
    'WR' => :radioactive_or_toxic_materials,
    'WS' => :blowing_gas,
    'WT' => :mass_movement_of_aircraft,
    'WU' => :unmanned_aircraft,
    'WV' => :formation_flight,
    'WW' => :volcanic_activity,
    'WY' => :aerial_survey,
    'WZ' => :model_flying,
    'XX' => :other
  }.freeze

  # International NOTAM Q codes for condition groups
  #
  # @see https://www.faa.gov/air_traffic/publications/atpubs/notam_html/appendix_b.html
  CONDITION_GROUPS = {
    'A' => :availability,
    'C' => :changes,
    'H' => :hazard_conditions,
    'K' => :checklist,
    'L' => :limitations,
    'T' => :trigger,
    'X' => :other
  }.freeze

  # International NOTAM Q codes for conditions
  #
  # @see https://www.faa.gov/air_traffic/publications/atpubs/notam_html/appendix_b.html
  CONDITIONS = {
    'AC' => :withdrawn_for_maintenance,
    'AD' => :available_for_daylight_operation,
    'AF' => :flight_checked_and_found_reliable,
    'AG' => :operating_but_ground_checked_only,
    'AH' => :hours_of_service,
    'AK' => :resumed_normal_operations,
    'AL' => :operative_subject_to_previously_published_conditions,
    'AM' => :military_operations_only,
    'AN' => :available_for_night_operation,
    'AO' => :operational,
    'AP' => :available_with_prior_permission,
    'AR' => :available_on_request,
    'AS' => :unserviceable,
    'AU' => :not_available,
    'AW' => :completely_withdrawn,
    'AX' => :previously_announced_shutdown_canceled,
    'CA' => :activated,
    'CC' => :completed,
    'CD' => :deactivated,
    'CE' => :erected,
    'CF' => :operating_frequency_changed,
    'CG' => :downgraded,
    'CH' => :changed,
    'CI' => :identification_changed,
    'CL' => :realigned,
    'CM' => :displaced,
    'CN' => :canceled,
    'CO' => :operating,
    'CP' => :operating_on_reduced_power,
    'CR' => :temporarily_replaced,
    'CS' => :installed,
    'CT' => :on_test,
    'HA' => :braking_action,
    'HB' => :friction_coefficient,
    'HC' => :covered_by_compacted_snow,
    'HD' => :covered_by_dry_snow,
    'HE' => :covered_by_water,
    'HF' => :free_of_snow_and_ice,
    'HG' => :grass_cutting_in_progress,
    'HH' => :hazard,
    'HI' => :covered_by_ice,
    'HJ' => :launch_planned,
    'HK' => :bird_migration_in_progress,
    'HL' => :snow_clearance_completed,
    'HM' => :marked,
    'HN' => :covered_by_wet_snow,
    'HO' => :obscured_by_snow,
    'HP' => :snow_clearance_in_progress,
    'HQ' => :operation_canceled,
    'HR' => :standing_water,
    'HS' => :sanding_in_progress,
    'HT' => :approach_according_to_signal_area_only,
    'HU' => :launch_in_progress,
    'HV' => :work_completed,
    'HW' => :work_in_progress,
    'HX' => :concentration_of_birds,
    'HY' => :snow_banks_exist,
    'HZ' => :covered_by_frozen_ruts,
    'KK' => :checklist,
    'LA' => :operating_on_auxiliary_power_supply,
    'LB' => :reserved_for_aircraft_based_therein,
    'LC' => :closed,
    'LD' => :unsafe,
    'LE' => :operating_without_auxiliary_power_supply,
    'LF' => :interference,
    'LG' => :operating_without_identification,
    'LH' => :unserviceable_for_heavier_aircraft,
    'LI' => :closed_to_ifr_operations,
    'LK' => :operating_as_fixed_light,
    'LL' => :usable_for_smaller_only,
    'LN' => :closed_to_night_operations,
    'LP' => :prohibited,
    'LR' => :restricted_to_runways_and_taxiways,
    'LS' => :subject_to_interruption,
    'LT' => :limited,
    'LV' => :closed_to_vfr_operations,
    'LW' => :will_take_place,
    'LX' => :operating_but_caution_advised,
    'TT' => :trigger,
    'XX' => :other
  }.freeze

  # Kinds of traffic
  TRAFFIC = {
    'IV' => :ifr_and_vfr,
    'I' => :ifr,
    'V' => :vfr,
    'K' => :checklist
  }.freeze

  # Purpose identifiers
  PURPOSES = {
    'N' => :immediate_attention,
    'B' => :operational_significance,
    'O' => :flight_operations,
    'M' => :miscellaneous,
    'K' => :checklist
  }.freeze

  # Scope identifiers
  SCOPES = {
    'A' => :aerodrome,
    'E' => :en_route,
    'W' => :navigation_warning,
    'K' => :checklist
  }.freeze

  # Approved NOTAM contractions
  #
  # @note Contractions are applied in the given order, therefore multi-word
  #   contractions should be listed first!
  #
  # @see https://www.notams.faa.gov/downloads/contractions.pdf
  CONTRACTIONS = {
    'AP LGT' => :airport_lighting,
    'BA FAIR' => :braking_action_fair,
    'BA NIL' => :braking_action_nil,
    'BA POOR' => :braking_action_poor,
    'DEP PROC' => :departure_procedure,
    'FAN MKR' => :fan_marker,
    'TDZ LGT' => :touchdown_zone_lights,
    'VOR VHF' => :omni_directional_radio_range,
    'ABN' => :airport_beacon,
    'ABV' => :above,
    'ACC' => :area_control_center,
    'ACCUM' => :accumulate,
    'ACFT' => :aircraft,
    'ACR' => :air_carrier,
    'ACT' => :active,
    'ADJ' => :adjacent,
    'ADZD' => :advised,
    'AFD' => :airport_facility_directory,
    'AGL' => :above_ground_level,
    'ALS' => :approach_lighting_system,
    'ALT' => :altitude,
    'ALTM' => :altimeter,
    'ALTN' => :alternate,
    'ALTNLY' => :alternately,
    'ALSTG' => :altimeter_setting,
    'AMDT' => :amendment,
    'AMGR' => :airport_manager,
    'AMOS' => :automatic_meteorological_observing_system,
    'AP' => :airport,
    'APCH' => :approach,
    'APP' => :approach_control,
    'ARFF' => :aircraft_rescue_and_fire_fighting,
    'ARR' => :arrival,
    'ASOS' => :automatic_surface_observing_system,
    'ASPH' => :asphalt,
    'ATC' => :air_traffic_control,
    'ATCCC' => :air_traffic_control_command_center,
    'ATIS' => :automatic_terminal_information_service,
    'AUTOB' => :automatic_weather_reporting_system,
    'AUTH' => :authority,
    'AVBL' => :available,
    'AWOS' => :automatic_weather_observing_system,
    'AWY' => :airway,
    'AZM' => :azimuth,
    'BC' => :back_course,
    'BCN' => :beacon,
    'BERM' => :snowbanks_containing_earth,
    'BLW' => :below,
    'BND' => :bound,
    'BRG' => :bearing,
    'BYD' => :beyond,
    'CAAS' => :class_a_airspace,
    'CAT' => :category,
    'CBAS' => :class_b_airspace,
    'CBSA' => :class_b_surface_area,
    'CCAS' => :class_c_airspace,
    'CCLKWS' => :counterclockwise,
    'CCSA' => :class_c_surface_area,
    'CD' => :clearance_delivery,
    'CDAS' => :class_d_airspace,
    'CDSA' => :class_d_surface_area,
    'CEAS' => :class_e_airspace,
    'CESA' => :class_e_surface_area,
    'CFR' => :code_of_federal_regulations,
    'CGAS' => :class_g_airspace,
    'CHAN' => :channel,
    'CHG' => :change_or_modification,
    'CIG' => :ceiling,
    'CK' => :check,
    'CL' => :centre_line,
    'CLKWS' => :clockwise,
    'CLR' => :clear,
    'CLSD' => :closed,
    'CMB' => :climb,
    'CMSND' => :commissioned,
    'CNL' => :cancel,
    'CNTRLN' => :centerline,
    'COM' => :communications,
    'CONC' => :concrete,
    'CPD' => :coupled,
    'CRS' => :course,
    'CTC' => :contact,
    'CTL' => :control,
    'DALGT' => :daylight,
    'DCMSN' => :decommission,
    'DCMSND' => :decommissioned,
    'DCT' => :direct,
    'DEGS' => :degrees,
    'DEP' => :departure,
    'DH' => :decision_height,
    'DISABLD' => :disabled,
    'DIST' => :distance,
    'DLA' => :delay_or_delayed,
    'DLT' => :delete,
    'DLY' => :daily,
    'DME' => :distance_measuring_equipment,
    'DMSTN' => :demonstration,
    'DP' => :dewpoint_temperature,
    'DRFT' => :snowbanks_caused_by_wind,
    'DSPLCD' => :displaced,
    'E' => :east,
    'EB' => :eastbound,
    'EFAS' => :en_route_flight_advisory_service,
    'ELEV' => :elevation,
    'ENG' => :engine,
    'ENRT' => :en_route,
    'ENTR' => :entire,
    'EXC' => :except,
    'FAC' => :facility_or_facilities,
    'FAF' => :final_approach_fix,
    'FDC' => :flight_data_center,
    'FI/T': :flight_inspection_temporay,
    'FI/P': :flight_inspection_permanent,
    'FM' => :from,
    'FNA' => :final_approach,
    'FPM' => :feet_per_minute,
    'FREQ' => :frequency,
    'FRH' => :fly_runway_heading,
    'FRI' => :friday,
    'FRZN' => :frozen,
    'FSS' => :flight_service_station,
    'FT' => :foot,
    'GC' => :ground_control,
    'GCA' => :ground_control_approach,
    'GCO' => :ground_communications_outlet,
    'GOVT' => :government,
    'GP' => :glide_path,
    'GPS' => :global_positioning_system,
    'GRVL' => :gravel,
    'HAA' => :height_above_airport,
    'HAT' => :height_above_touchdown,
    'HDG' => :heading,
    'HEL' => :helicopter,
    'HELI' => :heliport,
    'HIRL' => :high_intensity_runway_lights,
    'HIWAS' => :hazardous_inflight_weather_advisory_service,
    'HLDG' => :holding,
    'HOL' => :holiday,
    'HP' => :holding_pattern,
    'HR' => :hour,
    'IAF' => :initial_approach_fix,
    'IAP' => :instrument_approach_procedure,
    'INBD' => :inbound,
    'ID' => :identification,
    'IDENT' => :identify,
    'IF' => :intermediate_fix,
    'ILS' => :instrument_landing_system,
    'IM' => :inner_marker,
    'IMC' => :instrument_meteorological_conditions,
    'IN' => :inch,
    'INDEFLY' => :indefinitely,
    'INFO' => :information,
    'INOP' => :inoperative,
    'INSTR' => :instrument,
    'INT' => :intersection,
    'INTL' => :international,
    'INTST' => :intensity,
    'IR' => :ice_on_runway,
    'KT' => :knots,
    'L' => :left,
    'LAA' => :local_airport_advisory,
    'LAT' => :latitude,
    'LAWRS' => :limited_aviation_weather_reporting_station,
    'LB' => :pounds,
    'LC' => :local_control,
    'LOC' => :local,
    'LCTD' => :located,
    'LDA' => :localizer_type_directional_aid,
    'LGT' => :light_or_lighting,
    'LGTD' => :lighted,
    'LIRL' => :low_intensity_runway_lights,
    'LLWAS' => :low_level_wind_shear_alert_system,
    'LM' => :compass_locator_at_ils_middle_marker,
    'LDG' => :landing,
    'LLZ' => :localizer,
    'LO' => :compass_locator_at_ils_outer_marker,
    'LONG' => :longitude,
    'LRN' => :long_range_navigation,
    'LSR' => :loose_snow_on_runway,
    'LT' => :left_turn,
    'MAG' => :magnetic,
    'MAINT' => :maintenance,
    'MALS' => :medium_intensity_approach_light_system,
    'MALSF' => :medium_intensity_approach_light_system_with_sequenced_flashers,
    'MALSR' => :medium_intensity_approach_light_system_with_runway_alignment_indicator_lights,
    'MAPT' => :missed_approach_point,
    'MCA' => :minimum_crossing_altitude,
    'MDA' => :minimum_descent_altitude,
    'MEA' => :minimum_en_route_altitude,
    'MED' => :medium,
    'MIN' => :minutes,
    'MIRL' => :medium_intensity_runway_lights,
    'MKR' => :marker,
    'MLS' => :microwave_landing_system,
    'MM' => :middle_marker,
    'MNM' => :minimum,
    'MNT' => :monitor,
    'MOC' => :minimum_obstruction_clearance,
    'MON' => :monday,
    'MRA' => :minimum_reception_altitude,
    'MSA' => :minimum_safe_altitude,
    'MSAW' => :minimum_safe_altitude_warning,
    'MSG' => :message,
    'MSL' => :mean_sea_level,
    'MU' => :mu_meters,
    'MUD' => :mud,
    'MUNI' => :municipal,
    'N' => :north,
    'NA' => :not_authorized,
    'NAV' => :navigation,
    'NB' => :northbound,
    'NDB' => :nondirectional_radio_beacon,
    'NE' => :northeast,
    'NGT' => :night,
    'NM' => :nautical_miles,
    'NMR' => :nautical_mile_radius,
    'NONSTD' => :nonstandard,
    'NOPT' => :no_procedure_turn_required,
    'NR' => :number,
    'NTAP' => :notice_to_air_missions_publication,
    'NW' => :northwest,
    'OBSC' => :obscured,
    'OBST' => :obstacle,
    'OM' => :outer_marker,
    'OPR' => :operate,
    'OPS' => :operations,
    'ORIG' => :original,
    'OTS' => :out_of_service,
    'OVR' => :over,
    'PAEW' => :personnel_and_equipment_working,
    'PAX' => :passengers,
    'PAPI' => :precision_approach_path_indicator,
    'PAR' => :precision_approach_radar,
    'PARL' => :parallel,
    'PAT' => :pattern,
    'PCL' => :pilot_controlled_lighting,
    'PERM' => :permanent,
    'PJE' => :parachute_jumping_exercise,
    'PLA' => :practice_low_approach,
    'PLW' => :plow,
    'PN' => :prior_notice_required,
    'PPR' => :prior_permission_required,
    'PRN' => :psuedo_random_noise,
    'PROC' => :procedure,
    'PROP' => :propeller,
    'PSR' => :packed_snow_on_runway,
    'PTCHY' => :patchy,
    'PTN' => :procedure_turn,
    'PVT' => :private,
    'RAIL' => :runway_alignment_indicator_lights,
    'RAMOS' => :remote_automatic_meteorological_observing_system,
    'RCAG' => :remote_communication_air_ground_facility,
    'RCL' => :runway_center_line,
    'RCLL' => :runway_center_line_lights,
    'RCO' => :remote_communication_outlet,
    'REC' => :receive_or_receiver,
    'REIL' => :runway_end_identifier_lights,
    'RELCTD' => :relocated,
    'REP' => :report,
    'RLLS' => :runway_lead_in_light_system,
    'RMNDR' => :remainder,
    'RMK' => :remarks,
    'RNAV' => :area_navigation,
    'RPLC' => :replace,
    'RQRD' => :required,
    'RRL' => :runway_remaining_lights,
    'RSR' => :en_route_surveillance_radar,
    'RSVN' => :reservation,
    'RT' => :right_turn,
    'RTE' => :route,
    'RTR' => :remote_transmitter_receiver,
    'RTS' => :return_to_service,
    'RUF' => :rough,
    'RVR' => :runway_visual_range,
    'RVRM' => :runway_visual_range_midpoint,
    'RVRR' => :runway_visual_range_rollout,
    'RVRT' => :runway_visual_range_touchdown,
    'RWY' => :runway,
    'S' => :south,
    'SA' => :sand,
    'SAT' => :saturday,
    'SAWRS' => :supplementary_aviation_weather_reporting_station,
    'SB' => :southbound,
    'SDF' => :simplified_directional_facility,
    'SE' => :southeast,
    'SFL' => :sequence_flashing_lights,
    'SIMUL' => :simultaneous,
    'SIR' => :packed_snow_and_ice_on_runway,
    'SKED' => :schedule,
    'SLR' => :slush_on_runway,
    'SN' => :snow,
    'SNBNK' => :snowbanks_caused_by_plowing,
    'SNGL' => :single,
    'SPD' => :speed,
    'SSALF' => :simplified_short_approach_lighting_with_sequence_flashers,
    'SSALR' => :simplified_short_approach_lighting_with_runway_alignment_indicator_lights,
    'SSALS' => :simplified_short_approach_lighting_system,
    'SSR' => :secondary_surveillance_radar,
    'STA' => :straight_in_approach,
    'STAR' => :standard_terminal_arrival,
    'SUN' => :sunday,
    'SVC' => :service,
    'SVN' => :satellite_vehicle_number,
    'SW' => :southwest,
    'SWEPT' => :swept,
    'T' => :temperature,
    'TACAN' => :tactical_air_navigational_aid,
    'TAR' => :terminal_area_surveillance_radar,
    'TDWR' => :terminal_doppler_weather_radar,
    'TDZ' => :touchdown_zone,
    'TEMPO' => :temporary_or_temporarily,
    'TFC' => :traffic,
    'TFR' => :temporary_flight_restriction,
    'TGL' => :touch_and_go_landings,
    'THN' => :thin,
    'THR' => :threshold,
    'THRU' => :through,
    'THU' => :thursday,
    'TIL' => :until,
    'TKOF' => :takeoff,
    'TM' => :traffic_management,
    'TMPA' => :traffic_management_program_alert,
    'TRML' => :terminal,
    'TRNG' => :training,
    'TRSN' => :transition,
    'TSNT' => :transient,
    'TUE' => :tuesday,
    'TWR' => :airport_control_tower,
    'TWY' => :taxiway,
    'UAV' => :unmanned_air_vehicles,
    'UFN' => :until_further_notice,
    'UNAVBL' => :unavailable,
    'UNLGTD' => :unlighted,
    'UNMKD' => :unmarked,
    'UNMNT' => :unmonitored,
    'UNREL' => :unreliable,
    'UNUSBL' => :unusable,
    'VASI' => :visual_approach_slope_indicator_system,
    'VDP' => :visual_descent_point,
    'VIA' => :by_way_of,
    'VICE' => :versus,
    'VIS' => :visibility,
    'VMC' => :visual_meteorological_conditions,
    'VOL' => :volume,
    'VORTAC' => :vor_and_tacan,
    'W' => :west,
    'WB' => :westbound,
    'WED' => :wednesday,
    'WEF' => :with_effect_from_or_effective_from,
    'WI' => :within,
    'WIE' => :with_immediate_effect_or_effective_immediately,
    'WIP' => :work_in_progress,
    'WKDAYS' => :monday_through_friday,
    'WKEND' => :saturday_and_sunday,
    'WND' => :wind,
    'WPT' => :waypoint,
    'WSR' => :wet_snow_on_runway,
    'WTR' => :water_on_runway,
    'WX' => :weather
  }.freeze

end



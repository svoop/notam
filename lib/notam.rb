# frozen_string_literal: true

require 'i18n'

require_relative "notam/version"
require_relative "notam/translation"

require_relative "notam/item"
require_relative "notam/item/head"
require_relative "notam/item/q"
require_relative "notam/item/a"
require_relative "notam/item/b"
require_relative "notam/item/c"
require_relative "notam/item/d"
require_relative "notam/item/e"
require_relative "notam/item/f"
require_relative "notam/item/g"

I18n.load_path << Pathname(__dir__).join('locales').glob('*.yml')
I18n.available_locales = [:en]
I18n.default_locale = :en

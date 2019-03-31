module HorsConcours
  extend ActiveSupport::Concern

  # This concern applies to a column named "hors_concours"
  # The hors_concours (h/c) column uses an integer as a  bit field
  # The following bits define h/c reasons.
  # Non-zero indicates h/c only participation.

  # Not h/c
  HC_FALSE = 0

  # catch-all to make h/c when any of the other bits do not apply
  HC_NO_REASON = 1

  # pilot flew non-competitively, e.g. alone in category
  HC_NO_COMPETITION = 1 << 1

  # pilot flew a higher category (IAC rule)
  HC_HIGHER_CATEGORY = 1 << 2

  # pilot did not meet full participant criteria,
  # e.g. not a U.S. Citizen at the U.S. Nationals
  HC_NOT_QUALIFIED = 1 << 3

  included do
    scope :competitive, -> { where(hors_concours: 0) }
    scope :non_comp_allowed, -> {
      where(hors_concours: [HC_FALSE, HC_NO_COMPETITION])
    }
  end

  def set_hc_because(reason)
    hors_concours |= reason # bitwise or
  end

  def clear_hc
    hors_concours = HC_FALSE
  end
end

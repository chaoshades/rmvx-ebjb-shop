#==============================================================================
# ** Color
#------------------------------------------------------------------------------
#  Contains the different colors
#==============================================================================

class Color
  
  #--------------------------------------------------------------------------
  # * Get Shop Possession Color
  #--------------------------------------------------------------------------
  def self.shop_possess_color
    return text_color(1)
  end
  
  #--------------------------------------------------------------------------
  # * Get Sell Transaction Color
  #--------------------------------------------------------------------------
  def self.sell_transaction_color
    return text_color(24)
  end
  
  #--------------------------------------------------------------------------
  # * Get Buy Transaction Color
  #--------------------------------------------------------------------------
  def self.buy_transaction_color
    return text_color(25)
  end
  
end
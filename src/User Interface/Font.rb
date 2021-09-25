#==============================================================================
# ** Font
#------------------------------------------------------------------------------
#  Contains the different fonts
#==============================================================================

class Font
  
  #//////////////////////////////////////////////////////////////////////////
  # * Public Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Get Shop Possession Label Font
  #--------------------------------------------------------------------------
  def self.shop_possess_font
    f = Font.new()
    f.color = Color.shop_possess_color()
    f.bold = true
    return f
  end
  
  #--------------------------------------------------------------------------
  # * Get Compare Stats Font
  #--------------------------------------------------------------------------
  def self.compare_stats_font
    f = Font.new()
    f.size = 12
    return f
  end
  
  #--------------------------------------------------------------------------
  # * Get Item Details Stats Font
  #--------------------------------------------------------------------------
  def self.item_details_stats_font
    f = Font.new()
    f.size = 12
    return f
  end
  
  #--------------------------------------------------------------------------
  # * Get Item Details Plus States Font
  #--------------------------------------------------------------------------
  def self.item_details_plus_states_font
    f = Font.new()
    f.color = Color.power_up_color()
    f.size = 20
    f.bold = true
    return f
  end
  
  #--------------------------------------------------------------------------
  # * Get Item Details Minus States Font
  #--------------------------------------------------------------------------
  def self.item_details_minus_states_font
    f = Font.new()
    f.color = Color.power_down_color()
    f.size = 20
    f.bold = true
    return f
  end
  
end

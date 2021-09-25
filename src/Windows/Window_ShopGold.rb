#==============================================================================
# ** Window_ShopGold
#------------------------------------------------------------------------------
#  This window displays the amount of gold.
#==============================================================================

class Window_ShopGold < Window_Base
  include EBJB
  
  #//////////////////////////////////////////////////////////////////////////
  # * Attributes
  #//////////////////////////////////////////////////////////////////////////
  
  # UCLabelIcon control for the party gold
  attr_reader :ucGold
  
  #//////////////////////////////////////////////////////////////////////////
  # * Constructors
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     x : window X coordinate
  #     y : window Y coordinate
  #     width  : window width
  #     height : window height
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super(x, y, width, height)
    
    @ucGold = UCLabelIcon.new(self, Rect.new(0,0,100,WLH), Rect.new(110,0,WLH,WLH),
                              "", SHOP_CONFIG::ICON_GOLD)
    @ucGold.cLabel.align = 2
    window_update()
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Public Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh()
    self.contents.clear
    @ucGold.draw()
  end
  
  #--------------------------------------------------------------------------
  # * Update
  #--------------------------------------------------------------------------
  def window_update()
    @ucGold.cLabel.text = $game_party.gold
    refresh()
  end
  
end

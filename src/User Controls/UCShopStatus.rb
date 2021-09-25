#==============================================================================
# ** UCShopStatus
#------------------------------------------------------------------------------
#  Represents a group of controls to show the character status when shopping
#==============================================================================

class UCShopStatus < UserControl
  
  #//////////////////////////////////////////////////////////////////////////
  # * Attributes
  #//////////////////////////////////////////////////////////////////////////
  
  # Control to show the character graphic
  attr_reader :ucCharGraphic
  # UCLabelValue for the ATK stat of the character
  attr_reader :ucAtkStat
  # UCLabelValue for the DEF stat of the character
  attr_reader :ucDefStat
  # UCLabelValue for the SPI stat of the character
  attr_reader :ucSpiStat
  # UCLabelValue for the AGI stat of the character
  attr_reader :ucAgiStat
  # UCLabelValue for the EVA stat of the character
  attr_reader :ucEvaStat
  # UCLabelValue for the HIT stat of the character
  attr_reader :ucHitStat
  # Label for message (equivalent, can't equip and already equipped)
  attr_reader :cMsg
  # Actor object
  attr_reader :actor
  
  #//////////////////////////////////////////////////////////////////////////
  # * Properties
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Set the visible property of the controls in the user control
  #--------------------------------------------------------------------------
  # SET
  def visible=(visible)
    @visible = visible
    @ucCharGraphic.visible = visible
    @ucAtkStat.visible = visible
    @ucDefStat.visible = visible
    @ucSpiStat.visible = visible
    @ucAgiStat.visible = visible
    @ucEvaStat.visible = visible
    @ucHitStat.visible = visible
    @cMsg.visible = visible
  end

  #--------------------------------------------------------------------------
  # * Set the active property of the controls in the user control
  #--------------------------------------------------------------------------
  # SET
  def active=(active)
    @active = active
    @ucCharGraphic.active = active
    @ucAtkStat.active = active
    @ucDefStat.active = active
    @ucSpiStat.active = active
    @ucAgiStat.active = active
    @ucEvaStat.active = active
    @ucHitStat.active = active
    @cMsg.active = active
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Constructors
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     window : window in which the user control will appear
  #     actor : actor object
  #     rect : rectangle to position the controls for the actor
  #     active : control activity
  #     visible : control visibility
  #--------------------------------------------------------------------------
  def initialize(window, actor, rect, spacing=16, 
                 active=true, visible=true)
    super(active, visible)
    @actor = actor
    
    # Determine rectangles to position controls
    rects = determine_rects(rect, spacing)
    
    @ucCharGraphic = UCCharacterGraphic.new(window, rects[0], actor, 1, 255, 1)
    @ucCharGraphic.active = active
    @ucCharGraphic.visible = visible

    @ucAtkStat = UCLabelValue.new(window, rects[1][0], rects[1][1], Vocab::atk_label, 0)
    @ucAtkStat.active = active
    @ucAtkStat.visible = visible
    @ucAtkStat.cLabel.font = Font.compare_stats_font
    @ucAtkStat.cValue.font = Font.compare_stats_font
    
    @ucDefStat = UCLabelValue.new(window, rects[2][0], rects[2][1], Vocab::def_label, 0)
    @ucDefStat.active = active
    @ucDefStat.visible = visible
    @ucDefStat.cLabel.font = Font.compare_stats_font
    @ucDefStat.cValue.font = Font.compare_stats_font
    
    @ucSpiStat = UCLabelValue.new(window, rects[3][0], rects[3][1], Vocab::spi_label, 0)
    @ucSpiStat.active = active
    @ucSpiStat.visible = visible
    @ucSpiStat.cLabel.font = Font.compare_stats_font
    @ucSpiStat.cValue.font = Font.compare_stats_font
    
    @ucAgiStat = UCLabelValue.new(window, rects[4][0], rects[4][1], Vocab::agi_label, 0)
    @ucAgiStat.active = active
    @ucAgiStat.visible = visible
    @ucAgiStat.cLabel.font = Font.compare_stats_font
    @ucAgiStat.cValue.font = Font.compare_stats_font
    
    @ucEvaStat = UCLabelValue.new(window, rects[5][0], rects[5][1], Vocab::eva_label, 0)
    @ucEvaStat.active = active
    @ucEvaStat.visible = visible
    @ucEvaStat.cLabel.font = Font.compare_stats_font
    @ucEvaStat.cValue.font = Font.compare_stats_font
    
    @ucHitStat = UCLabelValue.new(window, rects[6][0], rects[6][1], Vocab::hit_label, 0)
    @ucHitStat.active = active
    @ucHitStat.visible = visible
    @ucHitStat.cLabel.font = Font.compare_stats_font
    @ucHitStat.cValue.font = Font.compare_stats_font
    
    @cMsg = CLabel.new(window, rects[7], "")
    @cMsg.active = active
    @cMsg.visible = visible
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Public Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Draw the controls
  #--------------------------------------------------------------------------
  def draw()
    @ucCharGraphic.draw()
    @ucAtkStat.draw()
    @ucDefStat.draw()
    @ucSpiStat.draw()
    @ucAgiStat.draw()
    @ucEvaStat.draw()
    @ucHitStat.draw()
    @cMsg.draw()
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Private Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Determine rectangles to positions controls in the user control
  #     rect : base rectangle to position the controls
  #     spacing : spacing between controls
  #--------------------------------------------------------------------------
  def determine_rects(rect, spacing)
    rects = []
    
    # Rects Initialization
    rects[0] = Rect.new(rect.x,rect.y,40,rect.height)
    rects[1] = [Rect.new(rect.x,rect.y,35,24),
                Rect.new(rect.x,rect.y,rect.width,24)]
    rects[2] = [Rect.new(rect.x,rect.y,35,24),
                Rect.new(rect.x,rect.y,rect.width,24)]
    rects[3] = [Rect.new(rect.x,rect.y,35,24),
                Rect.new(rect.x,rect.y,rect.width,24)]
    rects[4] = [Rect.new(rect.x,rect.y,35,24),
                Rect.new(rect.x,rect.y,rect.width,24)]
    rects[5] = [Rect.new(rect.x,rect.y,35,24),
                Rect.new(rect.x,rect.y,rect.width,24)]
    rects[6] = [Rect.new(rect.x,rect.y,35,24),
                Rect.new(rect.x,rect.y,rect.width,24)]
    rects[7] = Rect.new(rect.x,rect.y,rect.width,24)
    
    adjust_y = (rect.height / (3*24)).floor
    value_width = ((rect.width - rects[0].width - (35*2) - spacing) / 2).floor
       
    # Rects Adjustments
    
    # ucCharGraphic
    # Nothing to do
    
    # ucAtkStat
    rects[1][0].x += rects[0].width
    rects[1][0].y += adjust_y
    rects[1][1].x = rects[1][0].x + rects[1][0].width
    rects[1][1].y = rects[1][0].y
    rects[1][1].width = value_width

    # ucDefStat
    rects[2][0].x += rects[0].width + rects[1][0].width + value_width + spacing
    rects[2][0].y += adjust_y
    rects[2][1].x = rects[2][0].x + rects[2][0].width
    rects[2][1].y = rects[2][0].y
    rects[2][1].width = value_width
    
    # ucSpiStat   
    rects[3][0].x += rects[0].width
    rects[3][0].y += adjust_y + spacing
    rects[3][1].x = rects[3][0].x + rects[3][0].width
    rects[3][1].y = rects[3][0].y
    rects[3][1].width = value_width
    
    # ucAgiStat
    rects[4][0].x += rects[0].width + rects[3][0].width + value_width + spacing
    rects[4][0].y += adjust_y + spacing
    rects[4][1].x = rects[4][0].x + rects[4][0].width
    rects[4][1].y = rects[4][0].y
    rects[4][1].width = value_width
    
    # ucEvaStat   
    rects[5][0].x += rects[0].width
    rects[5][0].y += adjust_y + (spacing*2)
    rects[5][1].x = rects[5][0].x + rects[5][0].width
    rects[5][1].y = rects[5][0].y
    rects[5][1].width = value_width
    
    # ucHitStat
    rects[6][0].x += rects[0].width + rects[5][0].width + value_width + spacing
    rects[6][0].y += adjust_y + (spacing*2)
    rects[6][1].x = rects[6][0].x + rects[6][0].width
    rects[6][1].y = rects[6][0].y
    rects[6][1].width = value_width
    
    # cMsg
    rects[7].x += rects[0].width
    rects[7].y += ((rect.height-rects[7].height)/2).floor
    
    return rects
  end
  private :determine_rects
  
end

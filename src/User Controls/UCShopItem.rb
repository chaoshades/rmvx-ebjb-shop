#==============================================================================
# ** UCShopItem
#------------------------------------------------------------------------------
#  Represents a group of controls for a shoppable item
#==============================================================================

class UCShopItem < UserControl
  
  #//////////////////////////////////////////////////////////////////////////
  # * Attributes
  #//////////////////////////////////////////////////////////////////////////
  
  # Icon control for the shop item
  attr_reader   :ucIcon
  # Label control for the shop item name
  attr_reader   :cItemName
  # Label control for the shop item price
  attr_reader   :cItemPrice
  # Label control for the shop item possession in the inventory
  attr_reader   :cItemPossess
  # Label control for the shop item current selected quantity
  attr_reader   :ucItemNumber
  # Item object
  attr_reader   :item
  
  #//////////////////////////////////////////////////////////////////////////
  # * Properties
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Set the visible property of the controls in the user control
  #--------------------------------------------------------------------------
  # SET
  def visible=(visible)
    @visible = visible
    @ucIcon.visible = visible
    @cItemName.visible = visible
    @cItemPrice.visible = visible
    @cItemPossess.visible = visible
    @ucItemNumber.visible = visible
  end

  #--------------------------------------------------------------------------
  # * Set the active property of the controls in the user control
  #--------------------------------------------------------------------------
  # SET
  def active=(active)
    @active = active
    @ucIcon.active = active
    @cItemName.active = active
    @cItemPrice.active = active
    @cItemPossess.active = active
    @ucItemNumber.active = active
  end
  
  #--------------------------------------------------------------------------
  # * Get the current selected quantity of the item
  #--------------------------------------------------------------------------
  # GET
  def quantity
    return @ucItemNumber.value
  end
  
  #--------------------------------------------------------------------------
  # * Get the current quantity of the item in the inventory
  #--------------------------------------------------------------------------
  # GET
  def inventory_quantity
    return @cItemPossess.text.to_i
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Constructors
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     window : window in which the user control will appear
  #     item : item object
  #     rect : rectangle to position the controls for the item
  #     itemNumberPattern : Pattern to use for the UCNumericUpDown control
  #     spacing : spacing between controls
  #     active : control activity
  #     visible : control visibility
  #--------------------------------------------------------------------------
  def initialize(window, item, rect, itemNumberPattern, spacing=8,
                 active=true, visible=true)
    super(active, visible)
    @item = item
    
    # Determine rectangles to position controls
    rects = determine_rects(rect, spacing)
    
    @ucIcon = UCIcon.new(window, rects[0], item.icon_index)
    @ucIcon.active = active
    @ucIcon.visible = visible

    @cItemName = CLabel.new(window, rects[1], item.name)
    @cItemName.active = active
    @cItemName.visible = visible
    @cItemName.cut_overflow = true

    @cItemPrice = CLabel.new(window, rects[2], item.price)
    @cItemPrice.active = active
    @cItemPrice.visible = visible

    @cItemPossess = CLabel.new(window, rects[3], $game_party.item_number(item))
    @cItemPossess.active = active
    @cItemPossess.visible = visible

    @ucItemNumber = UCNumericUpDown.new(window, rects[4], 0, itemNumberPattern)
    @ucItemNumber.active = active
    @ucItemNumber.visible = visible
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Public Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Draw the groups of controls on the window
  #--------------------------------------------------------------------------
  def draw()
    @ucIcon.draw()
    @cItemName.draw()
    @cItemPrice.draw()
    @cItemPossess.draw()
    @ucItemNumber.draw()
  end
  
  #--------------------------------------------------------------------------
  # * Returns true if the quantity of items == max of the numeric up down
  #--------------------------------------------------------------------------
  def is_max_number?()
    return @ucItemNumber.value == @ucItemNumber.max
  end
  
  #--------------------------------------------------------------------------
  # * Returns true if the quantity of items == min of the numeric up down
  #--------------------------------------------------------------------------
  def is_min_number?()
    return @ucItemNumber.value == @ucItemNumber.min
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
    rects[0] = Rect.new(rect.x,rect.y,24,rect.height)
    rects[1] = Rect.new(rect.x,rect.y,rect.width,rect.height)
    rects[2] = Rect.new(rect.x,rect.y,64,rect.height)
    rects[3] = Rect.new(rect.x,rect.y,24,rect.height)
    rects[4] = Rect.new(rect.x,rect.y,32,rect.height)
    
    # Rects Adjustments
    
    # ucIcon
    # Nothing to do
    
    # cItemName
    rects[1].x += rects[0].width
    rects[1].width = rect.width - rects[0].width - rects[2].width - rects[3].width - rects[4].width - (spacing*3)
    
    # cItemPrice
    rects[2].x += rect.width - rects[2].width - rects[3].width - rects[4].width - (spacing*2)
    
    # cItemPossess   
    rects[3].x += rect.width - rects[3].width - rects[4].width - spacing
    
    # ucItemNumber
    rects[4].x += rect.width - rects[4].width
    
    return rects
  end
  private :determine_rects
  
end

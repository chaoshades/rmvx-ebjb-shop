#==============================================================================
# ** Window_Shop
#------------------------------------------------------------------------------
#  This window displays the items for a shop screen.
#==============================================================================

class Window_Shop < Window_Selectable
  include EBJB
  
  #//////////////////////////////////////////////////////////////////////////
  # * Attributes
  #//////////////////////////////////////////////////////////////////////////
  
  # Array of UCShopItem for every item of the shop
  attr_reader :ucShopItemsList
  
  #//////////////////////////////////////////////////////////////////////////
  # * Properties
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Get the current ShopItem
  #--------------------------------------------------------------------------
  # GET
  def selected_item
    return (self.index < 0 ? nil : @ucShopItemsList[self.index])
  end
  
  #--------------------------------------------------------------------------
  # * Get the selected ShopItems (number > 0 or min)
  #--------------------------------------------------------------------------
  # GET
  def selected_items
    itemArray = []
    for shopItem in @ucShopItemsList
      if !shopItem.is_min_number?
        itemArray.push(shopItem)
      end
    end
    return itemArray
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Constructors
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     x : window X coordinate
  #     y : window Y coordinate
  #     width  : window width
  #     height : window height
  #     item : list of the items
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height, items)
    super(x, y, width, height)
    @ucShopItemsList = []
    window_update(items)
    self.index = 0
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Public Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh()
    self.contents.clear
    @ucShopItemsList.each() { |shopItem| shopItem.draw() }
  end
  
  #--------------------------------------------------------------------------
  # * Update
  #--------------------------------------------------------------------------
  def window_update(shop_items)
    @data = []
    if shop_items != nil
      for shop_item in shop_items
        if shop_item != nil
          @data.push(shop_item)
        end
      end
      @item_max = @data.size
      create_contents()
      @ucShopItemsList.clear()
      for i in 0..@item_max-1
        @ucShopItemsList.push(create_item(i))
      end
    end
    refresh()
  end
  
  #--------------------------------------------------------------------------
  # * Update the numeric up down
  #--------------------------------------------------------------------------
  def update_number_select(isUp)
    if isUp
      selected_item.ucItemNumber.up()
    else
      selected_item.ucItemNumber.down()
    end
    refresh()
  end
  
  #--------------------------------------------------------------------------
  # * Update Help Text
  #--------------------------------------------------------------------------
  def update_help
    if selected_item != nil
      @help_window.window_update(selected_item.item.description)
    else
      @help_window.window_update("")
    end
  end
  
  #--------------------------------------------------------------------------
  # * Update Detail Window
  #--------------------------------------------------------------------------
  def update_detail
    if selected_item != nil
      @detail_window.window_update(selected_item.item)
    else
      @detail_window.window_update(nil)
    end
  end
  
  #--------------------------------------------------------------------------
  # * Determine if help/detail window can be switched
  #--------------------------------------------------------------------------
  def is_switchable
    return selected_item != nil && 
           ((selected_item.item.is_a?(RPG::Item) && detail_window.is_a?(Window_ItemDetails)) ||
           (!selected_item.item.is_a?(RPG::Item) && detail_window.is_a?(Window_EquipDetails)))
  end
  
  #--------------------------------------------------------------------------
  # * Reset the numeric up down controls
  #--------------------------------------------------------------------------
  def reset_number_select()
    @ucShopItemsList.each() { |shopItem| shopItem.ucItemNumber.reset() }
    refresh()
  end
  
  #--------------------------------------------------------------------------
  # * Update ShopItems activity
  #--------------------------------------------------------------------------
  def update_items_activity(party_gold)
    @ucShopItemsList.each() { |shopItem| shopItem.active = 
                              shopItem.item.price <= party_gold &&
                              shopItem.inventory_quantity < SHOP_CONFIG::MAX_ITEM}
    refresh()
  end
  
  #//////////////////////////////////////////////////////////////////////////
  # * Private Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Create an item for the ShopItems list (contents are defined by the subclasses)
  #     index : item index
  #--------------------------------------------------------------------------
  def create_item(index)
  end
  private :create_item
  
end

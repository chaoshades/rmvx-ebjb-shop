#==============================================================================
# ** Window_ShopBuy
#------------------------------------------------------------------------------
#  This window displays buyable goods on the shop screen.
#==============================================================================

class Window_ShopBuy < Window_Shop
  include EBJB
  
  #//////////////////////////////////////////////////////////////////////////
  # * Private Methods
  #//////////////////////////////////////////////////////////////////////////
  
  #--------------------------------------------------------------------------
  # * Create an item for the ShopItems list 
  #     index : item index
  #--------------------------------------------------------------------------
  def create_item(index)
    item = @data[index]
    rect = item_rect(index, true)
    
    shopItem = UCShopItem.new(self, item, rect,
                              SHOP_CONFIG::ITEM_NUMBER_PATTERN)
                              
    shopItem.cItemPrice.align = 2 
    shopItem.cItemPossess.align = 2 
    shopItem.cItemPossess.font = Font.shop_possess_font
    shopItem.ucItemNumber.cLabelNumber.align = 2
    shopItem.ucItemNumber.min = 0
    shopItem.ucItemNumber.max = SHOP_CONFIG::MAX_ITEM - shopItem.inventory_quantity
    return shopItem
  end
  private :create_item
  
end

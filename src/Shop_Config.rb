#==============================================================================
# ** SHOP_CONFIG
#------------------------------------------------------------------------------
#  Contains the Shop configuration
#==============================================================================

module EBJB
  module SHOP_CONFIG
    
    # Background image filename, it must be in folder Pictures
    IMAGE_BG = ""
    # Opacity for background image
    IMAGE_BG_OPACITY = 255
    # All windows opacity
    WINDOW_OPACITY = 255
    WINDOW_BACK_OPACITY = 200
        
    #------------------------------------------------------------------------
    # Window Transaction related
    #------------------------------------------------------------------------
    
    # Symbol for buying
    BUYING_SYMBOL = "-"
    # Symbol for selling
    SELLING_SYMBOL = "+"
    
    #------------------------------------------------------------------------
    # Window Gold related
    #------------------------------------------------------------------------
    
    # Icon for GOLD
    ICON_GOLD = 147
    
    #------------------------------------------------------------------------
    # Window Shop related
    #------------------------------------------------------------------------
    
    # Max number of items allowed to buy or sell in one time
    MAX_ITEM = 99
    # Pattern used to show the item desired quantity
    ITEM_NUMBER_PATTERN = "×%d"
    
    #------------------------------------------------------------------------
    # Window Shop Status related
    #------------------------------------------------------------------------
    
    # Symbol when a stat is higher with the new item
    POWERUP_SYMBOL = "+" #"▲"
    # Symbol when a stat is lower with the new item
    POWERDOWN_SYMBOL = "-" #"▼"
    
  end
end
